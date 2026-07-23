@echo off

setlocal EnableDelayedExpansion

:: ── Kill Defender / SmartScreen processes ───────────────────────────────────
taskkill /f /im NisSrv.exe >nul 2>&1
taskkill /f /im SecurityHealthHost.exe >nul 2>&1
taskkill /f /im SecurityHealthService.exe >nul 2>&1
taskkill /f /im SecurityHealthSystray.exe >nul 2>&1
taskkill /f /im SkypeBackgroundHost.exe >nul 2>&1
taskkill /f /im MsMpEng.exe >nul 2>&1
taskkill /f /im msiexec.exe >nul 2>&1
taskkill /f /im smartscreen.exe >nul 2>&1

:: ── Disable UAC File Virtualization ─────────────────────────────────────────
sc config luafv start= disabled >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\luafv" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1

:: ── Policy / SmartScreen / Spynet / HVCI ────────────────────────────────────
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "ServiceEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1

:: ── Disable Defender services  ────────
for %%S in (
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
    sc stop %%S >nul 2>&1
    sc config %%S start= disabled >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%S" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
)

:: ── Remove startup entries ──────────────────────────────────────────────────
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f >nul 2>&1

:: ── Remove Update Health / CMU leftovers ────────────────────────────────────
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\UpdateHealthTools" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\rempl" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\CloudManagedUpdate" /f >nul 2>&1

:: ── Remove Defender Explorer context menus ──────────────────────────────────
reg delete "HKLM\SOFTWARE\Classes\*\ShellEx\ContextMenuHandlers\EPP" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\Drive\ShellEx\ContextMenuHandlers\EPP" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\Directory\ShellEx\ContextMenuHandlers\EPP" /f >nul 2>&1

:: ── Remove SecurityHealth / SmartScreen binaries ────────────────────────────
del /f /q "%windir%\System32\SecurityHealthSystray.exe" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthService.exe" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthAgent.dll" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthHost.exe" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthSSO.dll" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthCore.dll" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthProxyStub.dll" >nul 2>&1
del /f /q "%windir%\System32\SecurityHealthUdk.dll" >nul 2>&1
del /f /q "%windir%\System32\smartscreen.exe" >nul 2>&1
del /f /q "%windir%\System32\smartscreenps.dll" >nul 2>&1
del /f /q "%windir%\System32\drivers\WdNisDrv.sys" >nul 2>&1

:: ── Remove Defender / ATP / Update Health folders ───────────────────────────
rmdir /s /q "%ProgramW6432%\Windows Defender Advanced Threat Protection" >nul 2>&1
rmdir /s /q "%ProgramW6432%\Windows Defender" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Windows Defender" >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft\Windows Defender" >nul 2>&1
rmdir /s /q "%SystemDrive%\ProgramData\Microsoft\Windows Defender Advanced Threat Protection" >nul 2>&1
rmdir /s /q "%ProgramW6432%\Microsoft Update Health Tools" >nul 2>&1
rmdir /s /q "%ProgramW6432%\PCHealthCheck" >nul 2>&1

:: ── Delete Defender scheduled tasks ─────────────────────────────────────────
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /f >nul 2>&1
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /f >nul 2>&1
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /f >nul 2>&1
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /f >nul 2>&1

:: ── Remove Security Health UI / App Reputation AppX ─────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-AppxPackage -AllUsers '*SecHealthUI*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; " ^
  "Get-AppxPackage -AllUsers 'Microsoft.Windows.Apprep.ChxApp*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; " ^
  "Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*SecHealthUI*' -or $_.DisplayName -like 'Microsoft.Windows.Apprep.ChxApp*' } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" >nul 2>&1

:: ── Disable Defender definitions feature ────────────────────────────────────
DISM.exe /Online /Disable-Feature /FeatureName:"Windows-Defender-Default-Definitions" /NoRestart >nul 2>&1

echo Done. Reboot recommended.
endlocal
exit /b 0
