"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.recognizeHandDrawnMap = exports.batchGrade = exports.gradeAssignment = exports.getAssignmentsToGrade = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 获取待批改作业
const getAssignmentsToGrade = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { status = 'submitted', classId } = req.query;
        let sql = `
      SELECT 
        asub.id as submission_id,
        asub.submit_time,
        asub.answers,
        asub.attachments,
        asub.status,
        a.id as assignment_id,
        a.title,
        a.total_score,
        u.id as student_id,
        u.real_name as student_name,
        c.name as class_name
      FROM assignment_submissions asub
      JOIN assignments a ON asub.assignment_id = a.id
      JOIN users u ON asub.student_id = u.id
      JOIN classes c ON a.class_id = c.id
      WHERE a.teacher_id = ? AND asub.status = ?
    `;
        const params = [teacherId, status];
        if (classId) {
            sql += ' AND c.id = ?';
            params.push(classId);
        }
        sql += ' ORDER BY asub.submit_time ASC';
        const submissions = await (0, connection_1.query)(sql, params);
        res.json({
            success: true,
            data: {
                submissions,
                total: submissions.length,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getAssignmentsToGrade = getAssignmentsToGrade;
// 批改作业
const gradeAssignment = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { submissionId } = req.params;
        const { score, detailedScores, comments, duration } = req.body;
        // 验证权限
        const submissions = await (0, connection_1.query)(`SELECT asub.*, a.teacher_id
       FROM assignment_submissions asub
       JOIN assignments a ON asub.assignment_id = a.id
       WHERE asub.id = ?`, [submissionId]);
        if (submissions.length === 0) {
            throw new errorHandler_1.AppError('作业提交不存在', 404);
        }
        if (submissions[0].teacher_id !== teacherId) {
            throw new errorHandler_1.AppError('无权批改此作业', 403);
        }
        // 更新批改结果
        await (0, connection_1.query)(`UPDATE assignment_submissions 
       SET teacher_score = ?, score = ?, feedback = ?, status = 'graded'
       WHERE id = ?`, [score, score, comments, submissionId]);
        // 记录批改
        await (0, connection_1.query)(`INSERT INTO grading_records 
       (submission_id, teacher_id, score, detailed_scores, comments, 
        grading_duration_seconds, grading_time)
       VALUES (?, ?, ?, ?, ?, ?, NOW())`, [submissionId, teacherId, score, JSON.stringify(detailedScores), comments, duration]);
        res.json({
            success: true,
            message: '批改完成',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.gradeAssignment = gradeAssignment;
// 批量批改
const batchGrade = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { gradings } = req.body; // [{submissionId, score, comments}, ...]
        if (!Array.isArray(gradings) || gradings.length === 0) {
            throw new errorHandler_1.AppError('批改数据不能为空', 400);
        }
        await (0, connection_1.transaction)(async (connection) => {
            for (const grading of gradings) {
                await connection.execute(`UPDATE assignment_submissions 
           SET teacher_score = ?, score = ?, feedback = ?, status = 'graded'
           WHERE id = ?`, [grading.score, grading.score, grading.comments, grading.submissionId]);
                await connection.execute(`INSERT INTO grading_records 
           (submission_id, teacher_id, score, comments, grading_time)
           VALUES (?, ?, ?, ?, NOW())`, [grading.submissionId, teacherId, grading.score, grading.comments]);
            }
        });
        res.json({
            success: true,
            message: `已批改 ${gradings.length} 份作业`,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.batchGrade = batchGrade;
// 识别手绘地图
const recognizeHandDrawnMap = async (req, res, next) => {
    try {
        const { submissionId, imageUrl, mapType } = req.body;
        if (!imageUrl || !mapType) {
            throw new errorHandler_1.AppError('图片URL和地图类型为必填项', 400);
        }
        // 调用图像识别服务（模拟）
        const recognitionResult = {
            map_type: mapType,
            detected_elements: {
                contour_lines: mapType === 'contour' ? ['等高线绘制准确', '间距合理'] : null,
                labels: ['标注完整', '位置准确'],
                legend: ['图例清晰'],
            },
            accuracy_score: 0.85,
            element_scores: {
                accuracy: 85,
                completeness: 90,
                neatness: 80,
            },
            suggestions: [
                '等高线间距可以更均匀',
                '标注字迹可以更清晰',
            ],
        };
        // 保存识别结果
        await (0, connection_1.query)(`INSERT INTO map_recognitions 
       (submission_id, image_url, map_type, recognition_result, 
        accuracy_score, element_scores, suggestions, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`, [
            submissionId,
            imageUrl,
            mapType,
            JSON.stringify(recognitionResult),
            recognitionResult.accuracy_score,
            JSON.stringify(recognitionResult.element_scores),
            JSON.stringify(recognitionResult.suggestions),
        ]);
        res.json({
            success: true,
            data: recognitionResult,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.recognizeHandDrawnMap = recognizeHandDrawnMap;
//# sourceMappingURL=grading.controller.js.map