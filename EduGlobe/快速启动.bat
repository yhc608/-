@echo off
chcp 65001 >nul
title EduGlobe 一键启动

echo ========================================
echo    EduGlobe 一键启动
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-all.ps1"

pause
