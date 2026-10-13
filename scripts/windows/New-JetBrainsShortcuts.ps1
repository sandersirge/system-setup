<#
.SYNOPSIS
  Create desktop shortcuts for JetBrains IDEs installed by JetBrains Toolbox.

.DESCRIPTION
  Searches %LOCALAPPDATA%\Programs recursively for each IDE's 64-bit launcher.
  Exactly one match -> creates/overwrites "<IDE>.lnk" on the desktop (target,
  working directory and icon set). No match -> "Not found". Several matches ->
  lists them and skips, so you can pick the right one by hand.
  Touches nothing but the desktop shortcuts.
#>
$ides = [ordered]@{
    'IntelliJ IDEA' = 'idea64.exe'
    'CLion'         = 'clion64.exe'
    'PyCharm'       = 'pycharm64.exe'
    'WebStorm'      = 'webstorm64.exe'
    'RustRover'     = 'rustrover64.exe'
}
$root    = Join-Path $env:LOCALAPPDATA 'Programs'
$desktop = [Environment]::GetFolderPath('Desktop')
$shell   = New-Object -ComObject WScript.Shell

foreach ($name in $ides.Keys) {
    $found = @(Get-ChildItem $root -Recurse -Filter $ides[$name] -File -ErrorAction SilentlyContinue)
    switch ($found.Count) {
        0 { "{0,-14} Not found" -f $name }
        1 {
            $exe = $found[0].FullName
            $lnk = $shell.CreateShortcut((Join-Path $desktop "$name.lnk"))
            $lnk.TargetPath       = $exe
            $lnk.WorkingDirectory = Split-Path $exe
            $lnk.IconLocation     = "$exe,0"
            $lnk.Save()
            "{0,-14} shortcut -> {1}" -f $name, $exe
        }
        default { "{0,-14} multiple installs, skipped:`n  {1}" -f $name, ($found.FullName -join "`n  ") }
    }
}
