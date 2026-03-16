# EduGlobe 一键启动脚本
# 此脚本将启动 MySQL、后端和前端所有服务

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe 一键启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 配置路径
$PROJECT_ROOT = $PSScriptRoot
$MYSQL_PATH = "D:\mysql-8.0.23-winx64\bin\mysqld.exe"
$BACKEND_PATH = Join-Path $PROJECT_ROOT "backend\server"
$FRONTEND_PATH = Join-Path $PROJECT_ROOT "frontend"

# 错误处理
$ErrorActionPreference = "Continue"

# ========================================
# 步骤 1: 启动 MySQL
# ========================================
Write-Host "[1/3] 启动 MySQL 数据库..." -ForegroundColor Yellow

$mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "✓ MySQL 已在运行 (PID: $($mysqlProcess.Id))" -ForegroundColor Green
} else {
    if (Test-Path $MYSQL_PATH) {
        Write-Host "正在启动 MySQL..." -ForegroundColor Cyan
        Start-Process -FilePath $MYSQL_PATH -ArgumentList "--console" -WindowStyle Minimized
        Start-Sleep -Seconds 5
        
        $mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
        if ($mysqlProcess) {
            Write-Host "✓ MySQL 启动成功" -ForegroundColor Green
        } else {
            Write-Host "✗ MySQL 启动失败" -ForegroundColor Red
            Write-Host "请手动运行 start-mysql.ps1 检查详细信息" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "✗ 错误: 未找到 MySQL" -ForegroundColor Red
        Write-Host "   路径: $MYSQL_PATH" -ForegroundColor Red
        Write-Host "   请修改脚本中的 MYSQL_PATH 变量" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# ========================================
# 步骤 2: 启动后端服务
# ========================================
Write-Host "[2/3] 启动后端服务..." -ForegroundColor Yellow

if (-not (Test-Path $BACKEND_PATH)) {
    Write-Host "✗ 错误: 后端目录不存在: $BACKEND_PATH" -ForegroundColor Red
    exit 1
}

# 检查后端是否已在运行
$backendPort = netstat -ano | Select-String ":3000.*LISTENING"
if ($backendPort) {
    Write-Host "✓ 后端服务已在运行 (端口 3000)" -ForegroundColor Green
} else {
    Write-Host "正在启动后端服务..." -ForegroundColor Cyan
    
    # 在新窗口启动后端
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BACKEND_PATH'; Write-Host '后端服务启动中...' -ForegroundColor Cyan; npm start"
    
    Write-Host "等待后端服务启动..." -ForegroundColor Cyan
    Start-Sleep -Seconds 8
    
    $backendPort = netstat -ano | Select-String ":3000.*LISTENING"
    if ($backendPort) {
        Write-Host "✓ 后端服务启动成功 (http://localhost:3000)" -ForegroundColor Green
    } else {
        Write-Host "⚠ 后端服务可能启动失败，请检查后端窗口" -ForegroundColor Yellow
    }
}

Write-Host ""

# ========================================
# 步骤 3: 启动前端服务
# ========================================
Write-Host "[3/3] 启动前端服务..." -ForegroundColor Yellow

if (-not (Test-Path $FRONTEND_PATH)) {
    Write-Host "✗ 错误: 前端目录不存在: $FRONTEND_PATH" -ForegroundColor Red
    exit 1
}

# 检查前端是否已在运行
$frontendPort = netstat -ano | Select-String ":5173.*LISTENING"
if ($frontendPort) {
    Write-Host "✓ 前端服务已在运行 (端口 5173)" -ForegroundColor Green
} else {
    Write-Host "正在启动前端服务..." -ForegroundColor Cyan
    
    # 在新窗口启动前端
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$FRONTEND_PATH'; Write-Host '前端服务启动中...' -ForegroundColor Cyan; npm run dev"
    
    Write-Host "等待前端服务启动..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    
    $frontendPort = netstat -ano | Select-String ":5173.*LISTENING"
    if ($frontendPort) {
        Write-Host "✓ 前端服务启动成功 (http://localhost:5173)" -ForegroundColor Green
    } else {
        Write-Host "⚠ 前端服务可能启动失败，请检查前端窗口" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   所有服务启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "服务访问地址:" -ForegroundColor Cyan
Write-Host "  🌐 前端应用: http://localhost:5173" -ForegroundColor White
Write-Host "  🔧 后端 API: http://localhost:3000/api" -ForegroundColor White
Write-Host "  🗄️  MySQL 数据库: localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "开发工具:" -ForegroundColor Cyan
Write-Host "  📊 HeidiSQL: 连接 localhost:3306 (root/CHENhaoyu0608..)" -ForegroundColor White
Write-Host ""
Write-Host "现在可以在浏览器中打开 http://localhost:5173 使用应用！" -ForegroundColor Green
Write-Host ""
Write-Host "提示:" -ForegroundColor Yellow
Write-Host "  - 请勿关闭弹出的后端和前端窗口" -ForegroundColor Gray
Write-Host "  - 要停止所有服务，请运行 stop-all.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
