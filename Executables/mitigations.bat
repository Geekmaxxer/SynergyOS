@echo off
:: Machine-wide exploit mitigation teardown. Opt-in only (unchecked by default).
::
:: The MitigationOptions mask below sets every nibble to 2 = "force OFF", which
:: disables DEP, bottom-up and high-entropy ASLR, SEHOP and heap termination for
:: every process on the system - not just games. Expect anti-cheat (EAC, BattlEye,
:: Vanguard) to refuse to launch with this applied.

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableControlFlowGuardExportSuppression" /t REG_BINARY /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableControlFlowGuardXFG" /t REG_BINARY /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_BINARY /d "1" /f

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "222222222222222222222222222222222222222222222222" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "000000000000000000000000000000000000000000000000" /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\FTH" /v Enabled /t REG_DWORD /d "0" /f

:: moved here from final.bat, where it ran unconditionally - this downgrades DEP
:: from AlwaysOn/OptOut to opt-in, which is a mitigation change like the rest.
bcdedit /set nx optin
