$foldersToRemove = @(
    "CbsTemp",
    "Logs",
    "SoftwareDistribution",
    "System32\LogFiles",
    "System32\LogFiles\WMI,"
    "System32\SleepStudy",
    "System32\sru",
    "System32\WDI\LogFiles",
    "System32\winevt\Logs",
    "SystemTemp",
    "Temp"

    # "WinSxS\Backup"
    # "Panther",
    # "Prefetch"
)

foreach ($folderName in $foldersToRemove) {
    $folderPath = Join-Path $env:SystemRoot $folderName
    if (Test-Path $folderPath) {
        Remove-Item -Path "$folderPath\*" -Force -Recurse | Out-Null
    }
}

Stop-Process -Name 'StartMenuExperienceHost' -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "Config" -Force -ErrorAction SilentlyContinue

Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory |
    Where-Object { $_.Name -match "Microsoft.Windows.StartMenuExperienceHost" } |
    ForEach-Object {
        Remove-Item "$env:LOCALAPPDATA\Packages\$($_.Name)\LocalState" -Recurse -Force -ErrorAction SilentlyContinue
    }

Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "start.tilegrid" } |
    Remove-Item -Force
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name Config -Force -ErrorAction SilentlyContinue
