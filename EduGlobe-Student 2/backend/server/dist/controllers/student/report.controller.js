"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPersonalizedPath = exports.getAbilityRadar = exports.getWeakPoints = exports.getLearningReport = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 获取学习报告
const getLearningReport = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        if (!studentId)
            throw new errorHandler_1.AppError('用户未登录', 401);
        const { type } = req.params; // daily, weekly, monthly, semester
        if (!['daily', 'weekly', 'monthly', 'semester'].includes(type)) {
            throw new errorHandler_1.AppError('无效的报告类型', 400);
        }
        // 计算日期范围
        const now = new Date();
        let startDate = new Date();
        let endDate = now;
        switch (type) {
            case 'daily':
                startDate = new Date(now.setHours(0, 0, 0, 0));
                break;
            case 'weekly':
                startDate = new Date(now.setDate(now.getDate() - 7));
                break;
            case 'monthly':
                startDate = new Date(now.setMonth(now.getMonth() - 1));
                break;
            case 'semester':
                startDate = new Date(now.setMonth(now.getMonth() - 6));
                break;
        }
        // 查找已生成的报告
        let reports = await (0, connection_1.query)(`SELECT * FROM learning_reports 
       WHERE student_id = ? AND report_type = ? 
         AND start_date >= ? AND end_date <= ?
       ORDER BY created_at DESC
       LIMIT 1`, [studentId, type, startDate, endDate]);
        // 如果没有报告，生成新报告
        if (reports.length === 0) {
            const reportData = await generateLearningReport(studentId, type, startDate, endDate);
            const result = await (0, connection_1.query)(`INSERT INTO learning_reports 
         (student_id, report_type, start_date, end_date, study_duration_minutes, 
          knowledge_mastery, weak_points, ability_radar, progress_trend, 
          suggestions, statistics, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`, [
                studentId,
                type,
                startDate,
                endDate,
                reportData.study_duration_minutes,
                JSON.stringify(reportData.knowledge_mastery),
                JSON.stringify(reportData.weak_points),
                JSON.stringify(reportData.ability_radar),
                JSON.stringify(reportData.progress_trend),
                reportData.suggestions,
                JSON.stringify(reportData.statistics),
            ]);
            reports = await (0, connection_1.query)('SELECT * FROM learning_reports WHERE id = ?', [result.insertId]);
        }
        res.json({
            success: true,
            data: reports[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getLearningReport = getLearningReport;
// 生成学习报告（辅助函数）
async function generateLearningReport(studentId, type, startDate, endDate) {
    // 获取学习时长
    const durationResult = await (0, connection_1.query)(`SELECT SUM(duration_seconds) / 60 as total_minutes
     FROM classroom_interactions
     WHERE student_id = ? AND created_at BETWEEN ? AND ?`, [studentId, startDate, endDate]);
    // 获取作业完成情况
    const assignmentStats = await (0, connection_1.query)(`SELECT 
       COUNT(*) as total,
       AVG(score) as avg_score,
       SUM(CASE WHEN status = 'graded' THEN 1 ELSE 0 END) as completed
     FROM assignment_submissions
     WHERE student_id = ? AND submit_time BETWEEN ? AND ?`, [studentId, startDate, endDate]);
    // 知识点掌握度
    const knowledgeMastery = await (0, connection_1.query)(`SELECT kn.name, kn.id,
       AVG(CASE WHEN ci.is_correct = 1 THEN 100 ELSE 0 END) as mastery_rate
     FROM classroom_interactions ci
     JOIN knowledge_nodes kn ON JSON_CONTAINS(CAST(kn.id AS CHAR), ci.content)
     WHERE ci.student_id = ? AND ci.created_at BETWEEN ? AND ?
     GROUP BY kn.id
     ORDER BY mastery_rate DESC`, [studentId, startDate, endDate]);
    // 薄弱知识点
    const weakPoints = await (0, connection_1.query)(`SELECT kn.name, COUNT(*) as error_count
     FROM error_questions eq
     JOIN knowledge_nodes kn ON eq.knowledge_node_id = kn.id
     WHERE eq.student_id = ? AND eq.created_at BETWEEN ? AND ?
       AND eq.mastery_level < 3
     GROUP BY kn.id
     ORDER BY error_count DESC
     LIMIT 5`, [studentId, startDate, endDate]);
    // 能力雷达图数据
    const abilityRadar = {
        knowledge: Math.floor(Math.random() * 30) + 70,
        skill: Math.floor(Math.random() * 30) + 70,
        thinking: Math.floor(Math.random() * 30) + 70,
        practice: Math.floor(Math.random() * 30) + 70,
        innovation: Math.floor(Math.random() * 30) + 70,
    };
    // 进步趋势
    const progressTrend = [
        { date: '2024-01', score: 75 },
        { date: '2024-02', score: 78 },
        { date: '2024-03', score: 82 },
    ];
    // AI建议
    const suggestions = `根据您在${type}的学习情况，建议：
1. 继续保持对${knowledgeMastery[0]?.name || '基础知识'}的学习热情
2. 加强对${weakPoints[0]?.name || '薄弱环节'}的练习
3. 建议每天学习30-45分钟，保持学习连续性`;
    return {
        study_duration_minutes: durationResult[0]?.total_minutes || 0,
        knowledge_mastery: knowledgeMastery,
        weak_points: weakPoints,
        ability_radar: abilityRadar,
        progress_trend: progressTrend,
        suggestions,
        statistics: assignmentStats[0],
    };
}
// 获取薄弱知识点
const getWeakPoints = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const weakPoints = await (0, connection_1.query)(`SELECT 
         kn.id, kn.name, kn.description,
         COUNT(eq.id) as error_count,
         AVG(eq.mastery_level) as avg_mastery,
         MAX(eq.last_review_time) as last_review_time
       FROM error_questions eq
       JOIN knowledge_nodes kn ON eq.knowledge_node_id = kn.id
       WHERE eq.student_id = ? AND eq.mastery_level < 4
       GROUP BY kn.id
       ORDER BY error_count DESC, avg_mastery ASC
       LIMIT 10`, [studentId]);
        res.json({
            success: true,
            data: weakPoints,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getWeakPoints = getWeakPoints;
// 获取能力雷达图
const getAbilityRadar = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        if (!studentId)
            throw new errorHandler_1.AppError('用户未登录', 401);
        // 计算各项能力得分  
        const abilities = {
            knowledge: await calculateKnowledgeScore(studentId),
            skill: await calculateSkillScore(studentId),
            thinking: await calculateThinkingScore(studentId),
            practice: await calculatePracticeScore(studentId),
            innovation: await calculateInnovationScore(studentId),
        };
        res.json({
            success: true,
            data: abilities,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getAbilityRadar = getAbilityRadar;
// 获取个性化学习路径
const getPersonalizedPath = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        let paths = await (0, connection_1.query)(`SELECT * FROM learning_paths WHERE student_id = ?`, [studentId]);
        if (paths.length === 0) {
            // 创建新的学习路径
            const weakKnowledge = await (0, connection_1.query)(`SELECT knowledge_node_id FROM error_questions
         WHERE student_id = ? AND mastery_level < 3
         GROUP BY knowledge_node_id
         LIMIT 10`, [studentId]);
            const recommendedSequence = weakKnowledge.map((item, index) => ({
                order: index + 1,
                knowledge_node_id: item.knowledge_node_id,
                estimated_time: 30, // 分钟
            }));
            const result = await (0, connection_1.query)(`INSERT INTO learning_paths 
         (student_id, current_level, target_level, weak_knowledge_nodes, 
          recommended_sequence, progress)
         VALUES (?, 3, 5, ?, ?, 0)`, [studentId, JSON.stringify(weakKnowledge), JSON.stringify(recommendedSequence)]);
            paths = await (0, connection_1.query)('SELECT * FROM learning_paths WHERE id = ?', [result.insertId]);
        }
        res.json({
            success: true,
            data: paths[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getPersonalizedPath = getPersonalizedPath;
// 辅助函数：计算各项能力得分
async function calculateKnowledgeScore(studentId) {
    const result = await (0, connection_1.query)(`SELECT AVG(score) as avg_score FROM assignment_submissions 
     WHERE student_id = ? AND status = 'graded'`, [studentId]);
    return Math.min(100, Math.floor(result[0]?.avg_score || 75));
}
async function calculateSkillScore(studentId) {
    const result = await (0, connection_1.query)(`SELECT COUNT(*) as practice_count FROM game_records 
     WHERE student_id = ?`, [studentId]);
    return Math.min(100, 60 + Math.floor((result[0]?.practice_count || 0) * 2));
}
async function calculateThinkingScore(studentId) {
    const result = await (0, connection_1.query)(`SELECT COUNT(*) as question_count FROM qa_records 
     WHERE student_id = ?`, [studentId]);
    return Math.min(100, 65 + Math.floor((result[0]?.question_count || 0) * 1.5));
}
async function calculatePracticeScore(studentId) {
    const result = await (0, connection_1.query)(`SELECT COUNT(*) as interaction_count FROM classroom_interactions 
     WHERE student_id = ?`, [studentId]);
    return Math.min(100, 70 + Math.floor((result[0]?.interaction_count || 0) * 0.5));
}
async function calculateInnovationScore(studentId) {
    const result = await (0, connection_1.query)(`SELECT COUNT(*) as post_count FROM channel_posts 
     WHERE author_id = ?`, [studentId]);
    return Math.min(100, 60 + Math.floor((result[0]?.post_count || 0) * 3));
}
//# sourceMappingURL=report.controller.js.map