"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const lesson_controller_1 = require("../controllers/teacher/lesson.controller");
const monitoring_controller_1 = require("../controllers/teacher/monitoring.controller");
const grading_controller_1 = require("../controllers/teacher/grading.controller");
const dashboard_controller_1 = require("../controllers/teacher/dashboard.controller");
const router = (0, express_1.Router)();
// 所有教师端路由都需要认证和教师角色
router.use(auth_1.authenticate);
router.use((0, auth_1.authorize)('teacher'));
// ========== 智能备课 ==========
router.post('/lesson/generate', lesson_controller_1.generateLessonPlan);
router.post('/lesson/save', lesson_controller_1.saveLessonPlan);
router.get('/lesson/list', lesson_controller_1.getLessonPlans);
router.get('/lesson/:id', lesson_controller_1.getLessonPlanDetail);
router.put('/lesson/:id/share', lesson_controller_1.shareLessonPlan);
// ========== 课堂管理 ==========
router.get('/monitoring/classroom/:courseId', monitoring_controller_1.getClassroomMonitoring);
router.get('/monitoring/interaction-stats/:courseId', monitoring_controller_1.getInteractionStats);
router.get('/monitoring/hot-questions/:courseId', monitoring_controller_1.getHotQuestions);
router.get('/monitoring/teaching-pace/:courseId', monitoring_controller_1.getTeachingPaceSuggestion);
// ========== 作业批改 ==========
router.get('/grading/assignments', grading_controller_1.getAssignmentsToGrade);
router.post('/grading/assignment/:submissionId', grading_controller_1.gradeAssignment);
router.post('/grading/batch', grading_controller_1.batchGrade);
router.post('/grading/recognize-map', grading_controller_1.recognizeHandDrawnMap);
// ========== 数据后台 ==========
router.get('/dashboard/:classId', dashboard_controller_1.getTeachingDashboard);
router.get('/dashboard/class-situation/:classId', dashboard_controller_1.getClassSituation);
router.get('/dashboard/student-analysis/:studentId', dashboard_controller_1.getStudentAnalysis);
router.get('/dashboard/export/:classId', dashboard_controller_1.exportTeachingData);
exports.default = router;
//# sourceMappingURL=teacher.routes.js.map