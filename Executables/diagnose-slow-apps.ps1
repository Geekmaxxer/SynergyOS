# SynergyOS App Launch Diagnostics
# Debug Session: e5fb1c

$logFile = "$env:USERPROFILE\Desktop\debug-e5fb1c.log"
$sessionId = 'e5fb1c'

# #region agent log
function Send-DebugLog {
    param([string]$Location, [string]$Message, [hashtable]$Data, [string]$HypothesisId)
    $payload = @{
        sessionId = $sessionId
        location = $Location
        message = $Message
        data = $Data
        hypothesisId = $HypothesisId
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logFile -Value $payload -Encoding UTF8
}
# #endregion

Write-Host "=== SynergyOS App Launch Diagnostics ===" -ForegroundColor Cyan
Write-Host "Collecting system state data..." -ForegroundColor Yellow

# Hypothesis A: Check SysMain service state
$sysmain = Get-Service -Name 'sysmain' -ErrorAction SilentlyContinue
$sysmainState = if ($sysmain) { @{Status = $sysmain.Status.ToString(); StartType = $sysmain.StartType.ToString()} } else { @{Status = 'NotFound'; StartType = 'N/A'} }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:HypA' -Message 'SysMain service state' -Data $sysmainState -HypothesisId 'A'
Write-Host "[A] SysMain: Status=$($sysmainState.Status), StartType=$($sysmainState.StartType)" -ForegroundColor $(if ($sysmainState.StartType -eq 'Disabled') {'Red'} else {'Green'})

# Hypothesis B: Check Memory Compression state
$mmAgent = Get-MMAgent -ErrorAction SilentlyContinue
$memCompression = if ($mmAgent) { $mmAgent.MemoryCompression } else { 'Unknown' }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:HypB' -Message 'Memory Compression state' -Data @{MemoryCompression = $memCompression.ToString()} -HypothesisId 'B'
Write-Host "[B] Memory Compression: $memCompression" -ForegroundColor $(if ($memCompression -eq $false) {'Red'} else {'Green'})

# Hypothesis C: Check Background Apps state
$bgAppsKey = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
$globalUserDisabled = (Get-ItemProperty -Path $bgAppsKey -Name 'GlobalUserDisabled' -ErrorAction SilentlyContinue).GlobalUserDisabled
$bgAppsState = if ($globalUserDisabled -eq 1) { 'Disabled' } elseif ($globalUserDisabled -eq 0) { 'Enabled' } else { 'Default/NotSet' }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:HypC' -Message 'Background Apps state' -Data @{GlobalUserDisabled = $globalUserDisabled; State = $bgAppsState} -HypothesisId 'C'
Write-Host "[C] Background Apps: $bgAppsState (GlobalUserDisabled=$globalUserDisabled)" -ForegroundColor $(if ($globalUserDisabled -eq 1) {'Red'} else {'Green'})

# Hypothesis D: Check Windows Search service state
$wsearch = Get-Service -Name 'wsearch' -ErrorAction SilentlyContinue
$wsearchState = if ($wsearch) { @{Status = $wsearch.Status.ToString(); StartType = $wsearch.StartType.ToString()} } else { @{Status = 'NotFound'; StartType = 'N/A'} }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:HypD' -Message 'Windows Search service state' -Data $wsearchState -HypothesisId 'D'
Write-Host "[D] Windows Search: Status=$($wsearchState.Status), StartType=$($wsearchState.StartType)" -ForegroundColor $(if ($wsearchState.StartType -eq 'Disabled') {'Red'} else {'Green'})

# Hypothesis E: Check StartExperiencesApp package presence
$startExpPkg = Get-AppxPackage -Name '*StartExperiencesApp*' -ErrorAction SilentlyContinue
$startExpState = if ($startExpPkg) { 'Installed' } else { 'Removed' }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:HypE' -Message 'StartExperiencesApp package state' -Data @{State = $startExpState; PackageName = $(if ($startExpPkg) { $startExpPkg.Name } else { 'N/A' })} -HypothesisId 'E'
Write-Host "[E] StartExperiencesApp: $startExpState" -ForegroundColor $(if ($startExpState -eq 'Removed') {'Red'} else {'Green'})

# Additional context: Check Prefetch state
$prefetchEnabled = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' -Name 'EnablePrefetcher' -ErrorAction SilentlyContinue).EnablePrefetcher
$prefetchState = switch ($prefetchEnabled) { 0 {'Disabled'} 1 {'Apps Only'} 2 {'Boot Only'} 3 {'Full'} default {'Unknown'} }
Send-DebugLog -Location 'diagnose-slow-apps.ps1:Prefetch' -Message 'Prefetch state' -Data @{EnablePrefetcher = $prefetchEnabled; State = $prefetchState} -HypothesisId 'Context'
Write-Host "[+] Prefetch: $prefetchState (Value=$prefetchEnabled)" -ForegroundColor $(if ($prefetchEnabled -lt 3) {'Yellow'} else {'Green'})

# Additional context: Check Superfetch state in registry
$superfetchEnabled = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' -Name 'EnableSuperfetch' -ErrorAction SilentlyContinue).EnableSuperfetch
Send-DebugLog -Location 'diagnose-slow-apps.ps1:Superfetch' -Message 'Superfetch registry state' -Data @{EnableSuperfetch = $superfetchEnabled} -HypothesisId 'Context'
Write-Host "[+] Superfetch Registry: Value=$superfetchEnabled" -ForegroundColor $(if ($superfetchEnabled -eq 0) {'Yellow'} else {'Green'})

# Check maintenance state
$maintenanceDisabled = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance' -Name 'MaintenanceDisabled' -ErrorAction SilentlyContinue).MaintenanceDisabled
Send-DebugLog -Location 'diagnose-slow-apps.ps1:Maintenance' -Message 'Maintenance state' -Data @{MaintenanceDisabled = $maintenanceDisabled} -HypothesisId 'Context'
Write-Host "[+] System Maintenance: $(if ($maintenanceDisabled -eq 1) {'Disabled'} else {'Enabled'})" -ForegroundColor $(if ($maintenanceDisabled -eq 1) {'Yellow'} else {'Green'})

# Check Windows version
$buildNumber = [System.Environment]::OSVersion.Version.Build
$isW11_25H2 = $buildNumber -ge 26100
Send-DebugLog -Location 'diagnose-slow-apps.ps1:Version' -Message 'Windows version' -Data @{Build = $buildNumber; Is25H2 = $isW11_25H2} -HypothesisId 'Context'
Write-Host "[+] Windows Build: $buildNumber (25H2: $isW11_25H2)" -ForegroundColor Cyan

Write-Host "`n=== Diagnostics Complete ===" -ForegroundColor Cyan
Write-Host "Log file written to: $logFile" -ForegroundColor Yellow

# Print plain text summary for easy copy/paste
Write-Host "`n--- COPY THIS SUMMARY ---" -ForegroundColor Magenta
$summary = @"
[DIAGNOSTIC RESULTS]
Build: $buildNumber
SysMain: $($sysmainState.Status)/$($sysmainState.StartType)
MemoryCompression: $memCompression
BackgroundApps: $bgAppsState
WindowsSearch: $($wsearchState.Status)/$($wsearchState.StartType)
StartExperiencesApp: $startExpState
Prefetch: $prefetchState
Maintenance: $(if ($maintenanceDisabled -eq 1) {'Disabled'} else {'Enabled'})
"@
Write-Host $summary
Write-Host "--- END SUMMARY ---" -ForegroundColor Magenta
