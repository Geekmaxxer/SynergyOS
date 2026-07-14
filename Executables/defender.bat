@echo off
:: disable defender

taskkill /f /im NisSrv.exe
taskkill /f /im SecurityHealthHost.exe
taskkill /f /im SecurityHealthService.exe
taskkill /f /im SecurityHealthSystray.exe
taskkill /f /im SkypeBackgroundHost.exe
taskkill /f /im MsMpEng.exe
taskkill /f /im msiexec.exe
taskkill /f /im smartscreen.exe

sc config luafv start= disabled

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "ServiceEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_SZ /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d 0 /f

reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Sense" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MsSecCore" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\wscsvc" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MsSecWfp" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MsSecFlt" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\wtd" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\UpdateHealthTools" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\rempl" /f
reg delete "HKLM\SOFTWARE\Microsoft\CloudManagedUpdate" /f
reg delete "HKLM\SOFTWARE\Classes\*\ShellEx\ContextMenuHandlers\EPP" /f
reg delete "HKLM\SOFTWARE\Classes\Drive\ShellEx\ContextMenuHandlers\EPP" /f
reg delete "HKLM\SOFTWARE\Classes\Directory\ShellEx\ContextMenuHandlers\EPP" /f

del /f /q "%windir%\System32\SecurityHealthSystray.exe"
del /f /q "%windir%\System32\SecurityHealthService.exe"
del /f /q "%windir%\System32\SecurityHealthAgent.dll"
del /f /q "%windir%\System32\SecurityHealthHost.exe"
del /f /q "%windir%\System32\SecurityHealthSSO.dll"
del /f /q "%windir%\System32\SecurityHealthCore.dll"
del /f /q "%windir%\System32\SecurityHealthProxyStub.dll"
del /f /q "%windir%\System32\SecurityHealthUdk.dll"
rmdir /s /q "%ProgramW6432%\Windows Defender Advanced Threat Protection"
rmdir /s /q "%ProgramW6432%\Windows Defender"
rmdir /s /q "%PROGRAMFILES(x86)%\Windows Defender"
rmdir /s /q "%ProgramData%\Microsoft\Windows Defender"
del /f /q "%windir%\System32\drivers\WdNisDrv.sys"
rmdir /s /q "%SystemDrive%\ProgramData\Microsoft\Windows Defender Advanced Threat Protection"
rmdir /s /q "%ProgramW6432%\Microsoft Update Health Tools"
rmdir /s /q "%ProgramW6432%\PCHealthCheck"
del /f /q "%windir%\System32\smartscreen.exe"
del /f /q "%windir%\System32\smartscreenps.dll"

schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /f
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /f
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /f
schtasks /delete /tn "\Microsoft\Windows\Windows Defender\Windows Defende
