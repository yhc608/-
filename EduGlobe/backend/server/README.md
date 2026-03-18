# EduGlobe 后端 API 文档

## 🚀 快速启动

### 1. 安装依赖
```bash
npm install
```

### 2. 配置环境变量
复制 `.env.example` 为 `.env` 并修改配置：
```bash
cp .env.example .env
```

### 3. 初始化数据库
```bash
cd ../database
powershell -ExecutionPolicy Bypass -File migrate-database.ps1
```

### 4. 启动开发服务器
```bash
npm run dev
```

服务器将运行在 http://localhost:3000

## 📚 API 模块

### 1. 认证模块 (`/api/auth`)
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录

### 2. 用户模块 (`/api/users`)
- `GET /api/users/me` - 获取当前用户信息
- `PUT /api/users/me` - 更新用户信息
- `GET /api/users/me/stats` - 获取用户统计

### 3. 经纬瞰政 (`/api/geopolitics`)
- `GET /api/geopolitics/hotspots` - 获取热点列表
- `GET /api/geopolitics/hotspots/:id` - 获取热点详情
- `GET /api/geopolitics/tags` - 获取标签列表
- `POST /api/geopolitics/hotspots/:id/like` - 点赞热点
- `POST /api/geopolitics/hotspots/:id/favorite` - 收藏热点
- `POST /api/geopolitics/questions/:id/answer` - 提交答案

### 4. 赛博实验 (`/api/cyberlab`)
- `GET /api/cyberlab/templates` - 获取实验模板列表
- `GET /api/cyberlab/temples/:id` - 获取实验详情
- `POST /api/cyberlab/experiments/start` - 开始实验
- `PUT /api/cyberlab/experiments/:id/save` - 保存实验数据
- `POST /api/cyberlab/experiments/:id/submit` - 提交实验报告
- `POST /api/cyberlab/collaborations/create` - 创建协作房间

### 5. 情景互动 (`/api/scenario`)
- `GET /api/scenario/roles` - 获取角色列表
- `GET /api/scenario/scenes` - 获取场景列表
- `GET /api/scenario/tasks` - 获取任务列表
- `POST /api/scenario/tasks/:id/start` - 开始任务
- `POST /api/scenario/discoveries` - 记录探索发现

### 6. AI地理伴学 (`/api/ai-companion`)
- `POST /api/ai-companion/chat/start` - 开始AI对话
- `POST /api/ai-companion/chat/:sessionId/message` - 发送消息
- `GET /api/ai-companion/analytics` - 获取学习分析
- `POST /api/ai-companion/study-plans` - 创建学习计划
- `GET /api/ai-companion/error-notebook` - 获取错题本
- `POST /api/ai-companion/ocr/recognize` - OCR识别

## 🔐 认证

大多数API需要在请求头中携带JWT令牌：
```
Authorization: Bearer <token>
```

## 📦 响应格式

成功响应：
```json
{
  "success": true,
  "data": { },
  "message": "操作成功"
}
```

错误响应：
```json
{
  "success": false,
  "message": "错误信息",
  "error": "详细错误堆栈（仅开发环境）"
}
```

## 🛠️ 技术栈

- **框架**: Express.js + TypeScript
- **数据库**: MySQL
- **认证**: JWT + bcryptjs
- **实时通信**: Socket.io
- **缓存**: Redis（可选）
- **日志**: Winston
- **安全**: Helmet + CORS

## 📝 开发命令

```bash
npm run dev      # 开发模式（热重载）
npm run build    # 编译TypeScript
npm start        # 生产模式
npm test         # 运行测试
```

## 🌐 WebSocket 事件

### 实验室协作
- `join_lab_room` - 加入实验室房间
- `lab_sync_data` - 同步实验数据
- `lab_data_update` - 接收数据更新

### 情景互动
- `join_scenario` - 加入场景
- `update_position` - 更新位置
- `player_position` - 接收玩家位置

### AI对话
- `ai_chat_stream` - AI流式响应
- `ai_response_chunk` - 接收AI响应片段

## 📌 注意事项

1. 确保MySQL服务已启动
2. 修改 `.env` 中的数据库密码
3. 生产环境需要更改 `JWT_SECRET`
4. 配置新闻API和AI服务的密钥
5. 检查防火墙允许3000端口
