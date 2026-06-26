# SynergyOS Fix for Slow App Opening on Win11 25H2
# Debug Session: e5fb1c - Post-fix verification

$logFile = "$env:USERPROFILE\Desktop\debug-e5fb1c.log"

# #region agent log
function Send-DebugLog {
    param([string]$Location, [string]$Message, [hashtable]$Data, [string]$HypothesisId)
    $payload = @{
        sessionId = 'e5fb1c'
        runId = 'post-fix'
        location = $Location
        message = $Message
        data = $Data
        hypothesisId = $HypothesisId
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    } | ConvertTo-Json -Compress
    Add-Content -Path $logFile -Value $payload -Encoding UTF8
}
# #endregion

Write-Host "=== SynergyOS Slow App Fix ===" -ForegroundColor Cyan
Write-Host "Applying fixes for Windows 11 25H2..." -ForegroundColor Yellow

# Fix A: Re-enable SysMain (Superfetch)
Write-Host "`n[A] Enabling SysMain (Superfetch)..." -ForegroundColor White
try {
    Set-Service -Name 'sysmain' -StartupType Automatic -ErrorAction Stop
    Start-Service -Name 'sysmain' -ErrorAction Stop
    $sysmain = Get-Service -Name 'sysmain'
    Send-DebugLog -Location 'fix:HypA' -Message 'SysMain fixed' -Data @{Status=$sysmain.Status.ToString();StartType=$sysmain.StartType.ToString()} -HypothesisId 'A'
    Write-Host "    SysMain: $($sysmain.Status)/$($sysmain.StartType)" -ForegroundColor Green
} catch {
    Write-Host "    Failed: $_" -ForegroundColor Red
    Send-DebugLog -Location 'fix:HypA' -Message 'SysMain fix failed' -Data @{Error=$_.ToString()} -HypothesisId 'A'
}

# Fix B: Re-enable Memory Compression
Write-Host "`n[B] Enabling Memory Compression..." -ForegroundColor White
try {
    Enable-MMAgent -MemoryCompression -ErrorAction Stop
    $mmAgent = Get-MMAgent
    Send-DebugLog -Location 'fix:HypB' -Message 'MemComp fixed' -Data @{MemoryCompression=$mmAgent.MemoryCompression.ToString()} -HypothesisId 'B'
    Write-Host "    Memory Compression: $($mmAgent.MemoryCompression)" -ForegroundColor Green
} catch {
    Write-Host "    Failed: $_" -ForegroundColor Red
    Send-DebugLog -Location 'fix:HypB' -Message 'MemComp fix failed' -Data @{Error=$_.ToString()} -HypothesisId 'B'
}

# Fix D: Re-enable Windows Search
Write-Host "`n[D] Enabling Windows Search..." -ForegroundColor White
try {
    Set-Service -Name 'wsearch' -StartupType Automatic -ErrorAction Stop
    Start-Service -Name 'wsearch' -ErrorAction Stop
    $wsearch = Get-Service -Name 'wsearch'
    Send-DebugLog -Location 'fix:HypD' -Message 'WSearch fixed' -Data @{Status=$wsearch.Status.ToString();StartType=$wsearch.StartType.ToString()} -HypothesisId 'D'
    Write-Host "    Windows Search: $($wsearch.Status)/$($wsearch.StartType)" -ForegroundColor Green
} catch {
    Write-Host "    Failed: $_" -ForegroundColor Red
    Send-DebugLog -Location 'fix:HypD' -Message 'WSearch fix failed' -Data @{Error=$_.ToString()} -HypothesisId 'D'
}

# Fix E: Note about StartExperiencesApp
Write-Host "`n[E] StartExperiencesApp..." -ForegroundColor White
$startExpPkg = Get-AppxPackage -Name '*StartExperiencesApp*' -ErrorAction SilentlyContinue
if ($startExpPkg) {
    Write-Host "    Already installed" -ForegroundColor Green
    Send-DebugLog -Location 'fix:HypE' -Message 'StartExp present' -Data @{State='Installed'} -HypothesisId 'E'
} else {
    Write-Host "    REMOVED - Requires Windows repair or reinstall to restore" -ForegroundColor Yellow
    Write-Host "    Run: DISM /Online /Cleanup-Image /RestoreHealth" -ForegroundColor Yellow
    Send-DebugLog -Location 'fix:HypE' -Message 'StartExp missing' -Data @{State='Removed';Note='Requires DISM repair'} -HypothesisId 'E'
}

Write-Host "`n=== Fix Applied ===" -ForegroundColor Cyan
Write-Host "Please RESTART your PC for changes to take full effect." -ForegroundColor Yellow
Write-Host "After restart, test app opening speed." -ForegroundColor Yellow

# Print summary
Write-Host "`n--- COPY THIS SUMMARY ---" -ForegroundColor Magenta
$sysmainNow = Get-Service -Name 'sysmain' -EA SilentlyContinue
$wsearchNow = Get-Service -Name 'wsearch' -EA SilentlyContinue
$mmAgentNow = Get-MMAgent -EA SilentlyContinue
Write-Host "[POST-FIX] SysMain:$($sysmainNow.Status)/$($sysmainNow.StartType) | MemComp:$($mmAgentNow.MemoryCompression) | WSearch:$($wsearchNow.Status)/$($wsearchNow.StartType) | StartExp:$(if($startExpPkg){'OK'}else{'NeedsRepair'})"
Write-Host "--- END SUMMARY ---" -ForegroundColor Magenta
