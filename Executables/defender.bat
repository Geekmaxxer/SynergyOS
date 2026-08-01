@echo off
setlocal enabledelayedexpansion

set "LOGDIR=C:\SynergyOS\Logs"
set "LOGFILE=%LOGDIR%\DisableDefenderServices.log"
set "MINSUDO=%windir%\MinSudo.exe"

if not exist "%LOGDIR%" mkdir "%LOGDIR%"


call :log "Starting Defender.bat"

for %%z in (
      MsSecCore
      MsSecFlt
      MsSecWfp
      SecurityHealthService
      Sense
      WdBoot
      WdFilter
      WdNisDrv
      WdNisSvc
      WinDefend
      wscsvc
      MDCoreSvc
      SgrmAgent
      SgrmBroker
      webthreatdefsvc
      webthreatdefusersvc
) do (
    call :log "Processing service: %%z"
    "%MINSUDO%" --NoLogo --TrustedInstaller --Privileged cmd /c "Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%%z" /v "Start" /t REG_DWORD /d "4" /f" >> "%LOGFILE%" 2>&1
    if !errorlevel! equ 0 (
        call :log "  SUCCESS: %%z set to Start=4"
    ) else (
        call :log "  ERROR: %%z failed with exit code !errorlevel!"
    )
)

call :log "Completed DisableDefenderServices.bat"


endlocal
exit /b 0

:log
echo %~1
echo [%date% %time%] %~1 >> "%LOGFILE%"
exit /b 0