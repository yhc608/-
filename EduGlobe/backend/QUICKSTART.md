# EduGlobe 快速启动指南

## 🚀 快速开始（5分钟上手）

### 方法一：Docker 部署（推荐）

1. **确保已安装 Docker 和 Docker Compose**
   ```bash
   docker --version
   docker-compose --version
   ```

2. **配置环境变量**
   ```bash
   # 复制环境变量模板
   cp .env.docker .env
   
   # 编辑 .env 文件，设置密码等敏感信息
   nano .env
   ```

3. **一键启动所有服务**
   ```bash
   # 构建并启动
   docker-compose up -d
   
   # 查看日志
   docker-compose logs -f
   ```

4. **访问应用**
   - 前端：http://localhost
   - 后端 API：http://localhost:3000
   - 健康检查：http://localhost:3000/health

### 方法二：本地开发

#### 1. 安装依赖

**数据库**
```bash
# 安装 MySQL 8.0
# Windows: 下载安装包 https://dev.mysql.com/downloads/mysql/
# macOS: brew install mysql
# Linux: sudo apt install mysql-server

# 启动 MySQL
# Windows: 在服务中启动 MySQL
# macOS/Linux: sudo systemctl start mysql
```

**Node.js**
```bash
# 下载安装 Node.js 16+ https://nodejs.org/
node --version  # 确认版本 >= 16
```

#### 2. 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 执行以下命令
source database/schema.sql;

# 或者直接导入
mysql -u root -p < database/schema.sql
```

#### 3. 启动后端服务

```bash
cd server

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置数据库连接信息

# 启动开发服务器（支持热重载）
npm run dev

# 后端将运行在 http://localhost:3000
```

#### 4. 启动前端服务

```bash
# 打开新的终端窗口
cd new-project

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env

# 启动开发服务器
npm run dev

# 前端将运行在 http://localhost:5173
```

#### 5. 访问应用

打开浏览器访问：http://localhost:5173

## 📝 测试账号

您需要先注册账号或使用以下 SQL 插入测试数据：

```sql
-- 插入测试学校
INSERT INTO schools (name, province, city, school_type) 
VALUES ('示范中学', '江苏省', '南京市', 'high_school');

-- 插入测试教师（密码: teacher123）
INSERT INTO users (username, password_hash, email, role, real_name, school_id) 
VALUES ('teacher01', '$2a$10$XYZ...', 'teacher@example.com', 'teacher', '张老师', 1);

-- 插入测试学生（密码: student123）
INSERT INTO users (username, password_hash, email, role, real_name, school_id) 
VALUES ('student01', '$2a$10$ABC...', 'student@example.com', 'student', '李同学', 1);
```

或者通过前端注册新账号。

## 🔍 常见问题

### 端口被占用
```bash
# Windows 查找占用端口的进程
netstat -ano | findstr :3000

# 杀死进程
taskkill /F /PID <进程ID>

# macOS/Linux
lsof -ti:3000 | xargs kill -9
```

### 数据库连接失败
1. 确认 MySQL 服务已启动
2. 检查 `.env` 文件中的数据库配置
3. 确认数据库用户有足够的权限

### 依赖安装失败
```bash
# 清除缓存
npm cache clean --force

# 删除 node_modules 重新安装
rm -rf node_modules package-lock.json
npm install
```

## 📦 主要功能模块

### 学生端
- `/prep` - 课前预习
- `/classroom` - 课堂互动
- `/review` - 课后复习
- `/feature` - 特色功能（地理伴学、赛博实验等）

### 教师端
- `/teacher/lesson` - 智能备课
- `/teacher/monitoring` - 课堂监控
- `/teacher/grading` - 作业批改
- `/teacher/dashboard` - 教学数据

## 🛠️ 开发工具

### VSCode 推荐插件
- Vue Language Features (Volar)
- TypeScript Vue Plugin (Volar)
- ESLint
- Prettier
- REST Client

### API 测试
可以使用以下工具测试 API：
- Postman
- Thunder Client (VSCode 插件)
- curl

示例：
```bash
# 登录
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"student01","password":"student123"}'

# 获取用户信息（需要替换 TOKEN）
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <YOUR_TOKEN>"
```

## 🎓 下一步

1. 阅读[完整文档](README.md)
2. 查看[部署指南](DEPLOYMENT.md)
3. 浏览[API 文档](docs/api.md)（如有）
4. 开始开发新功能

## 💡 提示

- 开发时前后端需要同时运行
- 修改代码后会自动热重载
- 建议使用 Git 进行版本控制
- 定期备份数据库

## 🐛 遇到问题？

1. 查看终端错误日志
2. 检查浏览器控制台
3. 查看后端日志文件 `server/logs/`
4. 提交 Issue 到 GitHub

---

祝开发愉快！💪
