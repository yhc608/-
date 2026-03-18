import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import * as scenarioController from '../controllers/scenario.controller';

const router = Router();

// 角色库
router.get('/roles', scenarioController.getRoles);
router.get('/roles/:id', scenarioController.getRoleDetail);

// 场景库
router.get('/scenes', scenarioController.getScenes);
router.get('/scenes/:id', scenarioController.getSceneDetail);

// 任务库
router.get('/tasks', scenarioController.getTasks);
router.get('/tasks/:id', scenarioController.getTaskDetail);
router.get('/scenes/:sceneId/tasks', scenarioController.getTasksByScene);

// 用户进度（需要登录）
router.post('/tasks/:id/start', authenticate, scenarioController.startTask);
router.put('/progress/:id/update', authenticate, scenarioController.updateProgress);
router.post('/progress/:id/complete', authenticate, scenarioController.completeTask);
router.get('/my-progress', authenticate, scenarioController.getMyProgress);

// 探索发现
router.post('/discoveries', authenticate, scenarioController.addDiscovery);
router.get('/my-discoveries', authenticate, scenarioController.getMyDiscoveries);

// NPC交互
router.get('/scenes/:sceneId/npcs', scenarioController.getSceneNPCs);
router.post('/npcs/:id/interact', authenticate, scenarioController.interactWithNPC);

// 装备背包
router.get('/equipment', scenarioController.getEquipment);
router.get('/my-inventory', authenticate, scenarioController.getMyInventory);
router.post('/equipment/:id/acquire', authenticate, scenarioController.acquireEquipment);

export default router;
