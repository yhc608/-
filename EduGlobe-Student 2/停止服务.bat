@echo off
chcp 65001 >nul
title EduGlobe 停止所有服务

echo ========================================
echo    EduGlobe 停止所有服务
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-all.ps1"

pause
