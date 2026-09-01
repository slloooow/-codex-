$ErrorActionPreference = 'Stop'

$packageDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceExe = Join-Path $packageDir 'CodexQuotaPet.exe'
$installDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CodexQuotaPet'
$installedExe = Join-Path $installDir 'CodexQuotaPet.exe'
$desktop = [Environment]::GetFolderPath('DesktopDirectory')
$shortcutPath = Join-Path $desktop 'Codex 额度桌宠.lnk'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'

if (-not (Test-Path -LiteralPath $sourceExe)) {
    throw "Missing package executable: $sourceExe"
}

$runningPets = @(Get-Process -Name 'CodexQuotaPet' -ErrorAction SilentlyContinue)
foreach ($runningPet in $runningPets) {
    $runningPet.Kill()
    if (-not $runningPet.WaitForExit(5000)) {
        throw "Could not stop the existing Codex quota pet process: $($runningPet.Id)"
    }
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item -LiteralPath $sourceExe -Destination $installedExe -Force

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $installedExe
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "$installedExe,0"
$shortcut.Description = '实时显示 Codex 当前最短额度窗口'
$shortcut.Save()

New-Item -Path $runKey -Force | Out-Null
Set-ItemProperty -LiteralPath $runKey -Name 'CodexQuotaPet' -Value ('"' + $installedExe + '"')

Start-Process -FilePath $installedExe

[pscustomobject]@{
    InstalledExe = $installedExe
    DesktopShortcut = $shortcutPath
    AutoStart = $true
}
