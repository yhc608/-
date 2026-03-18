import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/error.middleware';
import { query } from '../config/database';

// 简化实现，核心功能占位
export const getRoles = asyncHandler(async (req: Request, res: Response) => {
  const roles = await query('SELECT * FROM scenario_roles WHERE is_locked = FALSE');
  res.json({ success: true, data: roles });
});

export const getRoleDetail = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const [role] = await query('SELECT * FROM scenario_roles WHERE id = ?', [id]);
  res.json({ success: true, data: role });
});

export const getScenes = asyncHandler(async (req: Request, res: Response) => {
  const scenes = await query('SELECT * FROM scenario_scenes ORDER BY id');
  res.json({ success: true, data: scenes });
});

export const getSceneDetail = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const [scene] = await query('SELECT * FROM scenario_scenes WHERE id = ?', [id]);
  res.json({ success: true, data: scene });
});

export const getTasks = asyncHandler(async (req: Request, res: Response) => {
  const tasks = await query('SELECT * FROM scenario_tasks ORDER BY id');
  res.json({ success: true, data: tasks });
});

export const getTaskDetail = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const [task] = await query('SELECT * FROM scenario_tasks WHERE id = ?', [id]);
  res.json({ success: true, data: task });
});

export const getTasksByScene = asyncHandler(async (req: Request, res: Response) => {
  const { sceneId } = req.params;
  const tasks = await query('SELECT * FROM scenario_tasks WHERE scene_id = ?', [sceneId]);
  res.json({ success: true, data: tasks });
});

export const startTask = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  const userId = req.userId;
  await query(
    'INSERT INTO scenario_user_progress (user_id, task_id, status) VALUES (?, ?, "ongoing")',
    [userId, id]
  );
  res.json({ success: true, message: '任务已开始' });
});

export const updateProgress = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  const { progressData, decisionsData, collectedItems } = req.body;
  await query(
    `UPDATE scenario_user_progress SET 
     progress_data = ?, decisions_made = ?, collected_items = ? 
     WHERE id = ? AND user_id = ?`,
    [JSON.stringify(progressData), JSON.stringify(decisionsData), JSON.stringify(collectedItems), id, req.userId]
  );
  res.json({ success: true, message: '进度已保存' });
});

export const completeTask = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  await query(
    'UPDATE scenario_user_progress SET status = "completed", end_time = NOW() WHERE id = ? AND user_id = ?',
    [id, req.userId]
  );
  res.json({ success: true, message: '任务已完成' });
});

export const getMyProgress = asyncHandler(async (req: any, res: Response) => {
  const progress = await query(
    `SELECT p.*, t.title FROM scenario_user_progress p 
     JOIN scenario_tasks t ON p.task_id = t.id 
     WHERE p.user_id = ? ORDER BY p.start_time DESC`,
    [req.userId]
  );
  res.json({ success: true, data: progress });
});

export const addDiscovery = asyncHandler(async (req: any, res: Response) => {
  const { sceneId, discoveryType, name, description, position } = req.body;
  await query(
    `INSERT INTO scenario_discoveries 
     (user_id, scene_id, discovery_type, name, description, position) 
     VALUES (?, ?, ?, ?, ?, ?)`,
    [req.userId, sceneId, discoveryType, name, description, JSON.stringify(position)]
  );
  res.json({ success: true, message: '发现已记录' });
});

export const getMyDiscoveries = asyncHandler(async (req: any, res: Response) => {
  const discoveries = await query(
    'SELECT * FROM scenario_discoveries WHERE user_id = ? ORDER BY discovered_at DESC',
    [req.userId]
  );
  res.json({ success: true, data: discoveries });
});

export const getSceneNPCs = asyncHandler(async (req: Request, res: Response) => {
  const { sceneId } = req.params;
  const npcs = await query(
    'SELECT * FROM scenario_npcs WHERE scene_id = ? AND is_active = TRUE',
    [sceneId]
  );
  res.json({ success: true, data: npcs });
});

export const interactWithNPC = asyncHandler(async (req: any, res: Response) => {
  // NPC交互逻辑（简化）
  res.json({ success: true, message: 'NPC交互成功' });
});

export const getEquipment = asyncHandler(async (req: Request, res: Response) => {
  const equipment = await query('SELECT * FROM scenario_role_equipment ORDER BY rarity, category');
  res.json({ success: true, data: equipment });
});

export const getMyInventory = asyncHandler(async (req: any, res: Response) => {
  const inventory = await query(
    `SELECT i.*, e.name, e.icon, e.category FROM scenario_user_inventory i 
     JOIN scenario_role_equipment e ON i.equipment_id = e.id 
     WHERE i.user_id = ?`,
    [req.userId]
  );
  res.json({ success: true, data: inventory });
});

export const acquireEquipment = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  const { roleId } = req.body;
  await query(
    'INSERT INTO scenario_user_inventory (user_id, role_id, equipment_id) VALUES (?, ?, ?)',
    [req.userId, roleId, id]
  );
  res.json({ success: true, message: '装备已获得' });
});
