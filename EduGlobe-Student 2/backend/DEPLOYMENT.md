# EduGlobe 部署指南

本文档详细说明了如何在生产环境中部署 EduGlobe 地理教育平台。

## 📋 目录
- [系统要求](#系统要求)
- [部署架构](#部署架构)
- [Docker 部署](#docker-部署)
- [传统部署](#传统部署)
- [配置优化](#配置优化)
- [监控与维护](#监控与维护)

## 系统要求

### 最低配置
- **CPU**: 2核
- **内存**: 4GB RAM
- **存储**: 50GB SSD
- **操作系统**: Ubuntu 20.04+ / CentOS 7+ / Windows Server 2019+

### 推荐配置
- **CPU**: 4核+
- **内存**: 8GB+ RAM
- **存储**: 100GB+ SSD
- **带宽**: 10Mbps+

### 软件依赖
- Node.js 16.x 或更高版本
- MySQL 8.0 或更高版本
- Nginx 1.18+ (作为反向代理)
- PM2 (进程管理)
- Redis 6.0+ (可选，用于缓存)

## 部署架构

```
                    ┌─────────────┐
                    │   Client    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    Nginx    │ (反向代理 + 静态文件)
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
  ┌─────▼─────┐     ┌─────▼─────┐     ┌─────▼─────┐
  │  Node.js  │     │  Node.js  │     │  Node.js  │ (负载均衡)
  │  Server   │     │  Server   │     │  Server   │
  └─────┬─────┘     └─────┬─────┘     └─────┬─────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
      ┌─────▼─────┐  ┌────▼────┐  ┌─────▼─────┐
      │   MySQL   │  │  Redis  │  │  Storage  │
      │  Primary  │  │  Cache  │  │  Server   │
      └───────────┘  └─────────┘  └───────────┘
```

## Docker 部署

### 1. 创建 Docker 配置文件

#### docker-compose.yml
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: eduglobe-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: eduglobe_db
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mysql-data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    ports:
      - "3306:3306"
    networks:
      - eduglobe-net

  redis:
    image: redis:6.2-alpine
    container_name: eduglobe-redis
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - eduglobe-net

  backend:
    build:
      context: ./server
      dockerfile: Dockerfile
    container_name: eduglobe-backend
    restart: always
    environment:
      NODE_ENV: production
      PORT: 3000
      DB_HOST: mysql
      DB_PORT: 3306
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: eduglobe_db
      REDIS_HOST: redis
      REDIS_PORT: 6379
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "3000:3000"
    depends_on:
      - mysql
      - redis
    networks:
      - eduglobe-net

  frontend:
    build:
      context: ./new-project
      dockerfile: Dockerfile
    container_name: eduglobe-frontend
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - eduglobe-net

volumes:
  mysql-data:
  redis-data:

networks:
  eduglobe-net:
    driver: bridge
```

### 2. 创建后端 Dockerfile

```dockerfile
# server/Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

### 3. 创建前端 Dockerfile

```dockerfile
# new-project/Dockerfile
FROM node:16-alpine as build-stage

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine as production-stage

COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 4. 启动服务

```bash
# 创建 .env 文件
cat > .env << EOF
DB_ROOT_PASSWORD=your_root_password
DB_USER=eduglobe_user
DB_PASSWORD=your_db_password
JWT_SECRET=your_jwt_secret_key
EOF

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 传统部署

### 1. 部署数据库

```bash
# 安装 MySQL
sudo apt update
sudo apt install mysql-server

# 配置 MySQL
sudo mysql_secure_installation

# 创建数据库
mysql -u root -p < database/schema.sql

# 创建应用用户
mysql -u root -p
CREATE USER 'eduglobe_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON eduglobe_db.* TO 'eduglobe_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. 部署后端

```bash
# 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 PM2
sudo npm install -g pm2

# 部署后端代码
cd server
npm install
npm run build

# 配置环境变量
cp .env.example .env
nano .env  # 编辑配置

# 使用 PM2 启动
pm2 start dist/index.js --name eduglobe-backend
pm2 save
pm2 startup
```

### 3. 部署前端

```bash
# 构建前端
cd new-project
npm install
npm run build

# 将构建产物复制到 Nginx 目录
sudo mkdir -p /var/www/eduglobe
sudo cp -r dist/* /var/www/eduglobe/
```

### 4. 配置 Nginx

```nginx
# /etc/nginx/sites-available/eduglobe
server {
    listen 80;
    server_name example.com www.example.com;

    # 前端静态文件
    location / {
        root /var/www/eduglobe;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # API 代理
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # WebSocket 支持
    location /socket.io {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 文件上传限制
    client_max_body_size 100M;

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss;
}
```

```bash
# 启用站点
sudo ln -s /etc/nginx/sites-available/eduglobe /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. 配置 SSL（HTTPS）

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 获取 SSL 证书
sudo certbot --nginx -d example.com -d www.example.com

# 自动续期
sudo systemctl enable certbot.timer
```

## 配置优化

### MySQL 优化

```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
max_connections = 200
innodb_buffer_pool_size = 2G
innodb_log_file_size = 512M
innodb_flush_log_at_trx_commit = 2
query_cache_type = 1
query_cache_size = 64M
```

### Node.js 优化

```json
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'eduglobe-backend',
    script: './dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    max_memory_restart: '1G',
    min_uptime: '10s',
    max_restarts: 10
  }]
}
```

### Nginx 优化

```nginx
# 性能优化
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
}

http {
    # 缓存配置
    proxy_cache_path /var/cache/nginx levels=1:2 
                     keys_zone=api_cache:10m 
                     max_size=100m inactive=60m;

    # 启用 HTTP/2
    listen 443 ssl http2;
    
    # 连接超时
    keepalive_timeout 65;
    proxy_read_timeout 300;
    proxy_connect_timeout 300;
}
```

## 监控与维护

### 1. 日志管理

```bash
# PM2 日志
pm2 logs eduglobe-backend

# Nginx 日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# MySQL 慢查询日志
sudo tail -f /var/log/mysql/mysql-slow.log
```

### 2. 性能监控

```bash
# 安装监控工具
npm install -g pm2-logrotate
pm2 install pm2-server-monit

# 查看资源使用
pm2 monit

# 系统监控
htop
```

### 3. 数据备份

```bash
# MySQL 备份脚本
#!/bin/bash
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p eduglobe_db | gzip > $BACKUP_DIR/eduglobe_$DATE.sql.gz

# 保留最近 7 天的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# 添加到 crontab
0 2 * * * /path/to/backup-script.sh
```

### 4. 自动重启

```bash
# PM2 自动重启
pm2 startup
pm2 save

# 服务器重启后自动启动
sudo systemctl enable mysql
sudo systemctl enable nginx
sudo systemctl enable redis-server
```

## 故障排查

### 常见问题

1. **数据库连接失败**
   - 检查 MySQL 服务状态
   - 验证连接配置
   - 检查防火墙设置

2. **API 响应慢**
   - 检查数据库查询性能
   - 查看服务器负载
   - 优化慢查询

3. **WebSocket 连接失败**
   - 检查 Nginx 配置
   - 验证 Socket.IO 版本兼容性
   - 检查防火墙端口

## 安全建议

1. **定期更新依赖**
   ```bash
   npm audit
   npm update
   ```

2. **配置防火墙**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

3. **使用环境变量**
   - 不要在代码中硬编码敏感信息
   - 使用 `.env` 文件管理配置
   - 限制文件权限 `chmod 600 .env`

4. **定期备份**
   - 数据库每日备份
   - 代码版本控制
   - 配置文件备份

---

部署过程中如遇问题，请参考项目文档或提交 Issue。
