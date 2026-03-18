import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler, AppError } from '../middleware/error.middleware';
import { queryOne, query, execute } from '../config/database';

const router = Router();

// 获取当前用户信息
router.get('/me', authenticate, asyncHandler(async (req: any, res) => {
  const userId = req.userId;

  const user = await queryOne(
    `SELECT u.*, l.current_level, l.current_exp, l.total_points, l.title
     FROM users u
     LEFT JOIN user_levels l ON u.id = l.user_id
     WHERE u.id = ?`,
    [userId]
  );

  if (!user) {
    throw new AppError('用户不存在', 404);
  }

  // 移除敏感信息
  delete (user as any).password_hash;

  res.json({
    success: true,
    data: user,
  });
}));

// 更新用户信息
router.put('/me', authenticate, asyncHandler(async (req: any, res) => {
  const userId = req.userId;
  const { real_name, email, phone, avatar_url } = req.body;

  await execute(
    `UPDATE users 
     SET real_name = COALESCE(?, real_name),
         email = COALESCE(?, email),
         phone = COALESCE(?, phone),
         avatar_url = COALESCE(?, avatar_url)
     WHERE id = ?`,
    [real_name, email, phone, avatar_url, userId]
  );

  res.json({
    success: true,
    message: '更新成功',
  });
}));

// 获取用户统计
router.get('/me/stats', authenticate, asyncHandler(async (req: any, res) => {
  const userId = req.userId;

  // 这里可以聚合各个模块的统计数据
  const stats = await queryOne(
    `SELECT 
      (SELECT COUNT(*) FROM geopolitics_favorites WHERE user_id = ?) as favorites_count,
      (SELECT COUNT(*) FROM cyber_lab_records WHERE user_id = ? AND status = 'completed') as experiments_completed,
      (SELECT COUNT(*) FROM scenario_user_progress WHERE user_id = ? AND status = 'completed') as tasks_completed,
      (SELECT SUM(study_duration) FROM ai_study_analytics WHERE user_id = ?) as total_study_time
    `,
    [userId, userId, userId, userId]
  );

  res.json({
    success: true,
    data: stats,
  });
}));

export default router;
