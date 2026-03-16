"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.exportTeachingData = exports.getStudentAnalysis = exports.getClassSituation = exports.getTeachingDashboard = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 获取教学数据驾驶舱
const getTeachingDashboard = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        if (!teacherId)
            throw new errorHandler_1.AppError('用户未登录', 401);
        const { classId } = req.params;
        // 验证权限
        const classes = await (0, connection_1.query)('SELECT * FROM classes WHERE id = ? AND teacher_id = ?', [classId, teacherId]);
        if (classes.length === 0) {
            throw new errorHandler_1.AppError('无权访问该班级数据', 403);
        }
        // 获取或创建今日报告
        const today = new Date().toISOString().split('T')[0];
        let dashboards = await (0, connection_1.query)(`SELECT * FROM teaching_dashboard 
       WHERE teacher_id = ? AND class_id = ? AND report_date = ?`, [teacherId, classId, today]);
        if (dashboards.length === 0) {
            // 生成新报告
            const dashboardData = await generateDashboardData(teacherId, parseInt(classId));
            const result = await (0, connection_1.query)(`INSERT INTO teaching_dashboard 
         (teacher_id, class_id, report_date, class_situation, 
          assignment_completion_rate, average_score, interaction_degree, 
          knowledge_mastery, weak_students, excellent_students, 
          teaching_suggestions, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`, [
                teacherId,
                classId,
                today,
                JSON.stringify(dashboardData.class_situation),
                dashboardData.assignment_completion_rate,
                dashboardData.average_score,
                JSON.stringify(dashboardData.interaction_degree),
                JSON.stringify(dashboardData.knowledge_mastery),
                JSON.stringify(dashboardData.weak_students),
                JSON.stringify(dashboardData.excellent_students),
                dashboardData.teaching_suggestions,
            ]);
            dashboards = await (0, connection_1.query)('SELECT * FROM teaching_dashboard WHERE id = ?', [result.insertId]);
        }
        res.json({
            success: true,
            data: dashboards[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getTeachingDashboard = getTeachingDashboard;
// 生成仪表盘数据
async function generateDashboardData(teacherId, classId) {
    // 获取学生列表
    const students = await (0, connection_1.query)(`SELECT u.id, u.real_name 
     FROM users u 
     JOIN class_students cs ON u.id = cs.student_id
     WHERE cs.class_id = ? AND cs.status = 'active'`, [classId]);
    // 作业完成率
    const assignmentStats = await (0, connection_1.query)(`SELECT 
       COUNT(DISTINCT a.id) as total_assignments,
       COUNT(DISTINCT asub.id) as submitted_count,
       AVG(asub.score) as avg_score
     FROM assignments a
     LEFT JOIN assignment_submissions asub ON a.id = asub.assignment_id
     WHERE a.class_id = ? 
       AND a.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)`, [classId]);
    const totalStudents = students.length;
    const totalAssignments = assignmentStats[0].total_assignments || 1;
    const completionRate = (assignmentStats[0].submitted_count / (totalStudents * totalAssignments)) * 100;
    // 互动度统计
    const interactionStats = await (0, connection_1.query)(`SELECT 
       COUNT(*) as total_interactions,
       COUNT(DISTINCT student_id) as active_students
     FROM classroom_interactions ci
     JOIN courses c ON ci.course_id = c.id
     WHERE c.class_id = ? 
       AND ci.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)`, [classId]);
    // 知识点掌握情况
    const knowledgeMastery = await (0, connection_1.query)(`SELECT kn.name,
       AVG(CASE WHEN ci.is_correct = 1 THEN 100 ELSE 0 END) as mastery_rate
     FROM classroom_interactions ci
     JOIN courses c ON ci.course_id = c.id
     JOIN knowledge_nodes kn ON 1=1
     WHERE c.class_id = ?
       AND ci.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
     GROUP BY kn.id
     LIMIT 10`, [classId]);
    // 待帮扶学生
    const weakStudents = await (0, connection_1.query)(`SELECT u.id, u.real_name, AVG(asub.score) as avg_score
     FROM users u
     JOIN class_students cs ON u.id = cs.student_id
     LEFT JOIN assignment_submissions asub ON u.id = asub.student_id
     WHERE cs.class_id = ? AND cs.status = 'active'
     GROUP BY u.id
     HAVING avg_score < 60 OR avg_score IS NULL
     LIMIT 10`, [classId]);
    // 优秀学生
    const excellentStudents = await (0, connection_1.query)(`SELECT u.id, u.real_name, AVG(asub.score) as avg_score
     FROM users u
     JOIN class_students cs ON u.id = cs.student_id
     JOIN assignment_submissions asub ON u.id = asub.student_id
     WHERE cs.class_id = ? AND cs.status = 'active'
     GROUP BY u.id
     HAVING avg_score >= 85
     ORDER BY avg_score DESC
     LIMIT 10`, [classId]);
    const suggestions = `
根据班级数据分析：
1. 班级作业完成率 ${completionRate.toFixed(1)}%，${completionRate < 70 ? '需要加强督促' : '表现良好'}
2. 有 ${weakStudents.length} 名学生需要重点帮扶
3. ${excellentStudents.length} 名优秀学生可以发挥带头作用
4. 建议加强${knowledgeMastery[0]?.name || '重点知识'}的练习
  `.trim();
    return {
        class_situation: {
            total_students: totalStudents,
            active_students: interactionStats[0].active_students || 0,
            engagement_rate: (interactionStats[0].active_students / totalStudents) * 100 || 0,
        },
        assignment_completion_rate: completionRate,
        average_score: assignmentStats[0].avg_score || 0,
        interaction_degree: {
            total: interactionStats[0].total_interactions || 0,
            per_student: (interactionStats[0].total_interactions / totalStudents) || 0,
        },
        knowledge_mastery: knowledgeMastery,
        weak_students: weakStudents,
        excellent_students: excellentStudents,
        teaching_suggestions: suggestions,
    };
}
// 获取班级学情
const getClassSituation = async (req, res, next) => {
    try {
        const { classId } = req.params;
        const teacherId = req.user?.id;
        if (!teacherId)
            throw new errorHandler_1.AppError('用户未登录', 401);
        // 验证权限
        const classes = await (0, connection_1.query)('SELECT * FROM classes WHERE id = ? AND teacher_id = ?', [classId, teacherId]);
        if (classes.length === 0) {
            throw new errorHandler_1.AppError('无权访问该班级', 403);
        }
        const situation = await generateDashboardData(teacherId, parseInt(classId));
        res.json({
            success: true,
            data: situation.class_situation,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getClassSituation = getClassSituation;
// 获取学生分析
const getStudentAnalysis = async (req, res, next) => {
    try {
        const { studentId } = req.params;
        // 获取学生基本信息
        const students = await (0, connection_1.query)('SELECT id, username, real_name, email FROM users WHERE id = ?', [studentId]);
        if (students.length === 0) {
            throw new errorHandler_1.AppError('学生不存在', 404);
        }
        // 获取学习数据
        const learningData = await (0, connection_1.query)(`SELECT 
         COUNT(DISTINCT asub.id) as assignment_count,
         AVG(asub.score) as avg_score,
         COUNT(DISTINCT ci.id) as interaction_count,
         COUNT(DISTINCT qa.id) as question_count
       FROM users u
       LEFT JOIN assignment_submissions asub ON u.id = asub.student_id
       LEFT JOIN classroom_interactions ci ON u.id = ci.student_id
       LEFT JOIN qa_records qa ON u.id = qa.student_id
       WHERE u.id = ?`, [studentId]);
        // 获取薄弱知识点
        const weakPoints = await (0, connection_1.query)(`SELECT kn.name, COUNT(*) as error_count
       FROM error_questions eq
       JOIN knowledge_nodes kn ON eq.knowledge_node_id = kn.id
       WHERE eq.student_id = ?
       GROUP BY kn.id
       ORDER BY error_count DESC
       LIMIT 5`, [studentId]);
        res.json({
            success: true,
            data: {
                student: students[0],
                learning_data: learningData[0],
                weak_points: weakPoints,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getStudentAnalysis = getStudentAnalysis;
// 导出教学数据
const exportTeachingData = async (req, res, next) => {
    try {
        const { classId } = req.params;
        const teacherId = req.user?.id;
        if (!teacherId)
            throw new errorHandler_1.AppError('用户未登录', 401);
        // 获取完整数据
        const dashboardData = await generateDashboardData(teacherId, parseInt(classId));
        res.json({
            success: true,
            message: '数据导出成功',
            data: {
                export_time: new Date().toISOString(),
                class_id: classId,
                data: dashboardData,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.exportTeachingData = exportTeachingData;
//# sourceMappingURL=dashboard.controller.js.map