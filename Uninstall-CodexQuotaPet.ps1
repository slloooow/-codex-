$ErrorActionPreference = 'Stop'

$installDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CodexQuotaPet'
$installedExe = Join-Path $installDir 'CodexQuotaPet.exe'
$desktop = [Environment]::GetFolderPath('DesktopDirectory')
$shortcutPath = Join-Path $desktop 'Codex 额度桌宠.lnk'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'

$resolvedLocal = [IO.Path]::GetFullPath([Environment]::GetFolderPath('LocalApplicationData')).TrimEnd('\') + '\'
$resolvedInstall = [IO.Path]::GetFullPath($installDir).TrimEnd('\') + '\'
if (-not $resolvedInstall.StartsWith($resolvedLocal, [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $installDir) -ne 'CodexQuotaPet') {
    throw "Refusing to remove unexpected directory: $installDir"
}

$runningPets = @(Get-Process -Name 'CodexQuotaPet' -ErrorAction SilentlyContinue)
foreach ($runningPet in $runningPets) {
    $runningPet.Kill()
    if (-not $runningPet.WaitForExit(5000)) {
        throw "Could not stop the Codex quota pet process: $($runningPet.Id)"
    }
}

if (Test-Path -LiteralPath $runKey) {
    Remove-ItemProperty -LiteralPath $runKey -Name 'CodexQuotaPet' -ErrorAction SilentlyContinue
}
Remove-Item -LiteralPath $shortcutPath -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $installDir -Recurse -Force -ErrorAction SilentlyContinue

[pscustomobject]@{
    RemovedInstallDirectory = $installDir
    RemovedDesktopShortcut = $shortcutPath
    RemovedAutoStart = $true
}
