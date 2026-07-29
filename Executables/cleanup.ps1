$foldersToRemove = @(
    "CbsTemp",
    "Logs",
    "SoftwareDistribution",
    "System32\LogFiles",
    # was "System32\LogFiles\WMI," - the comma sat inside the quotes, so this entry
    # was a path that could never match and the folder was never actually cleared.
    "System32\LogFiles\WMI",
    "System32\SleepStudy",
    "System32\sru",
    "System32\WDI\LogFiles",
    # System32\winevt\Logs removed: that is the Windows event log store. Wiping it
    # destroys Application/System/Security history, which is the first thing anyone
    # looks at when they need to diagnose a problem on the resulting install.
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
# was "HKCU\..." with no drive colon, so this silently did nothing. The duplicate of
# this same call at the bottom of the file already uses the correct HKCU:\ form.
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name "Config" -Force -ErrorAction SilentlyContinue

Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory |
    Where-Object { $_.Name -match "Microsoft.Windows.StartMenuExperienceHost" } |
    ForEach-Object {
        Remove-Item "$env:LOCALAPPDATA\Packages\$($_.Name)\LocalState" -Recurse -Force -ErrorAction SilentlyContinue
    }

Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "start.tilegrid" } |
    Remove-Item -Force
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name Config -Force -ErrorAction SilentlyContinue
