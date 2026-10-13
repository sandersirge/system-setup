# 06 — Oh My Posh (themes, auto-upgrade, segments, fixes)

One prompt engine and one set of theme files for PowerShell, cmd, Git Bash and five WSL distros
(Fedora uses Powerlevel10k, [07](07-oh-my-zsh-powerlevel10k.md)).

## Install

| Where | Command |
|---|---|
| Windows | `winget install JanDeDobbeleer.OhMyPosh` (→ `%LOCALAPPDATA%\Programs\oh-my-posh`) |
| WSL distro | `bash scripts/wsl/install-oh-my-posh.sh` (→ `~/.local/bin/oh-my-posh`) |

The WSL script runs the official installer and falls back to the release binary when the
installer can't run (Fedora without `awk`):

```bash
curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
# fallback:
curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o ~/.local/bin/oh-my-posh
chmod +x ~/.local/bin/oh-my-posh
```

Init lines per shell:

| Shell | Init |
|---|---|
| PowerShell ([`$PROFILE`](01a-powershell-profile.md)) | `oh-my-posh init pwsh --config '<themes>\maxed_pc.omp.json' \| Invoke-Expression` |
| cmd (Clink lua) | `load(io.popen('oh-my-posh init cmd --config <themes>/maxed_pc.omp.json'):read('*a'))()` |
| Git Bash | `eval "$(oh-my-posh init bash --config '<themes>/maxed_bash_pc.omp.json')"` |
| WSL zsh | `eval "$(oh-my-posh init zsh --config /mnt/c/Users/<you>/AppData/Local/Programs/oh-my-posh/themes/maxed_pc.omp.json)"` |

## Themes in this repo

[`configs/oh-my-posh/themes/`](../configs/oh-my-posh/themes) → copy to
`%LOCALAPPDATA%\Programs\oh-my-posh\themes\` (`Install-WindowsShellConfig.ps1` does it).

| Theme | Used by | Notes |
|---|---|---|
| `maxed_pc.omp.json` | PowerShell, cmd, WSL zsh | desktop PC version: no battery segment |
| `maxed_bash_pc.omp.json` | Git Bash | same, with box-drawing frame (`╭─`, `─╮`, `─╯`) |
| `maxed.omp.json` / `maxed_bash.omp.json` | laptops | originals with the battery segment |

### How the `_pc` variants were made

1. Copied `maxed` → `maxed_pc` and `maxed_bash` → `maxed_bash_pc`.
2. Removed the `battery` segment (a desktop PC has no battery: Oh My Posh logs `no battery`, and
   `powercfg /batteryreport` says *No batteries*; the segment just stays hidden anyway).
3. Kept the **powerline arrow** between CPU/RAM (`sysinfo`) and Wi-Fi (`connection`): the
   `connection` segment stays `"style": "powerline"` with `"powerline_symbol": ""`.
4. Added a **round end cap** after it. A powerline segment ignores `trailing_diamond`, so the cap
   is its own plain `text` segment colored like the connection segment:

   ```json
   { "type": "text", "style": "plain", "foreground": "#14a3a8", "template": "" }
   ```

   In `maxed_bash_pc` the template is `"─╯"` to keep the frame corner.
   (The cap stays visible when the Wi-Fi segment is hidden, e.g. offline or in WSL.)

## Auto-upgrade

Set in the top-level `upgrade` block of the `_pc` themes (the originals keep `"auto": false`,
`"notice": true`). Docs: <https://ohmyposh.dev/docs/installation/upgrade>

```json
"upgrade": {
  "source": "cdn",
  "interval": "168h",
  "auto": true,
  "notice": false
}
```

| Key | Meaning |
|---|---|
| `auto` | install updates automatically (never a new **major** version) |
| `notice` | only print a notice that an update exists |
| `interval` | how often to check (Go duration, default `24h`) |
| `source` | `cdn` or `github` |

Upgrade checks never run when `async` loading is enabled in the config. CLI alternatives:
`oh-my-posh enable upgrade`, manual `oh-my-posh upgrade`.

## Segments added for detected technologies

All placed on line 2 after `rust`, same style as the existing language segments
(`#1e2636` background, white text, brand-colored icon). Every glyph was checked against
JetBrainsMono Nerd Font.

| Segment | Icon | Color | Shows | Appears when |
|---|---|---|---|---|
| `docker` | `U+F308` | `#2496ed` | Docker context | `display_mode: files` → Dockerfile / compose file present |
| `npm` | `U+E71E` | `#cb3837` | npm version | `package-lock.json` |
| `pnpm` | `U+E865` | `#f9ad00` | version | `pnpm-lock.yaml` |
| `yarn` | `U+E6A7` | `#2c8ebb` | version | `yarn.lock` |
| `bun` | `U+E76F` | `#fbf0df` | version | bun lockfile (`bun.lockb`) |
| `aws` | `U+E7AD` | `#ff9900` | `profile@region` | named profile active (`display_default: false` hides `default`) |
| `kubectl` | `U+F10FE` | `#326ce5` | `context :: namespace` | `~/.kube/config` exists (**every folder**) |
| `terraform` | `U+F1062` | `#844fba` | workspace | `.terraform` / `main.tf`, and `terraform` installed |
| `php` | `U+E73D` | `#777bb4` | version | PHP files |
| `ruby` | `U+E739` | `#cc342d` | version | Ruby files |
| `lua` | `U+E620` | `#51a0cf` | version | Lua files |
| `cmake` | `U+E794` | `#008fba` | version | `CMakeLists.txt` |
| `kotlin` | `U+E634` | `#7f52ff` | version | Kotlin files |
| `dart` | `U+E798` | `#40c4ff` | version | `pubspec.yaml` / Dart files |

Already in the original theme: `git`, `node` (also shows nvm's active Node + npm/yarn icon),
`python` (+ venv), `java`, `go`, `dotnet`, `rust`. There is no separate TypeScript segment.

Notes:

- A segment for a tool that isn't installed still shows its icon, without a version.
- Version segments run `<tool> --version` in matching folders: npm costs ~370 ms per prompt,
  an empty folder ~25 ms.
- Segment docs: <https://ohmyposh.dev/docs/segments/cli/docker> (and the same path pattern for
  every segment).

## OS icon fix (Arch / Fedora showed Tux)

Oh My Posh reports Arch as `archlinux` and Fedora as `fedoralinux`, but its built-in icons are keyed
`arch` / `fedora`, so they fell back to Tux (`U+F17C`). Added to the `os` segment of all four themes:

```json
"options": {
  "archlinux": "",
  "fedoralinux": ""
}
```

See what a distro is detected as with a minimal probe theme (`{{ .OS }}` / `{{ .Icon }}`):

```json
{ "version": 3, "blocks": [ { "type": "prompt", "alignment": "left", "segments": [
  { "type": "os", "style": "plain", "template": "OS=[{{ .OS }}] ICON=[{{ .Icon }}]" } ] } ] }
```

```bash
oh-my-posh print primary --config probe.json --shell zsh
```

## Fixes and explanations

### `CONFIG PARSE ERROR` in the prompt

```text
failed to parse config: invalid character '﻿' looking for beginning of value
```

The theme file starts with a UTF-8 **BOM**. Strip it:

```powershell
.\scripts\windows\Remove-JsonBom.ps1 "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\maxed.omp.json"
```

Save JSON as "UTF-8" (no BOM). Windows PowerShell 5.1 `Set-Content -Encoding UTF8` adds one;
PowerShell 7 does not. Debug any config problem:

```powershell
oh-my-posh debug --config <theme.json> --shell pwsh
oh-my-posh config export --config <theme.json>     # parses and prints the config
```

### Red `9009` (cmd) / `127` (zsh) in the prompt

That is the **exit code of the last command**, shown by the `status` segment:
9009 = cmd "command not found" (e.g. `clear`, which is a Linux command — use `cls`),
127 = the same in zsh. `cls` does not reset it; the next successful command does.

### Battery segment missing

Correct on a desktop PC — Windows reports no battery. On a laptop: Device Manager → Batteries →
*Microsoft ACPI-Compliant Control Method Battery*; if missing, uninstall the device and reboot.

### Changes not visible

The config is read when the shell starts: open a new tab or reload (table in [01](01-windows-terminal-and-fonts.md#4-reloading-after-changes)).

### Editing themes with PowerShell

`ConvertFrom-Json` → edit → `ConvertTo-Json -Depth 50` keeps every glyph in PowerShell 7. Always
write UTF-8 **without** BOM:

```powershell
[IO.File]::WriteAllText($path, ($json | ConvertTo-Json -Depth 50), [Text.UTF8Encoding]::new($false))
```
