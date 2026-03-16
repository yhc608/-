# EduGlobe 地理教育平台

> 智能化地理学习平台 - 融合AI助手、虚拟实验、互动场景和知识图谱

## 🚀 快速启动

### 最简单的方式（推荐）

双击运行 **`快速启动.bat`** 文件，等待所有服务启动完成后，在浏览器中打开：

```
http://localhost:5173
```

就这么简单！✨

### 使用 PowerShell

```powershell
.\start-all.ps1
```

### 停止服务

双击运行 **`停止服务.bat`** 或：

```powershell
.\stop-all.ps1
```

## 📚 详细文档

完整的启动指南和故障排除请查看：**[启动指南.md](./启动指南.md)**

## 🛠️ 技术栈

### 后端
- **框架**: Node.js + Express + TypeScript
- **数据库**: MySQL 8.0
- **认证**: JWT
- **实时通信**: Socket.io

### 前端
- **框架**: Vue 3 + TypeScript
- **构建工具**: Vite
- **UI**: 自定义组件库
- **路由**: Vue Router

## 📁 项目结构

```
EduGlobe-Student 2/
├── backend/                 # 后端服务
│   ├── database/           # 数据库脚本
│   └── server/             # Express 服务器
├── frontend/               # 前端应用
├── 快速启动.bat            # 双击启动（最简单）
├── 停止服务.bat            # 双击停止服务
├── start-all.ps1          # PowerShell 启动脚本
├── stop-all.ps1           # PowerShell 停止脚本
└── 启动指南.md            # 详细文档
```

## 🌐 服务地址

启动成功后：

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端应用 | http://localhost:5173 | 主应用界面 |
| 后端 API | http://localhost:3000/api | REST API |
| MySQL | localhost:3306 | 数据库 (root/CHENhaoyu0608..) |

## ✨ 主要功能

### 1. AI地理伴学
- 智能问答助手
- 知识图谱导航
- 个性化学习路径
- 学习进度追踪

### 2. 赛博实验
- 虚拟地理实验
- 数据分析工具
- 实验报告生成

### 3. 情景互动
- 沉浸式场景探索
- 任务驱动学习
- 互动体验记录

### 4. 经纬瞰政
- 地缘政治分析
- 热点事件追踪
- 多维度数据可视化

## 🔧 开发命令

```powershell
# 后端开发
cd backend/server
npm install          # 安装依赖
npm start           # 启动服务（使用编译后代码）
npm run build       # 编译 TypeScript

# 前端开发
cd frontend
npm install         # 安装依赖
npm run dev         # 启动开发服务器（支持热更新）
npm run build       # 构建生产版本
```

## 📊 数据库

### 连接信息
- **主机**: localhost
- **端口**: 3306
- **用户**: root
- **密码**: CHENhaoyu0608..
- **数据库**: eduglobe_db

### 管理工具
推荐使用 **HeidiSQL** 进行数据库管理

### 数据库表（33个）
包含用户、课程、班级、作业、实验、游戏、频道、知识图谱等完整业务表。

详细表结构见 `backend/database/schema.sql`

## ⚙️ 系统要求

### 必需
- Windows 10/11
- Node.js 16+
- MySQL 8.0+
- PowerShell 5.1+

### 推荐
- 8GB+ RAM
- SSD 硬盘
- 现代浏览器（Chrome/Edge/Firefox）

## 📝 注意事项

1. **首次启动**: 确保 MySQL 数据库路径正确（默认：D:\mysql-8.0.23-winx64）
2. **端口占用**: 确保 3000、3306、5173 端口未被占用
3. **窗口保持**: 启动后不要关闭弹出的命令行窗口
4. **数据备份**: 定期备份数据库（使用 HeidiSQL 或 mysqldump）

## 🐛 故障排除

### 常见问题

1. **MySQL 启动失败**
   - 检查路径是否正确
   - 确认 3306 端口未被占用
   - 查看启动日志

2. **后端无法连接数据库**
   - 验证数据库密码
   - 确认 MySQL 正在运行
   - 检查 .env 配置

3. **前端无法访问**
   - 确认后端已启动
   - 检查 CORS 配置
   - 查看浏览器控制台

详细解决方案见 [启动指南.md](./启动指南.md#常见问题)

## 📖 文档索引

- [启动指南](./启动指南.md) - 详细的启动步骤和故障排除
- [后端文档](./backend/README.md) - 后端架构和 API 文档
- [数据库文档](./backend/DEPLOYMENT.md) - 部署和优化指南

## 🤝 贡献

欢迎提出建议和改进！

## 📄 许可

MIT License

---

**🎓 让地理学习更智能、更有趣！**

有问题？查看 [启动指南.md](./启动指南.md) 或联系技术支持。
