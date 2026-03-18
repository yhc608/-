import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import * as geopoliticsController from '../controllers/geopolitics.controller';

const router = Router();

// ========== 热点相关 ==========
// 获取热点列表（支持分页、筛选）
router.get('/hotspots', geopoliticsController.getHotspots);

// 获取热点详情
router.get('/hotspots/:id', geopoliticsController.getHotspotDetail);

// 获取热点时间轴
router.get('/hotspots/timeline', geopoliticsController.getHotspotsTimeline);

// 热点地图点位数据
router.get('/hotspots/map-data', geopoliticsController.getHotspotsMapData);

// ========== 标签相关 ==========
// 获取所有标签
router.get('/tags', geopoliticsController.getTags);

// 按标签筛选热点
router.get('/tags/:tagId/hotspots', geopoliticsController.getHotspotsByTag);

// ========== 知识点关联 ==========
// 获取热点关联的知识点
router.get('/hotspots/:id/knowledge', geopoliticsController.getHotspotKnowledge);

// ========== 思维训练 ==========
// 获取热点相关问题
router.get('/hotspots/:id/questions', geopoliticsController.getHotspotQuestions);

// 提交答案（需要登录）
router.post('/questions/:id/answer', authenticate, geopoliticsController.submitAnswer);

// 获取答题记录
router.get('/my-answers', authenticate, geopoliticsController.getMyAnswers);

// 获取答题反馈
router.get('/answers/:id/feedback', authenticate, geopoliticsController.getAnswerFeedback);

// ========== 互动功能（需要登录）==========
// 收藏热点
router.post('/hotspots/:id/favorite', authenticate, geopoliticsController.addFavorite);

// 取消收藏
router.delete('/hotspots/:id/favorite', authenticate, geopoliticsController.removeFavorite);

// 获取我的收藏
router.get('/my-favorites', authenticate, geopoliticsController.getMyFavorites);

// 评论热点
router.post('/hotspots/:id/comments', authenticate, geopoliticsController.addComment);

// 获取评论列表
router.get('/hotspots/:id/comments', geopoliticsController.getComments);

// 点赞热点
router.post('/hotspots/:id/like', authenticate, geopoliticsController.likeHotspot);

// ========== 学习轨迹 ==========
// 记录学习轨迹
router.post('/hotspots/:id/learning-path', authenticate, geopoliticsController.recordLearningPath);

// 获取学习进度
router.get('/my-learning-progress', authenticate, geopoliticsController.getMyLearningProgress);

export default router;
