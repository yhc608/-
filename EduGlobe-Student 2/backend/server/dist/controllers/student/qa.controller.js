"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rateAnswer = exports.getQAHistory = exports.askMultimodalQuestion = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 多模态提问
const askMultimodalQuestion = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { questionText, questionType, mediaUrls, imageType } = req.body;
        // 图像识别（如果是图片提问）
        let recognitionResult = null;
        if (questionType === 'image' && mediaUrls && mediaUrls.length > 0) {
            // 调用图像识别服务（这里是模拟）
            recognitionResult = {
                type: imageType || 'contour',
                recognized_elements: ['等高线', '山峰', '河谷'],
                confidence: 0.92,
            };
        }
        // 识别相关知识点
        const relatedKnowledge = await (0, connection_1.query)(`SELECT id, name FROM knowledge_nodes 
       WHERE name LIKE ? OR description LIKE ?
       LIMIT 5`, [`%${questionText}%`, `%${questionText}%`]);
        // 生成AI回答（模拟）
        const aiAnswer = `根据您的问题"${questionText}"，我的回答是...`;
        const responseTime = Math.floor(Math.random() * 2000) + 500;
        // 保存问答记录
        const result = await (0, connection_1.query)(`INSERT INTO qa_records 
       (student_id, question_type, question_text, question_media, 
        image_recognition, knowledge_nodes, ai_answer, response_time_ms, 
        resolution_status, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'answered', NOW())`, [
            studentId,
            questionType,
            questionText,
            JSON.stringify(mediaUrls || []),
            JSON.stringify(recognitionResult),
            JSON.stringify(relatedKnowledge.map((k) => k.id)),
            aiAnswer,
            responseTime,
        ]);
        const qaId = result.insertId;
        // 获取关联例题
        const relatedExamples = await (0, connection_1.query)(`SELECT * FROM concept_cards 
       WHERE knowledge_node_id IN (?)
       LIMIT 3`, [relatedKnowledge.map((k) => k.id)]);
        res.json({
            success: true,
            data: {
                qa_id: qaId,
                answer: aiAnswer,
                response_time_ms: responseTime,
                image_recognition: recognitionResult,
                related_knowledge: relatedKnowledge,
                related_examples: relatedExamples,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.askMultimodalQuestion = askMultimodalQuestion;
// 获取答疑历史
const getQAHistory = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { page = 1, pageSize = 20, questionType } = req.query;
        let sql = `
      SELECT qa.*, 
             (SELECT COUNT(*) FROM qa_records WHERE student_id = ?) as total
      FROM qa_records qa
      WHERE qa.student_id = ?
    `;
        const params = [studentId, studentId];
        if (questionType) {
            sql += ' AND qa.question_type = ?';
            params.push(questionType);
        }
        sql += ` ORDER BY qa.created_at DESC 
             LIMIT ? OFFSET ?`;
        params.push(parseInt(pageSize));
        params.push((parseInt(page) - 1) * parseInt(pageSize));
        const records = await (0, connection_1.query)(sql, params);
        res.json({
            success: true,
            data: {
                records,
                page: parseInt(page),
                pageSize: parseInt(pageSize),
                total: records.length > 0 ? records[0].total : 0,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getQAHistory = getQAHistory;
// 评价答案
const rateAnswer = async (req, res, next) => {
    try {
        const { qaId } = req.params;
        const { rating, feedback } = req.body;
        if (!rating || rating < 1 || rating > 5) {
            throw new errorHandler_1.AppError('评分必须在1-5之间', 400);
        }
        await (0, connection_1.query)(`UPDATE qa_records 
       SET student_rating = ?, resolution_status = 'satisfied'
       WHERE id = ?`, [rating, qaId]);
        res.json({
            success: true,
            message: '评价已提交',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.rateAnswer = rateAnswer;
//# sourceMappingURL=qa.controller.js.map