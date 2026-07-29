@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for %%i in (
  EnhancedPowerManagementEnabled
  AllowIdleIrpInD3
  EnableSelectiveSuspend 
  DeviceSelectiveSuspended
  SelectiveSuspendEnabled 
  SelectiveSuspendOn 
  EnumerationRetryCount 
  ExtPropDescSemaphore 
  WaitWakeEnabled
  D3ColdSupported 
  WdfDirectedPowerTransitionEnable 
  EnableIdlePowerManagement 
  IdleInWorkingState
) do for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%i"^| findstr "HKEY"') do Reg add "%%a" /v "%%i" /t REG_DWORD /d "0" /f  

powercfg /h off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "SleepStudyDisabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoalescingFlushInterval" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "FxAccountingTelemetryDisabled" /t REG_DWORD /d "1" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "MSDisabled" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformRoleOverride" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\usbflags" /v "DisableHCS0Idle" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\usbflags" /v "Allow64KLowOrFullSpeedControlTransfers" /t REG_DWORD /d "1" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "IdlePowerMode" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "DisableDSTThrottle" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Storage" /v "StorageD3InModernStandby" /t REG_DWORD /d "0" /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\WmiAcpi" /v "Start" /t REG_DWORD /d "4" /f

powershell -nop -noni -exec bypass -c "Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | ForEach-Object { $_.enable = $false; $_.psbase.put(); }"
:: Import the SynergyOS power plan, and only remove the built-in plans once it is
:: confirmed active. Previously the three built-ins were deleted unconditionally, so
:: a missing or unreadable sos.pow left the machine with no power plan at all.
powercfg -delete 77777777-7777-7777-7777-777777777777 >nul 2>&1

if not exist "%WinDir%\sos.pow" (
    echo [power.bat] sos.pow not found in %WinDir% - keeping the built-in power plans.
    goto :skipplans
)

powercfg -import "%WinDir%\sos.pow" 77777777-7777-7777-7777-777777777777
if errorlevel 1 (
    echo [power.bat] Failed to import sos.pow - keeping the built-in power plans.
    goto :skipplans
)

powercfg -setactive 77777777-7777-7777-7777-777777777777
if errorlevel 1 (
    echo [power.bat] Failed to activate the SynergyOS plan - keeping the built-in power plans.
    goto :skipplans
)

powercfg -delete 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg -delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -delete a1841308-3541-4fab-bc81-f71556f20b4a

:skipplans
