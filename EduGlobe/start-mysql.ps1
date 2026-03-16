# EduGlobe MySQL 启动脚本
# 此脚本用于启动 MySQL 8.0.23 数据库服务器

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe MySQL 启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# MySQL 路径配置
$MYSQL_PATH = "D:\mysql-8.0.23-winx64\bin\mysqld.exe"
$MYSQL_DATA_DIR = "D:\mysql-8.0.23-winx64\data"

# 检查 MySQL 是否已在运行
Write-Host "[1/3] 检查 MySQL 运行状态..." -ForegroundColor Yellow
$mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue

if ($mysqlProcess) {
    Write-Host "✓ MySQL 已在运行 (PID: $($mysqlProcess.Id))" -ForegroundColor Green
    Write-Host ""
    Write-Host "如需重启 MySQL，请先运行 stop-mysql.ps1 停止服务" -ForegroundColor Yellow
    exit 0
}

# 检查 MySQL 文件是否存在
Write-Host "[2/3] 检查 MySQL 安装..." -ForegroundColor Yellow
if (-not (Test-Path $MYSQL_PATH)) {
    Write-Host "✗ 错误: MySQL 未找到" -ForegroundColor Red
    Write-Host "   路径: $MYSQL_PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "请修改脚本中的 MYSQL_PATH 变量指向正确的 mysqld.exe 路径" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ MySQL 安装路径正确" -ForegroundColor Green

# 启动 MySQL
Write-Host "[3/3] 启动 MySQL 服务器..." -ForegroundColor Yellow
Write-Host ""
Write-Host "MySQL 将在后台运行，请勿关闭弹出的窗口！" -ForegroundColor Yellow
Write-Host "数据库配置:" -ForegroundColor Cyan
Write-Host "  - 主机: localhost / 127.0.0.1" -ForegroundColor White
Write-Host "  - 端口: 3306" -ForegroundColor White
Write-Host "  - 用户: root" -ForegroundColor White
Write-Host "  - 密码: CHENhaoyu0608.." -ForegroundColor White
Write-Host "  - 数据库: eduglobe_db" -ForegroundColor White
Write-Host ""

# 在新窗口中启动 MySQL
Start-Process -FilePath $MYSQL_PATH -ArgumentList "--console" -WindowStyle Normal

# 等待 MySQL 启动
Write-Host "等待 MySQL 启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 验证 MySQL 是否启动成功
$mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "✓ MySQL 启动成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "现在可以:" -ForegroundColor Cyan
    Write-Host "  1. 使用 HeidiSQL 连接数据库" -ForegroundColor White
    Write-Host "  2. 运行 start-backend.ps1 启动后端服务" -ForegroundColor White
    Write-Host "  3. 运行 start-all.ps1 一键启动所有服务" -ForegroundColor White
} else {
    Write-Host "✗ MySQL 启动失败" -ForegroundColor Red
    Write-Host "请检查 MySQL 配置和日志" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
