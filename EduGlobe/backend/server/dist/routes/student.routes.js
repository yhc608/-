"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const preview_controller_1 = require("../controllers/student/preview.controller");
const classroom_controller_1 = require("../controllers/student/classroom.controller");
const qa_controller_1 = require("../controllers/student/qa.controller");
const report_controller_1 = require("../controllers/student/report.controller");
const router = (0, express_1.Router)();
// 所有学生端路由都需要认证和学生角色
router.use(auth_1.authenticate);
router.use((0, auth_1.authorize)('student'));
// ========== 课前预习 ==========
router.get('/preview/knowledge-map', preview_controller_1.getKnowledgeMap);
router.get('/preview/concept-card/:id', preview_controller_1.getConceptCard);
router.get('/preview/test', preview_controller_1.getPreviewTest);
router.post('/preview/test/submit', preview_controller_1.submitPreviewTest);
router.get('/preview/personalized-review', preview_controller_1.getPersonalizedReview);
// ========== 课堂互动 ==========
router.post('/classroom/join', classroom_controller_1.joinClassroom);
router.post('/classroom/question', classroom_controller_1.askQuestion);
router.post('/classroom/interaction', classroom_controller_1.submitInteraction);
router.get('/classroom/:courseId/status', classroom_controller_1.getClassroomStatus);
router.post('/classroom/game/play', classroom_controller_1.playGame);
router.post('/classroom/game/submit', classroom_controller_1.submitGameResult);
// ========== 智能答疑 ==========
router.post('/qa/ask', qa_controller_1.askMultimodalQuestion);
router.get('/qa/history', qa_controller_1.getQAHistory);
router.post('/qa/:qaId/rate', qa_controller_1.rateAnswer);
// ========== 学习报告 ==========
router.get('/report/:type', report_controller_1.getLearningReport);
router.get('/weak-points', report_controller_1.getWeakPoints);
router.get('/ability-radar', report_controller_1.getAbilityRadar);
router.get('/personalized-path', report_controller_1.getPersonalizedPath);
exports.default = router;
//# sourceMappingURL=student.routes.js.map