import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import * as aiController from '../controllers/ai-companion.controller';

const router = Router();

// AI对话
router.post('/chat/start', authenticate, aiController.startChatSession);
router.post('/chat/:sessionId/message', authenticate, aiController.sendMessage);
router.get('/chat/sessions', authenticate, aiController.getMyChatSessions);
router.get('/chat/:sessionId/messages', authenticate, aiController.getMessages);

// 学习计划
router.post('/study-plans', authenticate, aiController.createStudyPlan);
router.get('/study-plans', authenticate, aiController.getMyStudyPlans);
router.get('/study-plans/:id', authenticate, aiController.getStudyPlanDetail);
router.put('/study-plans/:id', authenticate, aiController.updateStudyPlan);

// 每日任务
router.get('/daily-tasks', authenticate, aiController.getDailyTasks);
router.post('/daily-tasks/:id/complete', authenticate, aiController.completeDailyTask);

// 学习分析
router.get('/analytics', authenticate, aiController.getMyAnalytics);
router.get('/analytics/weekly', authenticate, aiController.getWeeklyReport);
router.get('/analytics/knowledge-mastery', authenticate, aiController.getKnowledgeMastery);

// 错题本
router.post('/error-notebook', authenticate, aiController.addErrorQuestion);
router.get('/error-notebook', authenticate, aiController.getMyErrors);
router.put('/error-notebook/:id/master', authenticate, aiController.markAsMastered);

// 学习建议
router.get('/suggestions', authenticate, aiController.getMySuggestions);
router.post('/suggestions/:id/adopt', authenticate, aiController.adoptSuggestion);

// OCR识别
router.post('/ocr/recognize', authenticate, aiController.recognizeImage);

// 智能推荐
router.get('/recommendations/questions', authenticate, aiController.getQuestionRecommendations);
router.get('/recommendations/resources', authenticate, aiController.getResourceRecommendations);

// 学习提醒
router.get('/reminders', authenticate, aiController.getMyReminders);
router.put('/reminders/:id/read', authenticate, aiController.markReminderAsRead);

// 成就系统
router.get('/achievements', authenticate, aiController.getMyAchievements);
router.get('/achievements/all', aiController.getAllAchievements);

export default router;
