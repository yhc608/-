# ========================================
# EduGlobe 数据库迁移脚本
# 功能：一键导入所有数据库表结构和初始数据
# 使用方法：.\migrate-database.ps1
# ========================================

param(
    [string]$Host = "localhost",
    [string]$User = "root",
    [string]$Password = "CHENhaoyu0608..",
    [string]$Database = "eduglobe_db"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EduGlobe 数据库迁移工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 MySQL 是否已安装
Write-Host "[1/6] 检查 MySQL 环境..." -ForegroundColor Yellow
$mysqlPath = Get-Command mysql -ErrorAction SilentlyContinue

if (-not $mysqlPath) {
    Write-Host "❌ 错误：未找到 MySQL 命令行工具" -ForegroundColor Red
    Write-Host "请确保 MySQL 已安装并已添加到系统 PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✅ MySQL 已安装: $($mysqlPath.Source)" -ForegroundColor Green
Write-Host ""

# 获取当前脚本目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# SQL 文件列表（按执行顺序）
$sqlFiles = @(
    @{
        Name = "基础表结构"
        File = "schema.sql"
        Description = "用户、学校、班级、知识图谱等基础表"
    },
    @{
        Name = "四大功能模块表"
        File = "four-features.sql"
        Description = "经纬瞰政、赛博实验、情景互动、AI伴学"
    },
    @{
        Name = "增强功能表"
        File = "enhanced-features.sql"
        Description = "标签、评论、媒体、统计等补充表"
    }
)

# 执行 SQL 文件
$successCount = 0
$failCount = 0

foreach ($sqlFile in $sqlFiles) {
    $filePath = Join-Path $scriptDir $sqlFile.File
    
    Write-Host "[2/6] 执行: $($sqlFile.Name)" -ForegroundColor Yellow
    Write-Host "     描述: $($sqlFile.Description)" -ForegroundColor Gray
    Write-Host "     文件: $($sqlFile.File)" -ForegroundColor Gray
    
    if (-not (Test-Path $filePath)) {
        Write-Host "⚠️  跳过：文件不存在" -ForegroundColor Yellow
        $failCount++
        Write-Host ""
        continue
    }
    
    try {
        # 执行 SQL 文件
        $result = & mysql -h $Host -u $User -p$Password < $filePath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 成功导入" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "❌ 导入失败" -ForegroundColor Red
            Write-Host "   错误信息: $result" -ForegroundColor Red
            $failCount++
        }
    } catch {
        Write-Host "❌ 执行失败: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
    Start-Sleep -Milliseconds 500
}

# 验证数据库表
Write-Host "[3/6] 验证数据库表..." -ForegroundColor Yellow

try {
    $tableCount = & mysql -h $Host -u $User -p$Password -D $Database -e "SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema='$Database';" --skip-column-names 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 数据库表数量: $tableCount" -ForegroundColor Green
    } else {
        Write-Host "⚠️  无法获取表数量" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  验证失败: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# 显示关键表列表
Write-Host "[4/6] 显示关键数据表..." -ForegroundColor Yellow

$keyTables = @(
    "users", "schools", "classes",
    "geopolitics_hotspots", "cyber_lab_templates", 
    "scenario_scenes", "scenario_tasks",
    "ai_study_sessions", "ai_study_plans"
)

try {
    foreach ($table in $keyTables) {
        $exists = & mysql -h $Host -u $User -p$Password -D $Database -e "SHOW TABLES LIKE '$table';" --skip-column-names 2>&1
        
        if ($exists -match $table) {
            Write-Host "  ✅ $table" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $table (不存在)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "  ⚠️  无法验证表: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# 数据库优化
Write-Host "[5/6] 执行数据库优化..." -ForegroundColor Yellow

try {
    # 分析表以优化查询性能
    $analyzeTables = @(
        "geopolitics_hotspots",
        "cyber_lab_records",
        "scenario_user_progress",
        "ai_study_analytics"
    )
    
    foreach ($table in $analyzeTables) {
        $result = & mysql -h $Host -u $User -p$Password -D $Database -e "ANALYZE TABLE $table;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ 已优化: $table" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "  ⚠️  优化跳过: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# 汇总报告
Write-Host "[6/6] 迁移完成报告" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "成功导入: $successCount 个文件" -ForegroundColor Green
Write-Host "失败/跳过: $failCount 个文件" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host "数据库名: $Database" -ForegroundColor Cyan
Write-Host "主机地址: $Host" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "🎉 数据库迁移成功完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步操作：" -ForegroundColor Yellow
    Write-Host "  1. 配置后端环境变量 (.env 文件)" -ForegroundColor White
    Write-Host "  2. 启动后端服务: cd server && npm install && npm start" -ForegroundColor White
    Write-Host "  3. 启动前端服务: cd frontend && npm install && npm run dev" -ForegroundColor White
} else {
    Write-Host "⚠️  迁移过程中出现错误，请检查日志" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "常见问题解决：" -ForegroundColor Yellow
    Write-Host "  1. 检查 MySQL 是否运行: Get-Service MySQL*" -ForegroundColor White
    Write-Host "  2. 检查用户名和密码是否正确" -ForegroundColor White
    Write-Host "  3. 检查数据库是否已创建: CREATE DATABASE eduglobe_db;" -ForegroundColor White
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
