import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import * as cyberLabController from '../controllers/cyberlab.controller';

const router = Router();

// ========== 实验模板 ==========
// 获取实验列表
router.get('/templates', cyberLabController.getTemplates);

// 获取实验详情
router.get('/temples/:id', cyberLabController.getTemplateDetail);

// 按分类获取实验
router.get('/categories/:category/templates', cyberLabController.getTemplatesByCategory);

// 获取热门实验
router.get('/templates/popular', cyberLabController.getPopularTemplates);

// ========== 实验执行（需要登录）==========
// 开始实验
router.post('/experiments/start', authenticate, cyberLabController.startExperiment);

// 保存实验数据
router.put('/experiments/:id/save', authenticate, cyberLabController.saveExperimentData);

// 提交实验报告
router.post('/experiments/:id/submit', authenticate, cyberLabController.submitExperiment);

// 获取我的实验记录
router.get('/my-experiments', authenticate, cyberLabController.getMyExperiments);

// 获取实验详情
router.get('/experiments/:id', authenticate, cyberLabController.getExperimentDetail);

// 删除实验记录
router.delete('/experiments/:id', authenticate, cyberLabController.deleteExperiment);

// ========== 数据快照 ==========
// 记录数据快照
router.post('/experiments/:id/snapshots', authenticate, cyberLabController.saveDataSnapshot);

// 获取数据快照
router.get('/experiments/:id/snapshots', authenticate, cyberLabController.getDataSnapshots);

// ========== 实验评价 ==========
// 提交评价
router.post('/templates/:id/review', authenticate, cyberLabController.addReview);

// 获取评价列表
router.get('/templates/:id/reviews', cyberLabController.getReviews);

// ========== 协作实验 ==========
// 创建协作房间
router.post('/collaborations/create', authenticate, cyberLabController.createCollaboration);

// 加入协作房间
router.post('/collaborations/:roomCode/join', authenticate, cyberLabController.joinCollaboration);

// 获取房间信息
router.get('/collaborations/:roomCode', authenticate, cyberLabController.getCollaborationInfo);

// 同步数据（通过WebSocket处理，这里提供REST备份接口）
router.post('/collaborations/:roomCode/sync', authenticate, cyberLabController.syncCollaborationData);

// ========== 实验步骤 ==========
// 获取实验步骤
router.get('/templates/:id/steps', cyberLabController.getExperimentSteps);

// ========== 资源管理 ==========
// 获取实验资源
router.get('/templates/:id/resources', cyberLabController.getExperimentResources);

export default router;
