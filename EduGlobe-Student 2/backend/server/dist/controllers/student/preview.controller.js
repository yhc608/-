"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPersonalizedReview = exports.submitPreviewTest = exports.getPreviewTest = exports.getConceptCard = exports.getKnowledgeMap = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 获取知识图谱
const getKnowledgeMap = async (req, res, next) => {
    try {
        const { chapter, textbook_version } = req.query;
        let sql = `
      SELECT kn.*, 
             JSON_ARRAYAGG(
               JSON_OBJECT(
                 'target_id', kr.target_node_id,
                 'relation_type', kr.relation_type,
                 'strength', kr.strength
               )
             ) as relations
      FROM knowledge_nodes kn
      LEFT JOIN knowledge_relations kr ON kn.id = kr.source_node_id
      WHERE 1=1
    `;
        const params = [];
        if (chapter) {
            sql += ' AND kn.chapter = ?';
            params.push(chapter);
        }
        if (textbook_version) {
            sql += ' AND kn.textbook_version = ?';
            params.push(textbook_version);
        }
        sql += ' GROUP BY kn.id ORDER BY kn.textbook_page';
        const nodes = await (0, connection_1.query)(sql, params);
        res.json({
            success: true,
            data: {
                nodes,
                total: nodes.length,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getKnowledgeMap = getKnowledgeMap;
// 获取概念卡片
const getConceptCard = async (req, res, next) => {
    try {
        const { id } = req.params;
        const cards = await (0, connection_1.query)(`SELECT cc.*, kn.name as knowledge_name, kn.three_dimension_analysis, 
              kn.common_mistakes, kn.extension_resources
       FROM concept_cards cc
       JOIN knowledge_nodes kn ON cc.knowledge_node_id = kn.id
       WHERE cc.id = ?`, [id]);
        if (cards.length === 0) {
            throw new errorHandler_1.AppError('概念卡片不存在', 404);
        }
        res.json({
            success: true,
            data: cards[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getConceptCard = getConceptCard;
// 获取预习检测
const getPreviewTest = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { knowledge_nodes, difficulty } = req.query;
        // 这里应该调用AI服务生成题目
        // 简化版：从题库随机选择
        const knowledgeNodeIds = knowledge_nodes
            ? JSON.parse(knowledge_nodes)
            : [];
        // 模拟生成题目
        const questions = {
            test_id: Date.now(),
            questions: [
                {
                    id: 1,
                    type: 'choice',
                    content: '示例选择题',
                    options: ['A', 'B', 'C', 'D'],
                    knowledge_node_id: knowledgeNodeIds[0] || 1,
                },
            ],
            total_score: 100,
            time_limit: 1800, // 30分钟
        };
        res.json({
            success: true,
            data: questions,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getPreviewTest = getPreviewTest;
// 提交预习检测
const submitPreviewTest = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        const { test_id, answers, duration } = req.body;
        // 创建作业记录
        const assignmentResult = await (0, connection_1.query)(`INSERT INTO assignments (class_id, teacher_id, title, assignment_type, questions, total_score)
       SELECT cs.class_id, c.teacher_id, '预习检测', 'preview', ?, 100
       FROM class_students cs
       JOIN classes c ON cs.class_id = c.id
       WHERE cs.student_id = ?
       LIMIT 1`, [JSON.stringify(answers), studentId]);
        const assignmentId = assignmentResult.insertId;
        // 创建提交记录
        await (0, connection_1.query)(`INSERT INTO assignment_submissions 
       (assignment_id, student_id, answers, submit_time, duration_seconds, status)
       VALUES (?, ?, ?, NOW(), ?, 'submitted')`, [assignmentId, studentId, JSON.stringify(answers), duration]);
        // AI评分和诊断（简化版）
        const score = Math.floor(Math.random() * 30) + 70; // 70-100分
        const diagnosticReport = {
            score,
            weak_points: ['地形特征', '气候类型'],
            strong_points: ['地理位置', '河流水系'],
            suggestions: ['加强对地形特征的理解', '多做气候类型的对比练习'],
        };
        // 更新分数
        await (0, connection_1.query)('UPDATE assignment_submissions SET score = ?, ai_comment = ? WHERE assignment_id = ? AND student_id = ?', [score, JSON.stringify(diagnosticReport), assignmentId, studentId]);
        res.json({
            success: true,
            message: '提交成功',
            data: {
                score,
                diagnostic_report: diagnosticReport,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.submitPreviewTest = submitPreviewTest;
// 获取个性化复习包
const getPersonalizedReview = async (req, res, next) => {
    try {
        const studentId = req.user?.id;
        // 获取错题和薄弱知识点
        const errorQuestions = await (0, connection_1.query)(`SELECT eq.*, kn.name as knowledge_name
       FROM error_questions eq
       JOIN knowledge_nodes kn ON eq.knowledge_node_id = kn.id
       WHERE eq.student_id = ? AND eq.mastery_level < 4
       ORDER BY eq.created_at DESC
       LIMIT 20`, [studentId]);
        // 获取推荐资源
        const resources = await (0, connection_1.query)(`SELECT DISTINCT tr.*
       FROM teaching_resources tr
       WHERE JSON_CONTAINS(tr.knowledge_nodes, ?)
       LIMIT 10`, [JSON.stringify(errorQuestions.map((eq) => eq.knowledge_node_id))]);
        res.json({
            success: true,
            data: {
                error_questions: errorQuestions,
                recommended_resources: resources,
                review_plan: '建议每天复习30分钟，重点关注薄弱知识点',
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getPersonalizedReview = getPersonalizedReview;
//# sourceMappingURL=preview.controller.js.map