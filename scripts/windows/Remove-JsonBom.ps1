<#
.SYNOPSIS
  Strip the UTF-8 BOM from a JSON file (fixes Oh My Posh "CONFIG PARSE ERROR").

.DESCRIPTION
  Oh My Posh's JSON parser rejects a leading U+FEFF ("invalid character '﻿'
  looking for beginning of value"). Windows PowerShell 5.1 and some editors add it
  when saving as "UTF-8". This rewrites the file as UTF-8 without BOM, keeping a .bak copy.

.EXAMPLE
  .\Remove-JsonBom.ps1 "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\maxed.omp.json"
#>
param([Parameter(Mandatory)][string[]]$Path)

foreach ($p in $Path) {
    $bytes = [IO.File]::ReadAllBytes($p)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Copy-Item $p "$p.bak"
        $text = [IO.File]::ReadAllText($p).TrimStart([char]0xFEFF)
        [IO.File]::WriteAllText($p, $text, [Text.UTF8Encoding]::new($false))
        "BOM removed: $p (backup: $p.bak)"
    } else {
        "no BOM: $p"
    }
}
