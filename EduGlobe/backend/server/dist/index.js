"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.io = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const compression_1 = __importDefault(require("compression"));
const dotenv_1 = __importDefault(require("dotenv"));
const http_1 = require("http");
const socket_io_1 = require("socket.io");
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const logger_1 = require("./utils/logger");
const errorHandler_1 = require("./middleware/errorHandler");
const requestLogger_1 = require("./middleware/requestLogger");
const connection_1 = require("./database/connection");
// 路由导入
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const student_routes_1 = __importDefault(require("./routes/student.routes"));
const teacher_routes_1 = __importDefault(require("./routes/teacher.routes"));
const course_routes_1 = __importDefault(require("./routes/course.routes"));
const knowledge_routes_1 = __importDefault(require("./routes/knowledge.routes"));
const assignment_routes_1 = __importDefault(require("./routes/assignment.routes"));
const qa_routes_1 = __importDefault(require("./routes/qa.routes"));
const experiment_routes_1 = __importDefault(require("./routes/experiment.routes"));
const channel_routes_1 = __importDefault(require("./routes/channel.routes"));
const resource_routes_1 = __importDefault(require("./routes/resource.routes"));
const report_routes_1 = __importDefault(require("./routes/report.routes"));
// 加载环境变量
dotenv_1.default.config();
const app = (0, express_1.default)();
const httpServer = (0, http_1.createServer)(app);
const io = new socket_io_1.Server(httpServer, {
    cors: {
        origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
        methods: ['GET', 'POST'],
    },
});
exports.io = io;
const PORT = process.env.PORT || 3000;
// 限流配置
const limiter = (0, express_rate_limit_1.default)({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '15') * 60 * 1000,
    max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
    message: '请求过于频繁，请稍后再试',
});
// 中间件
app.use((0, helmet_1.default)());
app.use((0, compression_1.default)());
app.use((0, cors_1.default)({
    origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
    credentials: true,
}));
app.use(express_1.default.json({ limit: '50mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '50mb' }));
app.use(requestLogger_1.requestLogger);
app.use('/api/', limiter);
// 静态文件服务
app.use('/uploads', express_1.default.static('uploads'));
// 健康检查
app.get('/health', (_req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
    });
});
// API路由
app.use('/api/auth', auth_routes_1.default);
app.use('/api/student', student_routes_1.default);
app.use('/api/teacher', teacher_routes_1.default);
app.use('/api/courses', course_routes_1.default);
app.use('/api/knowledge', knowledge_routes_1.default);
app.use('/api/assignments', assignment_routes_1.default);
app.use('/api/qa', qa_routes_1.default);
app.use('/api/experiments', experiment_routes_1.default);
app.use('/api/channels', channel_routes_1.default);
app.use('/api/resources', resource_routes_1.default);
app.use('/api/reports', report_routes_1.default);
// WebSocket 连接处理
io.on('connection', (socket) => {
    logger_1.logger.info(`客户端连接: ${socket.id}`);
    // 加入课堂
    socket.on('join-classroom', (courseId) => {
        socket.join(`classroom-${courseId}`);
        logger_1.logger.info(`用户 ${socket.id} 加入课堂 ${courseId}`);
    });
    // 课堂互动
    socket.on('classroom-interaction', (data) => {
        io.to(`classroom-${data.courseId}`).emit('interaction-update', data);
    });
    // 实时答疑
    socket.on('ask-question', (data) => {
        // 这里可以调用AI服务处理问题
        socket.emit('answer-received', {
            questionId: data.questionId,
            answer: '正在处理您的问题...',
        });
    });
    socket.on('disconnect', () => {
        logger_1.logger.info(`客户端断开: ${socket.id}`);
    });
});
// 错误处理中间件（必须放在最后）
app.use(errorHandler_1.errorHandler);
// 404处理
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: '请求的资源不存在',
        path: req.path,
    });
});
// 启动服务器
async function startServer() {
    try {
        // 连接数据库
        await (0, connection_1.connectDatabase)();
        logger_1.logger.info('数据库连接成功');
        // 启动HTTP服务器
        httpServer.listen(PORT, () => {
            logger_1.logger.info(`🚀 服务器运行在端口 ${PORT}`);
            logger_1.logger.info(`📚 环境: ${process.env.NODE_ENV || 'development'}`);
            logger_1.logger.info(`🌐 API地址: http://localhost:${PORT}/api`);
        });
    }
    catch (error) {
        logger_1.logger.error('服务器启动失败:', error);
        process.exit(1);
    }
}
// 优雅关闭
process.on('SIGTERM', () => {
    logger_1.logger.info('收到SIGTERM信号，正在关闭服务器...');
    httpServer.close(() => {
        logger_1.logger.info('服务器已关闭');
        process.exit(0);
    });
});
process.on('SIGINT', () => {
    logger_1.logger.info('收到SIGINT信号，正在关闭服务器...');
    httpServer.close(() => {
        logger_1.logger.info('服务器已关闭');
        process.exit(0);
    });
});
// 启动
startServer();
//# sourceMappingURL=index.js.map