"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTeachingPaceSuggestion = exports.getHotQuestions = exports.getInteractionStats = exports.getClassroomMonitoring = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 获取课堂监控数据
const getClassroomMonitoring = async (req, res, next) => {
    try {
        const { courseId } = req.params;
        const teacherId = req.user?.id;
        // 验证课程权限
        const courses = await (0, connection_1.query)('SELECT * FROM courses c JOIN classes cls ON c.class_id = cls.id WHERE c.id = ? AND cls.teacher_id = ?', [courseId, teacherId]);
        if (courses.length === 0) {
            throw new errorHandler_1.AppError('无权访问该课堂', 403);
        }
        // 获取实时监控数据
        const monitoring = await (0, connection_1.query)(`SELECT 
         AVG(attention_level) as avg_attention,
         COUNT(*) as interaction_count,
         SUM(CASE WHEN emotion = 'happy' THEN 1 ELSE 0 END) as happy_count,
         SUM(CASE WHEN emotion = 'confused' THEN 1 ELSE 0 END) as confused_count,
         SUM(CASE WHEN emotion = 'bored' THEN 1 ELSE 0 END) as bored_count
       FROM classroom_interactions
       WHERE course_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 10 MINUTE)`, [courseId]);
        // 保存监控快照
        await (0, connection_1.query)(`INSERT INTO classroom_monitoring 
       (course_id, monitoring_time, average_attention, emotion_distribution, interaction_stats)
       VALUES (?, NOW(), ?, ?, ?)`, [
            courseId,
            monitoring[0].avg_attention || 0,
            JSON.stringify({
                happy: monitoring[0].happy_count || 0,
                confused: monitoring[0].confused_count || 0,
                bored: monitoring[0].bored_count || 0,
            }),
            JSON.stringify({
                total: monitoring[0].interaction_count || 0,
            }),
        ]);
        res.json({
            success: true,
            data: monitoring[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getClassroomMonitoring = getClassroomMonitoring;
// 获取互动统计
const getInteractionStats = async (req, res, next) => {
    try {
        const { courseId } = req.params;
        const stats = await (0, connection_1.query)(`SELECT 
         interaction_type,
         COUNT(*) as count,
         AVG(CASE WHEN is_correct IS NOT NULL THEN is_correct ELSE 0 END) as accuracy
       FROM classroom_interactions
       WHERE course_id = ?
       GROUP BY interaction_type`, [courseId]);
        res.json({
            success: true,
            data: stats,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getInteractionStats = getInteractionStats;
// 获取提问热点
const getHotQuestions = async (req, res, next) => {
    try {
        const { courseId } = req.params;
        const questions = await (0, connection_1.query)(`SELECT content, COUNT(*) as count
       FROM classroom_interactions
       WHERE course_id = ? AND interaction_type = 'question'
       GROUP BY content
       ORDER BY count DESC
       LIMIT 10`, [courseId]);
        res.json({
            success: true,
            data: questions,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getHotQuestions = getHotQuestions;
// 获取教学节奏建议
const getTeachingPaceSuggestion = async (req, res, next) => {
    try {
        const { courseId } = req.params;
        const monitoring = await (0, connection_1.query)(`SELECT average_attention, interaction_stats, blind_spots
       FROM classroom_monitoring
       WHERE course_id = ?
       ORDER BY monitoring_time DESC
       LIMIT 1`, [courseId]);
        let suggestion = '';
        if (monitoring.length > 0) {
            const avgAttention = monitoring[0].average_attention;
            if (avgAttention < 3) {
                suggestion = '学生专注度较低，建议：\n1. 增加互动环节\n2. 使用多媒体辅助\n3. 适当休息';
            }
            else if (avgAttention > 4) {
                suggestion = '学生专注度很好，可以：\n1. 适当增加难度\n2. 深入讲解重点\n3. 鼓励学生提问';
            }
            else {
                suggestion = '教学节奏良好，继续保持';
            }
        }
        res.json({
            success: true,
            data: {
                monitoring: monitoring[0] || {},
                suggestion,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getTeachingPaceSuggestion = getTeachingPaceSuggestion;
//# sourceMappingURL=monitoring.controller.js.map