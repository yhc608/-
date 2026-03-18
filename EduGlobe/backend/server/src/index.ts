import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';
import path from 'path';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';

// 导入路由
import geopoliticsRoutes from './routes/geopolitics.routes';
import cyberLabRoutes from './routes/cyberlab.routes';
import scenarioRoutes from './routes/scenario.routes';
import aiCompanionRoutes from './routes/ai-companion.routes';
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';

// 导入中间件
import { errorHandler } from './middleware/error.middleware';
import { requestLogger } from './middleware/logger.middleware';
import { rateLimiter } from './middleware/rate-limit.middleware';

// 加载环境变量
dotenv.config();

const app: Application = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:5173',
    methods: ['GET', 'POST'],
  },
});

// 基础中间件
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(requestLogger);

// 静态文件服务
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// API 路由
app.use('/api/auth', rateLimiter, authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/geopolitics', geopoliticsRoutes);
app.use('/api/cyberlab', cyberLabRoutes);
app.use('/api/scenario', scenarioRoutes);
app.use('/api/ai-companion', aiCompanionRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// WebSocket 连接处理
io.on('connection', (socket) => {
  console.log(`用户已连接: ${socket.id}`);

  // 实验室协作
  socket.on('join_lab_room', (roomCode: string) => {
    socket.join(`lab_${roomCode}`);
    console.log(`用户 ${socket.id} 加入实验室 ${roomCode}`);
  });

  socket.on('lab_sync_data', (data) => {
    const roomCode = data.roomCode;
    socket.to(`lab_${roomCode}`).emit('lab_data_update', data);
  });

  // 情景互动位置同步
  socket.on('join_scenario', (scenarioId: number) => {
    socket.join(`scenario_${scenarioId}`);
  });

  socket.on('update_position', (data) => {
    const scenarioId = data.scenarioId;
    socket.to(`scenario_${scenarioId}`).emit('player_position', {
      userId: data.userId,
      position: data.position,
    });
  });

  // AI 对话流式响应
  socket.on('ai_chat_stream', async (data) => {
    // 这里后续集成流式响应
    socket.emit('ai_response_chunk', { chunk: '处理中...' });
  });

  socket.on('disconnect', () => {
    console.log(`用户已断开: ${socket.id}`);
  });
});

// 错误处理中间件（必须放在最后）
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

httpServer.listen(PORT, () => {
  console.log(`========================================`);
  console.log(`🚀 EduGlobe 服务器启动成功！`);
  console.log(`📍 服务地址: http://localhost:${PORT}`);
  console.log(`🌐 API 文档: http://localhost:${PORT}/api-docs`);
  console.log(`⚡ WebSocket: ws://localhost:${PORT}`);
  console.log(`========================================`);
});

export { app, io };
