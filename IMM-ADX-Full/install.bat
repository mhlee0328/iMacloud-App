@echo off
chcp 65001
echo.
rem 確認 Docker Engine Daemon 運行後再執行以下動作
echo 正在確認 Docker Desktop CE 服務運行狀態中  . . .

rem 以下兩行給 Win11預覽版 WSL Disable 需要排除 ERROR: error during connect: Get "http://host.docker.internal:2375/v1.24/info": dial tcp 172.20.10.2:2375: connectex: No connection could be made because the target machine actively refused it.
rem Remove-Item Env:\DOCKER_HOST 
rem $env:DOCKER_HOST="tcp://localhost:2375"
docker info > nul 2>&1  
if %errorlevel% neq 0 (
    echo.
    echo.
    echo.
    rem 設置文字顏色為紅色
    color 4
    echo IMM-ADX-Full 的 App 安裝失敗 ! ! !
    rem 還原文字顏色為默認
    color
    echo.
    echo 請先啟動您的 Docker Desktop CE 服務。Docker Engine Daemon 未運行或未正確安裝。
    echo.
    echo.
    echo.
    pause
    exit /b 1
)



rem 過濾 Name: docker-desktop
echo 確認 Docker Desktop CE 服務運行狀態中  . . .
docker info | findstr /C:"Name: docker-desktop" > nul 2>&1  
if %errorlevel% neq 0 (
    echo.
    echo.
    echo.
    rem 設置文字顏色為紅色
    color 4
    echo IMM-ADX-Full 的 App 安裝失敗 ! ! !
    rem 還原文字顏色為默認
    color
    echo.
    echo 請先啟動您的 Docker Desktop CE 服務。echo Docker Engine Daemon 未運行在 Docker Desktop CE 上。
    echo.
    echo.
    echo.
    pause
    exit /b 1
)



rem 還原文字顏色為默認
color
for /F "tokens=1" %%A in ('docker ps ^| findstr "IMM-"') do docker stop %%A
for /F "tokens=1" %%B in ('docker ps ^| findstr "IMM-"') do docker rm %%B

start "進行IMM-容器化安裝" /wait cmd /c docker-compose -f .\apps\IMM-ADX-Full\docker-compose.full.yaml up -d

start chrome "https://localhost:8880/"
exit /b