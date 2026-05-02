@echo off
chcp 65001 >nul
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║     SafeLock — Deploy do Relay (uma vez só)         ║
echo  ╚══════════════════════════════════════════════════════╝
echo.
echo  Este script faz o deploy do servidor relay de forma
echo  semi-automática. Segue os passos abaixo.
echo.
echo  PASSO 1: Criar conta gratuita em render.com
echo  ─────────────────────────────────────────────────────
echo  Abre o browser e vai a:
echo.
echo    https://render.com/register
echo.
pause

echo.
echo  PASSO 2: Deploy do Relay Server
echo  ─────────────────────────────────────────────────────
echo  Clica no link abaixo para fazer deploy automático:
echo.
echo    https://render.com/deploy?repo=...
echo.
echo  OU faz manualmente:
echo    1. No Render: New → Web Service
echo    2. "Build and deploy from Git repository" → Public Git repo
echo    3. Ou arrasta a pasta safelock-relay/ para o Render
echo    4. Build Command: npm install
echo    5. Start Command: npm start
echo    6. Plan: Free
echo    7. Clica Create Web Service
echo.
echo  Aguarda 2-3 minutos e copia o URL (ex: https://xxx.onrender.com)
echo.
set /p RELAY_URL=  Cola aqui o URL do teu relay: 
echo.
echo  URL guardado: %RELAY_URL%
echo.
echo  Agora corre:  configure.bat
echo  e depois:     build-all.bat
echo.
:: Guardar URL para usar no configure.bat
echo set SAVED_RELAY_URL=%RELAY_URL% > .relay_url.bat
echo  [OK] URL guardado em .relay_url.bat
echo.
pause
