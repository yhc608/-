"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.shareLessonPlan = exports.getLessonPlanDetail = exports.getLessonPlans = exports.saveLessonPlan = exports.generateLessonPlan = void 0;
const errorHandler_1 = require("../../middleware/errorHandler");
const connection_1 = require("../../database/connection");
// 生成教案
const generateLessonPlan = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { title, grade, textbookVersion, chapter, section, duration = 45, crossSubject = false, } = req.body;
        if (!title || !grade || !chapter) {
            throw new errorHandler_1.AppError('标题、年级和章节为必填项', 400);
        }
        // 调用AI生成教案（模拟）
        const generatedPlan = {
            title,
            subject: '地理',
            grade,
            textbook_version: textbookVersion,
            chapter,
            section,
            duration_minutes: duration,
            teaching_objectives: `
1. 知识目标：理解${chapter}的主要概念和原理
2. 能力目标：培养学生的地理思维和实践能力
3. 素养目标：提升学生的地理核心素养
      `.trim(),
            key_points: `
- ${chapter}的核心概念
- 主要原理和规律
- 实际应用场景
      `.trim(),
            difficult_points: `
- 复杂概念的理解
- 理论与实践的结合
      `.trim(),
            teaching_methods: `
- 情境教学法
- 问题引导法
- 小组合作学习
- 多媒体辅助教学
      `.trim(),
            content: `
一、导入（5分钟）
- 虚拟角色引导
- 情境创设

二、新课讲授（25分钟）
1. 概念讲解
2. 案例分析
3. 互动讨论

三、巩固练习（10分钟）
- 地理小游戏
- 即时测验

四、总结提升（5分钟）
- 知识梳理
- 布置作业
      `.trim(),
            resources: {
                videos: ['相关纪录片片段'],
                images: ['地图、图表'],
                animations: ['3D动画演示'],
                games: ['地理小游戏'],
            },
            cross_subject_elements: crossSubject
                ? {
                    subjects: ['历史', '物理'],
                    integration_points: ['地理与历史的关联', '地理与物理的交叉'],
                }
                : null,
        };
        res.json({
            success: true,
            message: 'AI教案生成成功',
            data: generatedPlan,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.generateLessonPlan = generateLessonPlan;
// 保存教案
const saveLessonPlan = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { title, subject, grade, textbookVersion, chapter, section, content, teachingObjectives, keyPoints, difficultPoints, teachingMethods, resources, crossSubjectElements, durationMinutes, isPublic = false, } = req.body;
        const result = await (0, connection_1.query)(`INSERT INTO lesson_plans 
       (teacher_id, title, subject, grade, textbook_version, chapter, section,
        content, teaching_objectives, key_points, difficult_points, 
        teaching_methods, resources, cross_subject_elements, 
        duration_minutes, is_public, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`, [
            teacherId,
            title,
            subject,
            grade,
            textbookVersion,
            chapter,
            section,
            content,
            teachingObjectives,
            keyPoints,
            difficultPoints,
            teachingMethods,
            JSON.stringify(resources),
            JSON.stringify(crossSubjectElements),
            durationMinutes,
            isPublic,
        ]);
        res.json({
            success: true,
            message: '教案保存成功',
            data: {
                id: result.insertId,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.saveLessonPlan = saveLessonPlan;
// 获取教案列表
const getLessonPlans = async (req, res, next) => {
    try {
        const teacherId = req.user?.id;
        const { grade, textbookVersion, chapter, isPublic } = req.query;
        let sql = `
      SELECT lp.*, u.real_name as teacher_name
      FROM lesson_plans lp
      JOIN users u ON lp.teacher_id = u.id
      WHERE (lp.teacher_id = ? OR lp.is_public = 1)
    `;
        const params = [teacherId];
        if (grade) {
            sql += ' AND lp.grade = ?';
            params.push(grade);
        }
        if (textbookVersion) {
            sql += ' AND lp.textbook_version = ?';
            params.push(textbookVersion);
        }
        if (chapter) {
            sql += ' AND lp.chapter = ?';
            params.push(chapter);
        }
        if (isPublic !== undefined) {
            sql += ' AND lp.is_public = ?';
            params.push(isPublic);
        }
        sql += ' ORDER BY lp.created_at DESC';
        const plans = await (0, connection_1.query)(sql, params);
        res.json({
            success: true,
            data: plans,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getLessonPlans = getLessonPlans;
// 获取教案详情
const getLessonPlanDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const teacherId = req.user?.id;
        const plans = await (0, connection_1.query)(`SELECT lp.*, u.real_name as teacher_name, u.school_id
       FROM lesson_plans lp
       JOIN users u ON lp.teacher_id = u.id
       WHERE lp.id = ? AND (lp.teacher_id = ? OR lp.is_public = 1)`, [id, teacherId]);
        if (plans.length === 0) {
            throw new errorHandler_1.AppError('教案不存在或无权访问', 404);
        }
        // 增加浏览次数
        await (0, connection_1.query)('UPDATE lesson_plans SET view_count = view_count + 1 WHERE id = ?', [id]);
        res.json({
            success: true,
            data: plans[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getLessonPlanDetail = getLessonPlanDetail;
// 分享教案
const shareLessonPlan = async (req, res, next) => {
    try {
        const { id } = req.params;
        const teacherId = req.user?.id;
        const { isPublic } = req.body;
        // 验证权限
        const plans = await (0, connection_1.query)('SELECT * FROM lesson_plans WHERE id = ? AND teacher_id = ?', [id, teacherId]);
        if (plans.length === 0) {
            throw new errorHandler_1.AppError('教案不存在或无权操作', 404);
        }
        await (0, connection_1.query)('UPDATE lesson_plans SET is_public = ?, updated_at = NOW() WHERE id = ?', [isPublic ? 1 : 0, id]);
        res.json({
            success: true,
            message: isPublic ? '教案已公开分享' : '教案已设为私密',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.shareLessonPlan = shareLessonPlan;
//# sourceMappingURL=lesson.controller.js.map