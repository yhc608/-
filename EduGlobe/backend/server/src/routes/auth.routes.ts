import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { asyncHandler, AppError } from '../middleware/error.middleware';
import { query, queryOne, insert } from '../config/database';
import { authRateLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

// 注册
router.post('/register', authRateLimiter, asyncHandler(async (req, res) => {
  const { username, password, email, role = 'student' } = req.body;

  if (!username || !password) {
    throw new AppError('用户名和密码不能为空', 400);
  }

  // 检查用户是否存在
  const existing = await queryOne(
    'SELECT id FROM users WHERE username = ? OR email = ?',
    [username, email]
  );

  if (existing) {
    throw new AppError('用户名或邮箱已存在', 400);
  }

  // 密码加密
  const passwordHash = await bcrypt.hash(password, 10);

  // 创建用户
  const userId = await insert(
    'INSERT INTO users (username, password_hash, email, role) VALUES (?, ?, ?, ?)',
    [username, passwordHash, email, role]
  );

  // 初始化用户等级
  await insert(
    'INSERT INTO user_levels (user_id) VALUES (?)',
    [userId]
  );

  res.json({
    success: true,
    message: '注册成功',
    data: { userId },
  });
}));

// 登录
router.post('/login', authRateLimiter, asyncHandler(async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    throw new AppError('用户名和密码不能为空', 400);
  }

  // 查询用户
  const user = await queryOne<any>(
    'SELECT * FROM users WHERE username = ? AND status = "active"',
    [username]
  );

  if (!user) {
    throw new AppError('用户名或密码错误', 401);
  }

  // 验证密码
  const isValidPassword = await bcrypt.compare(password, user.password_hash);

  if (!isValidPassword) {
    throw new AppError('用户名或密码错误', 401);
  }

  // 生成 JWT
  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET || 'eduglobe_secret_key',
    { expiresIn: '7d' }
  );

  // 更新最后登录时间
  await query('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);

  res.json({
    success: true,
    message: '登录成功',
    data: {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        avatar: user.avatar_url,
      },
    },
  });
}));

export default router;
