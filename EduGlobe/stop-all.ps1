# EduGlobe 一键停止脚本
# 此脚本将停止 MySQL、后端和前端所有服务

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe 一键停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 配置路径
$MYSQL_PATH = "D:\mysql-8.0.23-winx64\bin\mysqld.exe"

# ========================================
# 停止前端服务 (Vite)
# ========================================
Write-Host "[1/3] 停止前端服务..." -ForegroundColor Yellow
$viteProcesses = Get-Process | Where-Object { $_.ProcessName -eq "node" -and $_.Path -like "*\node.exe" } | Where-Object {
    $cmdline = (Get-WmiObject Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
    $cmdline -like "*vite*" -or $cmdline -like "*frontend*"
}

if ($viteProcesses) {
    $viteProcesses | ForEach-Object {
        Write-Host "停止前端进程 (PID: $($_.Id))" -ForegroundColor Cyan
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "✓ 前端服务已停止" -ForegroundColor Green
} else {
    Write-Host "前端服务未在运行" -ForegroundColor Gray
}

Write-Host ""

# ========================================
# 停止后端服务 (Node/Express)
# ========================================
Write-Host "[2/3] 停止后端服务..." -ForegroundColor Yellow

# 查找占用 3000 端口的进程
$backendPort = netstat -ano | Select-String ":3000.*LISTENING"
if ($backendPort) {
    $backendPort | ForEach-Object {
        $line = $_.Line
        $pid = ($line -split '\s+')[-1]
        if ($pid -match '^\d+$') {
            Write-Host "停止后端进程 (PID: $pid)" -ForegroundColor Cyan
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "✓ 后端服务已停止" -ForegroundColor Green
} else {
    Write-Host "后端服务未在运行" -ForegroundColor Gray
}

Write-Host ""

# ========================================
# 停止 MySQL 数据库
# ========================================
Write-Host "[3/3] 停止 MySQL 数据库..." -ForegroundColor Yellow

$mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "停止 MySQL 进程 (PID: $($mysqlProcess.Id))" -ForegroundColor Cyan
    $mysqlProcess | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "✓ MySQL 已停止" -ForegroundColor Green
} else {
    Write-Host "MySQL 未在运行" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   所有服务已停止" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
