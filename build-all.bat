@echo off
echo.
echo  SafeLock -- Build Completo
echo  ==========================
echo  Este script gera os 2 instaladores .exe finais.
echo  Certifica-te de que correste configure.bat primeiro!
echo.

if not exist "output" mkdir output

:: ==========================================
::  PARTE 1 -- Agent (Python -> .exe)
:: ==========================================
echo  [1/2] A compilar SafeLock Agent...
echo  ------------------------------------------
cd safelock-agent

python --version >nul 2>&1
if errorlevel 1 (
    echo  [ERRO] Python nao encontrado. Instala Python 3.11+ em python.org
    cd .. & pause & exit /b 1
)

echo  A instalar dependencias Python...
python -m pip install -r requirements.txt -q
python -m pip install pyinstaller -q

echo  A compilar SafeLockService.exe...
python -m PyInstaller --onefile --noconsole --name SafeLockService ^
  --hidden-import win32timezone ^
  --hidden-import win32service ^
  --hidden-import win32serviceutil ^
  --hidden-import win32event ^
  --hidden-import servicemanager ^
  --hidden-import pywintypes ^
  --hidden-import engineio.async_drivers.threading ^
  --hidden-import socketio ^
  --hidden-import psutil ^
  --add-data "config.py;." ^
  --add-data "modules;modules" ^
  agent_service.py >build_service.log 2>&1

if errorlevel 1 (
    echo  [ERRO] Falha em SafeLockService.exe - ver build_service.log
    cd .. & pause & exit /b 1
)

echo  A compilar SafeLockUI.exe...
python -m PyInstaller --onefile --noconsole --name SafeLockUI ^
  --hidden-import engineio.async_drivers.threading ^
  --add-data "config.py;." ^
  --add-data "modules;modules" ^
  safelock_ui.py >build_ui.log 2>&1

if errorlevel 1 (
    echo  [ERRO] Falha em SafeLockUI.exe - ver build_ui.log
    cd .. & pause & exit /b 1
)

if not exist installer\bin mkdir installer\bin
copy /Y dist\SafeLockService.exe installer\bin\ >nul
copy /Y dist\SafeLockUI.exe installer\bin\ >nul
echo  [OK] Executaveis compilados.

:: Tentar Inno Setup
set ISCC=
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if exist "C:\Program Files\Inno Setup 6\ISCC.exe"       set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
if exist "C:\Program Files\Inno Setup 7\ISCC.exe"       set ISCC="C:\Program Files\Inno Setup 7\ISCC.exe"
if exist "C:\Program Files (x86)\Inno Setup 7\ISCC.exe" set ISCC="C:\Program Files (x86)\Inno Setup 7\ISCC.exe"
if exist "%LocalAppData%\Programs\Inno Setup 6\ISCC.exe" set ISCC="%LocalAppData%\Programs\Inno Setup 6\ISCC.exe"
if exist "%LocalAppData%\Programs\Inno Setup 7\ISCC.exe" set ISCC="%LocalAppData%\Programs\Inno Setup 7\ISCC.exe"

if defined ISCC (
    echo  A gerar instalador do Agent com Inno Setup...
    if not exist installer\output mkdir installer\output
    %ISCC% installer\setup.iss /Q
    if errorlevel 1 (
        echo  [AVISO] Inno Setup falhou. Verifica setup.iss
    ) else (
        copy /Y installer\output\SafeLockAgent-Setup.exe ..\output\ >nul
        echo  [OK] SafeLockAgent-Setup.exe gerado!
    )
) else (
    echo  [AVISO] Inno Setup nao encontrado.
    echo          Instala em: https://jrsoftware.org/isdl.php
    echo          Depois abre: safelock-agent\installer\setup.iss
)

cd ..

:: ==========================================
::  PARTE 2 -- Admin (Electron -> .exe)
:: ==========================================
echo.
echo  [2/2] A compilar SafeLock Admin...
echo  ------------------------------------------
cd safelock-admin

node --version >nul 2>&1
if errorlevel 1 (
    echo  [ERRO] Node.js nao encontrado. Instala em: https://nodejs.org
    cd .. & pause & exit /b 1
)

echo  A instalar dependencias Node...
call npm install --silent
if errorlevel 1 (
    echo  [ERRO] npm install falhou
    cd .. & pause & exit /b 1
)

echo  A compilar app Electron...
call npm run build
if errorlevel 1 (
    echo  [ERRO] Build do Admin falhou
    cd .. & pause & exit /b 1
)

for /r dist-electron %%f in (*Setup*.exe) do (
    copy /Y "%%f" ..\output\ >nul
    echo  [OK] %%~nxf gerado!
)

cd ..

:: ==========================================
::  RESULTADO
:: ==========================================
echo.
echo  =============================================
echo   Build concluido!
echo  =============================================
echo.
echo  Os teus 2 instaladores estao em: output\
echo.
dir /b output\*.exe 2>nul
echo.
echo  INSTALA NO TEU PC:       "SafeLock Admin Setup.exe"
echo  INSTALA NO PC DO FILHO:  "SafeLockAgent-Setup.exe"
echo.
pause
