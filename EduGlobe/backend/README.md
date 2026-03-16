# EduGlobe 地理教育平台

一个基于 AI 的智能地理教育平台，支持课前预习、课堂互动、课后巩固、虚拟实验等全方位教学功能。

## 📚 项目简介

EduGlobe 是一个集成了前端、后端和数据库的完整全栈应用，旨在为中学和本科生提供智能化的地理学习体验，同时为教师提供强大的教学辅助工具。

### 核心功能

#### 学生端功能
- **课前预习**：智能知识图谱、概念卡片、预习检测
- **课堂互动**：虚拟角色导入、实时问答、专注力监测、地理小游戏
- **课后巩固**：多模态答疑、错题归因、个性化复习计划、学习报告
- **本科专属**：VR/AR 虚拟仿真、地理虚拟实验、地学交流频道

#### 教师端功能
- **智能备课**：一键生成教案、跨学科融合、资源包匹配
- **课堂管理**：实时监测、互动统计、教学节奏建议
- **作业批改**：手绘地图识别、自动评分、智能评语
- **数据后台**：学情分析、教学数据驾驶舱

## 🏗️ 技术栈

### 前端
- **框架**：Vue 3 + TypeScript + Vite
- **路由**：Vue Router 4
- **样式**：SCSS
- **可视化**：ECharts、Three.js
- **通信**：Axios、Socket.IO Client

### 后端
- **运行时**：Node.js
- **框架**：Express + TypeScript
- **认证**：JWT (JSON Web Tokens)
- **实时通信**：Socket.IO
- **日志**：Winston
- **验证**：Joi

### 数据库
- **主数据库**：MySQL 8.0
- **缓存**：Redis (可选)

## 📦 项目结构

```
EduGlobe/
├── new-project/                # 前端项目
│   ├── src/
│   │   ├── components/        # Vue 组件
│   │   ├── pages/             # 页面组件
│   │   ├── router/            # 路由配置
│   │   ├── services/          # API 服务
│   │   ├── styles/            # 样式文件
│   │   └── utils/             # 工具函数
│   ├── public/                # 静态资源
│   └── package.json
│
├── server/                     # 后端项目
│   ├── src/
│   │   ├── controllers/       # 控制器
│   │   │   ├── student/      # 学生端控制器
│   │   │   └── teacher/      # 教师端控制器
│   │   ├── routes/            # 路由定义
│   │   ├── middleware/        # 中间件
│   │   ├── database/          # 数据库连接
│   │   ├── utils/             # 工具函数
│   │   └── index.ts           # 入口文件
│   ├── .env.example           # 环境变量示例
│   └── package.json
│
└── database/                   # 数据库脚本
    └── schema.sql             # 数据库表结构
```

## 🚀 快速开始

### 环境要求
- Node.js >= 16.x
- MySQL >= 8.0
- npm >= 8.x 或 yarn

### 1. 克隆项目
```bash
git clone <repository-url>
cd EduGlobe
```

### 2. 配置数据库

#### 创建数据库
```bash
mysql -u root -p < database/schema.sql
```

或者在 MySQL 命令行中执行：
```sql
source database/schema.sql;
```

### 3. 配置后端

#### 安装依赖
```bash
cd server
npm install
```

#### 配置环境变量
```bash
cp .env.example .env
```

编辑 `.env` 文件，配置数据库连接和其他参数：
```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=eduglobe_db

JWT_SECRET=your_jwt_secret_key
```

#### 启动后端服务
```bash
# 开发模式（支持热重载）
npm run dev

# 生产模式
npm run build
npm start
```

后端服务将运行在 `http://localhost:3000`

### 4. 配置前端

#### 安装依赖
```bash
cd new-project
npm install
```

#### 配置环境变量
```bash
cp .env.example .env
```

编辑 `.env` 文件：
```env
VITE_API_BASE_URL=http://localhost:3000/api
VITE_WS_URL=http://localhost:3000
```

#### 启动前端开发服务器
```bash
npm run dev
```

前端服务将运行在 `http://localhost:5173`

### 5. 访问应用
打开浏览器访问 `http://localhost:5173`

## 🔑 默认账户

系统初始化后，您可以注册新账户或者插入测试数据：

```sql
-- 插入测试学校
INSERT INTO schools (name, province, city, school_type) 
VALUES ('示范中学', '江苏省', '南京市', 'high_school');

-- 插入测试教师
INSERT INTO users (username, password_hash, email, role, real_name, school_id) 
VALUES ('teacher01', '$2a$10$...', 'teacher@example.com', 'teacher', '张老师', 1);

-- 插入测试学生
INSERT INTO users (username, password_hash, email, role, real_name, school_id) 
VALUES ('student01', '$2a$10$...', 'student@example.com', 'student', '李同学', 1);
```

## 📖 API 文档

### 认证接口
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 获取当前用户信息

### 学生端接口
- `GET /api/student/preview/knowledge-map` - 获取知识图谱
- `POST /api/student/classroom/join` - 加入课堂
- `POST /api/student/qa/ask` - 提问
- `GET /api/student/report/:type` - 获取学习报告

### 教师端接口
- `POST /api/teacher/lesson/generate` - 生成教案
- `GET /api/teacher/monitoring/classroom/:courseId` - 课堂监控
- `POST /api/teacher/grading/assignment/:submissionId` - 批改作业
- `GET /api/teacher/dashboard/:classId` - 教学数据驾驶舱

详细 API 文档请参考 `/docs/api.md`

## 🔧 开发指南

### 添加新功能
1. 在 `server/src/controllers/` 中创建控制器
2. 在 `server/src/routes/` 中定义路由
3. 在 `new-project/src/services/api.ts` 中添加 API 调用
4. 在前端页面中使用 API

### 数据库迁移
```bash
cd server
npm run migrate
```

### 运行测试
```bash
# 后端测试
cd server
npm test

# 前端测试
cd new-project
npm test
```

## 📊 数据库设计

### 核心数据表
- **users** - 用户表（学生+教师）
- **schools** - 学校表
- **classes** - 班级表
- **knowledge_nodes** - 知识图谱节点
- **courses** - 课程表
- **assignments** - 作业表
- **classroom_interactions** - 课堂互动记录
- **qa_records** - 答疑记录
- **learning_reports** - 学习报告

详细表结构请查看 `database/schema.sql`

## 🚢 部署

### Docker 部署（推荐）
```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d
```

### 传统部署
1. 配置 Nginx 反向代理
2. 使用 PM2 管理 Node.js 进程
3. 配置 MySQL 主从复制（可选）
4. 配置 Redis 集群（可选）

详细部署指南请参考 `/docs/deployment.md`

## 🤝 贡献指南

欢迎贡献代码、提出问题或建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 📞 联系方式

- 项目主页：[GitHub Repository]
- 问题反馈：[Issues]
- 邮箱：support@eduglobe.com

## 🙏 致谢

感谢所有为本项目做出贡献的开发者！

---

© 2024 EduGlobe Team. All Rights Reserved.
