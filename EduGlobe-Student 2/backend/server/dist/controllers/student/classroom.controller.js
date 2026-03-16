"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitGameResult = exports.playGame = exports.getClassroomStatus = exports.submitInteraction = exports.askQuestion = exports.joinClassroom = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
const index_1 = require("../../index");
// 加入课堂
const joinClassroom = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { courseId } = req.body;
        // 验证学生是否属于该课程的班级
        const courses = await (0, connection_1.query)(`SELECT c.* FROM courses c
       JOIN classes cls ON c.class_id = cls.id
       JOIN class_students cs ON cls.id = cs.class_id
       WHERE c.id = ? AND cs.student_id = ?`, [courseId, studentId]);
        if (courses.length === 0) {
            throw new errorHandler_1.AppError('无权访问该课堂', 403);
        }
        // 记录学生进入课堂
        await (0, connection_1.query)(`INSERT INTO classroom_interactions 
       (course_id, student_id, interaction_type, content, created_at)
       VALUES (?, ?, 'join', '学生进入课堂', NOW())`, [courseId, studentId]);
        // 获取虚拟角色
        const characters = await (0, connection_1.query)('SELECT * FROM virtual_characters ORDER BY RAND() LIMIT 1');
        res.json({
            success: true,
            message: '成功加入课堂',
            data: {
                course: courses[0],
                virtual_character: characters[0],
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.joinClassroom = joinClassroom;
// 提问
const askQuestion = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { courseId, question, questionType = 'text' } = req.body;
        // 记录提问
        const result = await (0, connection_1.query)(`INSERT INTO classroom_interactions 
       (course_id, student_id, interaction_type, content, created_at)
       VALUES (?, ?, 'question', ?, NOW())`, [courseId, studentId, question]);
        const interactionId = result.insertId;
        // 模拟AI回答（实际应调用AI服务）
        const aiAnswer = `关于"${question}"的回答：这是一个很好的问题...`;
        const responseTime = Math.floor(Math.random() * 2000) + 500;
        // 更新AI回答
        await (0, connection_1.query)(`UPDATE classroom_interactions 
       SET ai_response = ?, response_time_ms = ?
       WHERE id = ?`, [aiAnswer, responseTime, interactionId]);
        // 通过WebSocket广播到课堂
        index_1.io.to(`classroom-${courseId}`).emit('new-question', {
            student: req.user?.real_name || req.user?.username,
            question,
            answer: aiAnswer,
        });
        res.json({
            success: true,
            data: {
                interaction_id: interactionId,
                answer: aiAnswer,
                response_time_ms: responseTime,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.askQuestion = askQuestion;
// 提交互动记录
const submitInteraction = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { courseId, interactionType, content, isCorrect, attentionLevel, emotion, } = req.body;
        await (0, connection_1.query)(`INSERT INTO classroom_interactions 
       (course_id, student_id, interaction_type, content, is_correct, 
        attention_level, emotion, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`, [courseId, studentId, interactionType, content, isCorrect, attentionLevel, emotion]);
        res.json({
            success: true,
            message: '互动记录已提交',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.submitInteraction = submitInteraction;
// 获取课堂状态
const getClassroomStatus = async (req, res, next) => {
    try {
        const { courseId } = req.params;
        const studentId = req.user?.id;
        // 获取课堂互动统计
        const stats = await (0, connection_1.query)(`SELECT 
         COUNT(*) as total_interactions,
         AVG(attention_level) as avg_attention,
         SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
         COUNT(CASE WHEN interaction_type = 'question' THEN 1 END) as question_count
       FROM classroom_interactions
       WHERE course_id = ? AND student_id = ?`, [courseId, studentId]);
        // 获取知识点盲区提醒
        const blindSpots = await (0, connection_1.query)(`SELECT kn.name, COUNT(*) as wrong_count
       FROM classroom_interactions ci
       JOIN knowledge_nodes kn ON JSON_CONTAINS(ci.content, CAST(kn.id AS CHAR))
       WHERE ci.course_id = ? AND ci.student_id = ? AND ci.is_correct = 0
       GROUP BY kn.id
       ORDER BY wrong_count DESC
       LIMIT 5`, [courseId, studentId]);
        res.json({
            success: true,
            data: {
                stats: stats[0],
                blind_spots: blindSpots,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getClassroomStatus = getClassroomStatus;
// 开始游戏
const playGame = async (req, res, next) => {
    try {
        const { gameId, courseId } = req.body;
        const games = await (0, connection_1.query)('SELECT * FROM geography_games WHERE id = ?', [gameId]);
        if (games.length === 0) {
            throw new errorHandler_1.AppError('游戏不存在', 404);
        }
        res.json({
            success: true,
            data: games[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.playGame = playGame;
// 提交游戏结果
const submitGameResult = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { gameId, courseId, score, correctCount, totalCount, durationSeconds, gameData, } = req.body;
        await (0, connection_1.query)(`INSERT INTO game_records 
       (game_id, course_id, student_id, score, correct_count, total_count, 
        duration_seconds, game_data, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`, [gameId, courseId, studentId, score, correctCount, totalCount, durationSeconds, JSON.stringify(gameData)]);
        // 记录到课堂互动
        await (0, connection_1.query)(`INSERT INTO classroom_interactions 
       (course_id, student_id, interaction_type, content, score, created_at)
       VALUES (?, ?, 'game', ?, ?, NOW())`, [courseId, studentId, `完成游戏，得分${score}`, score]);
        res.json({
            success: true,
            message: '游戏结果已提交',
            data: {
                score,
                rank: '前20%', // 可以根据实际数据计算排名
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.submitGameResult = submitGameResult;
//# sourceMappingURL=classroom.controller.js.map