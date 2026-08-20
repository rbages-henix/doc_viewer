@echo off
chcp 65001 > nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch-doc.ps1"

:: Si une erreur survient, on garde la fenetre ouverte
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Le script s'est arrete suite a une erreur.
    pause
)