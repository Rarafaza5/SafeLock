@echo off
echo.
echo  SafeLock -- Configuracao Inicial
echo  =================================
echo.
echo  Este script configura ambos os EXEs com os teus dados.
echo  So precisas de correr isto UMA VEZ antes de fazer o build.
echo.

:: Verificar Python
python --version >nul 2>&1
if errorlevel 1 (
    echo  [ERRO] Python nao encontrado.
    echo         Instala em: https://python.org/downloads
    pause & exit /b 1
)

echo  PASSO 1: Relay Server
echo  -------------------------------------------
echo  Vai a https://render.com e faz deploy de safelock-relay/
echo  Copia o URL que te e dado (ex: https://xxx.onrender.com)
echo.
set /p RELAY_URL=  URL do Relay: 

echo.
echo  PASSO 2: Seguranca
echo  -------------------------------------------
set /p ADMIN_PASS=  Palavra-passe do Admin (ex: MinhaSenha123): 
set /p RELAY_SECRET=  Segredo de comunicacao (qualquer texto secreto): 
set /p CLIENT_ID=  ID do cliente (ex: filho-joao) [ENTER para "safelock-client-01"]: 

if "%CLIENT_ID%"=="" set CLIENT_ID=safelock-client-01

echo.
echo  A configurar ficheiros...

:: Chamar o helper Python com os argumentos
python configure_helper.py "%RELAY_URL%" "%ADMIN_PASS%" "%RELAY_SECRET%" "%CLIENT_ID%"

if errorlevel 1 (
    echo.
    echo  [ERRO] Falha na configuracao. Ver mensagem acima.
    pause & exit /b 1
)

echo.
echo  =============================================
echo   Configuracao concluida com sucesso!
echo  =============================================
echo.
echo  Proximo passo: corre   build-all.bat
echo.
pause
