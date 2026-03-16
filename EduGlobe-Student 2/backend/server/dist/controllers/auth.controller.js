"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.changePassword = exports.updateProfile = exports.getCurrentUser = exports.refreshToken = exports.logout = exports.login = exports.register = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const errorHandler_1 = require("../middleware/errorHandler");
const connection_1 = require("../database/connection");
const logger_1 = require("../utils/logger");
// 生成JWT token
const generateToken = (user) => {
    return jsonwebtoken_1.default.sign({
        id: user.id,
        username: user.username,
        role: user.role,
        email: user.email,
    }, (process.env.JWT_SECRET || 'secret'), { expiresIn: (process.env.JWT_EXPIRE || '7d') });
};
// 注册
const register = async (req, res, next) => {
    try {
        const { username, password, email, role, real_name, phone, school_id, grade_level, } = req.body;
        // 验证必填字段
        if (!username || !password || !role) {
            throw new errorHandler_1.AppError('用户名、密码和角色为必填项', 400);
        }
        // 检查用户是否已存在
        const existingUsers = await (0, connection_1.query)('SELECT id FROM users WHERE username = ? OR email = ?', [username, email || null]);
        if (existingUsers.length > 0) {
            throw new errorHandler_1.AppError('用户名或邮箱已存在', 409);
        }
        // 加密密码
        const password_hash = await bcryptjs_1.default.hash(password, 10);
        // 插入用户
        const result = await (0, connection_1.query)(`INSERT INTO users (username, password_hash, email, role, real_name, phone, school_id, grade_level)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, [username, password_hash, email, role, real_name, phone, school_id, grade_level]);
        const userId = result.insertId;
        // 获取新创建的用户
        const users = await (0, connection_1.query)('SELECT id, username, email, role, real_name, avatar_url, school_id, grade_level, created_at FROM users WHERE id = ?', [userId]);
        const user = users[0];
        const token = generateToken(user);
        logger_1.logger.info(`新用户注册: ${username} (${role})`);
        res.status(201).json({
            success: true,
            message: '注册成功',
            data: {
                user,
                token,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.register = register;
// 登录
const login = async (req, res, next) => {
    try {
        const { username, password } = req.body;
        if (!username || !password) {
            throw new errorHandler_1.AppError('用户名和密码为必填项', 400);
        }
        // 查询用户
        const users = await (0, connection_1.query)('SELECT * FROM users WHERE username = ? AND status = ?', [username, 'active']);
        if (users.length === 0) {
            throw new errorHandler_1.AppError('用户名或密码错误', 401);
        }
        const user = users[0];
        // 验证密码
        const isPasswordValid = await bcryptjs_1.default.compare(password, user.password_hash);
        if (!isPasswordValid) {
            throw new errorHandler_1.AppError('用户名或密码错误', 401);
        }
        // 更新最后登录时间
        await (0, connection_1.query)('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);
        // 生成token
        const token = generateToken(user);
        // 移除密码字段
        const { password_hash, ...userWithoutPassword } = user;
        logger_1.logger.info(`用户登录: ${username}`);
        res.json({
            success: true,
            message: '登录成功',
            data: {
                user: userWithoutPassword,
                token,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.login = login;
// 登出
const logout = async (req, res, next) => {
    try {
        // 这里可以将token加入黑名单（需要Redis）
        logger_1.logger.info(`用户登出: ${req.user?.username}`);
        res.json({
            success: true,
            message: '登出成功',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.logout = logout;
// 刷新token
const refreshToken = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            throw new errorHandler_1.AppError('未提供刷新令牌', 400);
        }
        const decoded = jsonwebtoken_1.default.verify(refreshToken, process.env.JWT_SECRET || 'secret');
        // 查询用户
        const users = await (0, connection_1.query)('SELECT id, username, email, role FROM users WHERE id = ? AND status = ?', [decoded.id, 'active']);
        if (users.length === 0) {
            throw new errorHandler_1.AppError('用户不存在或已被禁用', 401);
        }
        const newToken = generateToken(users[0]);
        res.json({
            success: true,
            data: {
                token: newToken,
            },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.refreshToken = refreshToken;
// 获取当前用户信息
const getCurrentUser = async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const users = await (0, connection_1.query)(`SELECT id, username, email, role, real_name, avatar_url, phone, 
              school_id, grade_level, created_at, last_login 
       FROM users WHERE id = ?`, [userId]);
        if (users.length === 0) {
            throw new errorHandler_1.AppError('用户不存在', 404);
        }
        res.json({
            success: true,
            data: users[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getCurrentUser = getCurrentUser;
// 更新个人资料
const updateProfile = async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { real_name, email, phone, avatar_url } = req.body;
        const updates = [];
        const values = [];
        if (real_name) {
            updates.push('real_name = ?');
            values.push(real_name);
        }
        if (email) {
            updates.push('email = ?');
            values.push(email);
        }
        if (phone) {
            updates.push('phone = ?');
            values.push(phone);
        }
        if (avatar_url) {
            updates.push('avatar_url = ?');
            values.push(avatar_url);
        }
        if (updates.length === 0) {
            throw new errorHandler_1.AppError('没有提供更新字段', 400);
        }
        values.push(userId);
        await (0, connection_1.query)(`UPDATE users SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`, values);
        // 获取更新后的用户信息
        const users = await (0, connection_1.query)('SELECT id, username, email, role, real_name, avatar_url, phone FROM users WHERE id = ?', [userId]);
        res.json({
            success: true,
            message: '个人资料更新成功',
            data: users[0],
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updateProfile = updateProfile;
// 修改密码
const changePassword = async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { oldPassword, newPassword } = req.body;
        if (!oldPassword || !newPassword) {
            throw new errorHandler_1.AppError('旧密码和新密码为必填项', 400);
        }
        // 查询用户
        const users = await (0, connection_1.query)('SELECT password_hash FROM users WHERE id = ?', [userId]);
        if (users.length === 0) {
            throw new errorHandler_1.AppError('用户不存在', 404);
        }
        // 验证旧密码
        const isPasswordValid = await bcryptjs_1.default.compare(oldPassword, users[0].password_hash);
        if (!isPasswordValid) {
            throw new errorHandler_1.AppError('旧密码错误', 401);
        }
        // 加密新密码
        const newPasswordHash = await bcryptjs_1.default.hash(newPassword, 10);
        // 更新密码
        await (0, connection_1.query)('UPDATE users SET password_hash = ? WHERE id = ?', [
            newPasswordHash,
            userId,
        ]);
        logger_1.logger.info(`用户修改密码: ${req.user?.username}`);
        res.json({
            success: true,
            message: '密码修改成功',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.changePassword = changePassword;
//# sourceMappingURL=auth.controller.js.map