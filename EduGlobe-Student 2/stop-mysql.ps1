# EduGlobe MySQL 停止脚本
# 此脚本用于停止 MySQL 8.0.23 数据库服务器

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe MySQL 停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# MySQL 路径配置
$MYSQL_PATH = "D:\mysql-8.0.23-winx64\bin\mysqld.exe"

Write-Host "正在停止 MySQL 服务..." -ForegroundColor Yellow

# 查找并停止 MySQL 进程
$mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue

if ($mysqlProcess) {
    Write-Host "找到 MySQL 进程 (PID: $($mysqlProcess.Id))" -ForegroundColor Cyan
    
    # 尝试优雅地停止
    Write-Host "正在停止进程..." -ForegroundColor Yellow
    $mysqlProcess | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 2
    
    # 验证是否停止
    $checkProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
    if ($checkProcess) {
        Write-Host "✗ MySQL 停止失败，尝试强制停止..." -ForegroundColor Red
        Stop-Process -Id $checkProcess.Id -Force
        Start-Sleep -Seconds 1
    }
    
    Write-Host "✓ MySQL 已停止" -ForegroundColor Green
} else {
    Write-Host "MySQL 未在运行" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
