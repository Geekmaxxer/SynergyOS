@echo off
:: Virtualisation-based security teardown.
::
:: Gated behind the "Disable VBS / HVCI / Credential Guard" checkbox. This used to
:: run unconditionally from final.bat, which meant the SOS "Enable VBS" toggle could
:: never actually stick and users got Credential Guard and LSA Protection removed
:: without being asked.
::
:: RunAsPPL=0 is the significant one: LSA Protection is what prevents credential
:: dumping tools from reading the lsass process. Only disable it if you specifically
:: need to, e.g. for a debugger or an anti-cheat that refuses to run alongside it.

Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v "Enabled" /t REG_DWORD /d 0 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "Enabled" /t REG_DWORD /d 0 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /t REG_DWORD /d 0 /f
