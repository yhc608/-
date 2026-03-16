# EduGlobe 环境检查脚本
# 此脚本检查所有必需的环境和配置是否正确

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe 环境检查" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allChecks = @()
$passedChecks = 0
$totalChecks = 0

function Check-Item {
    param(
        [string]$Name,
        [bool]$Result,
        [string]$Details = ""
    )
    
    $script:totalChecks++
    
    if ($Result) {
        Write-Host "✓ $Name" -ForegroundColor Green
        if ($Details) {
            Write-Host "  $Details" -ForegroundColor Gray
        }
        $script:passedChecks++
    } else {
        Write-Host "✗ $Name" -ForegroundColor Red
        if ($Details) {
            Write-Host "  $Details" -ForegroundColor Yellow
        }
    }
    
    $script:allChecks += @{
        Name = $Name
        Result = $Result
        Details = $Details
    }
}

# ========================================
# 检查系统环境
# ========================================
Write-Host "[1/5] 检查系统环境..." -ForegroundColor Yellow
Write-Host ""

# 检查 PowerShell 版本
$psVersion = $PSVersionTable.PSVersion
$psVersionOk = $psVersion.Major -ge 5
Check-Item "PowerShell 版本" $psVersionOk "版本: $($psVersion.Major).$($psVersion.Minor)"

# 检查 Node.js
try {
    $nodeVersion = node --version 2>$null
    $nodeOk = $nodeVersion -ne $null
    Check-Item "Node.js" $nodeOk "版本: $nodeVersion"
} catch {
    Check-Item "Node.js" $false "未安装或不在 PATH 中"
}

# 检查 npm
try {
    $npmVersion = npm --version 2>$null
    $npmOk = $npmVersion -ne $null
    Check-Item "npm" $npmOk "版本: $npmVersion"
} catch {
    Check-Item "npm" $false "未安装或不在 PATH 中"
}

Write-Host ""

# ========================================
# 检查 MySQL
# ========================================
Write-Host "[2/5] 检查 MySQL 数据库..." -ForegroundColor Yellow
Write-Host ""

$MYSQL_PATH = "D:\mysql-8.0.23-winx64\bin\mysqld.exe"
$MYSQL_CLIENT = "D:\mysql-8.0.23-winx64\bin\mysql.exe"

# 检查 MySQL 安装
$mysqlInstalled = Test-Path $MYSQL_PATH
Check-Item "MySQL 安装" $mysqlInstalled "路径: $MYSQL_PATH"

if ($mysqlInstalled) {
    # 检查 MySQL 是否运行
    $mysqlProcess = Get-Process | Where-Object { $_.Path -eq $MYSQL_PATH } -ErrorAction SilentlyContinue
    $mysqlRunning = $mysqlProcess -ne $null
    Check-Item "MySQL 运行状态" $mysqlRunning $(if ($mysqlRunning) { "PID: $($mysqlProcess.Id)" } else { "未运行，请运行 start-mysql.ps1" })
    
    # 检查 3306 端口
    $port3306 = netstat -ano | Select-String ":3306.*LISTENING"
    $portOk = $port3306 -ne $null
    Check-Item "MySQL 端口 (3306)" $portOk $(if (!$portOk) { "端口未监听" })
}

Write-Host ""

# ========================================
# 检查项目文件
# ========================================
Write-Host "[3/5] 检查项目文件..." -ForegroundColor Yellow
Write-Host ""

$PROJECT_ROOT = $PSScriptRoot
$BACKEND_PATH = Join-Path $PROJECT_ROOT "backend\server"
$FRONTEND_PATH = Join-Path $PROJECT_ROOT "frontend"
$ENV_FILE = Join-Path $BACKEND_PATH ".env"
$SCHEMA_FILE = Join-Path $PROJECT_ROOT "backend\database\schema.sql"

# 检查后端目录
$backendExists = Test-Path $BACKEND_PATH
Check-Item "后端目录" $backendExists "路径: $BACKEND_PATH"

if ($backendExists) {
    # 检查后端依赖
    $backendModules = Test-Path (Join-Path $BACKEND_PATH "node_modules")
    Check-Item "后端依赖" $backendModules $(if (!$backendModules) { "请运行: cd backend/server && npm install" })
    
    # 检查后端编译文件
    $backendDist = Test-Path (Join-Path $BACKEND_PATH "dist")
    Check-Item "后端编译文件" $backendDist $(if (!$backendDist) { "请运行: cd backend/server && npm run build" })
    
    # 检查环境配置
    $envExists = Test-Path $ENV_FILE
    Check-Item "后端配置文件" $envExists ".env 文件"
}

# 检查前端目录
$frontendExists = Test-Path $FRONTEND_PATH
Check-Item "前端目录" $frontendExists "路径: $FRONTEND_PATH"

if ($frontendExists) {
    # 检查前端依赖
    $frontendModules = Test-Path (Join-Path $FRONTEND_PATH "node_modules")
    Check-Item "前端依赖" $frontendModules $(if (!$frontendModules) { "请运行: cd frontend && npm install" })
}

# 检查数据库脚本
$schemaExists = Test-Path $SCHEMA_FILE
Check-Item "数据库脚本" $schemaExists "schema.sql"

Write-Host ""

# ========================================
# 检查服务运行状态
# ========================================
Write-Host "[4/5] 检查服务运行状态..." -ForegroundColor Yellow
Write-Host ""

# 检查后端端口
$backendPort = netstat -ano | Select-String ":3000.*LISTENING"
$backendRunning = $backendPort -ne $null
Check-Item "后端服务 (3000)" $backendRunning $(if (!$backendRunning) { "未运行" } else { "运行中" })

# 检查前端端口
$frontendPort = netstat -ano | Select-String ":5173.*LISTENING"
$frontendRunning = $frontendPort -ne $null
Check-Item "前端服务 (5173)" $frontendRunning $(if (!$frontendRunning) { "未运行" } else { "运行中" })

Write-Host ""

# ========================================
# 检查启动脚本
# ========================================
Write-Host "[5/5] 检查启动脚本..." -ForegroundColor Yellow
Write-Host ""

$startAllScript = Test-Path (Join-Path $PROJECT_ROOT "start-all.ps1")
Check-Item "一键启动脚本" $startAllScript "start-all.ps1"

$stopAllScript = Test-Path (Join-Path $PROJECT_ROOT "stop-all.ps1")
Check-Item "一键停止脚本" $stopAllScript "stop-all.ps1"

$startMysqlScript = Test-Path (Join-Path $PROJECT_ROOT "start-mysql.ps1")
Check-Item "MySQL启动脚本" $startMysqlScript "start-mysql.ps1"

$quickStartBat = Test-Path (Join-Path $PROJECT_ROOT "快速启动.bat")
Check-Item "快速启动批处理" $quickStartBat "快速启动.bat"

Write-Host ""

# ========================================
# 总结报告
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   检查完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "通过: $passedChecks / $totalChecks 项 ($passRate%)" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

# 提供建议
if ($passRate -lt 100) {
    Write-Host "建议操作:" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not $mysqlInstalled) {
        Write-Host "  1. 修改脚本中的 MySQL 路径" -ForegroundColor White
    }
    
    if ($mysqlInstalled -and -not $mysqlRunning) {
        Write-Host "  1. 运行 start-mysql.ps1 启动 MySQL" -ForegroundColor White
    }
    
    if ($backendExists -and -not $backendModules) {
        Write-Host "  2. 安装后端依赖: cd backend/server && npm install" -ForegroundColor White
    }
    
    if ($frontendExists -and -not $frontendModules) {
        Write-Host "  3. 安装前端依赖: cd frontend && npm install" -ForegroundColor White
    }
    
    if (-not $backendRunning -and -not $frontendRunning) {
        Write-Host "  4. 运行 start-all.ps1 启动所有服务" -ForegroundColor White
    }
} else {
    Write-Host "✓ 所有检查通过！环境配置正确。" -ForegroundColor Green
    Write-Host ""
    
    if (-not $backendRunning -or -not $frontendRunning) {
        Write-Host "服务未运行，可以运行以下命令启动:" -ForegroundColor Cyan
        Write-Host "  .\start-all.ps1" -ForegroundColor White
        Write-Host "  或双击 快速启动.bat" -ForegroundColor White
    } else {
        Write-Host "所有服务正在运行！" -ForegroundColor Green
        Write-Host "访问: http://localhost:5173" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
