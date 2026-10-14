# 15 — Installed apps on this computer

The Windows desktop and taskbar apps, grouped by category, with the way each one is installed and
the command to reinstall it. Left out on purpose: games, Microsoft Edge (part of Windows), Wallpaper
Engine, Thonny and ASUS DriverHub. Tools for the dev setup itself (Git, PowerShell 7, Oh My Posh,
Neovim, WezTerm, Rust, …) are in their own docs ([README](../README.md)).

Every winget / Microsoft Store ID below was checked with `winget show --id <ID> -e`.

## Reinstall everything at once

[`configs/windows/winget/apps.json`](../configs/windows/winget/apps.json) holds every app that has a
winget or Microsoft Store ID. In PowerShell:

```powershell
winget import -i configs\windows\winget\apps.json --accept-package-agreements --accept-source-agreements
```

Apps already installed are skipped. The [manual installs](#manual-installs) aren't covered and have
to be downloaded by hand.

Install or update a single app:

```powershell
winget install --id <ID> -e          # add  --source msstore  for Store IDs
winget upgrade --all                 # update everything winget knows about
```

## Office and productivity

| App | Installed via | ID |
|---|---|---|
| Microsoft 365 (Word, Excel, PowerPoint) | Office installer (Click-to-Run) | `Microsoft.Office` |
| Outlook (new) | winget / built in | `Microsoft.Outlook` |
| Microsoft Teams | winget | `Microsoft.Teams` |
| Obsidian | winget | `Obsidian.Obsidian` |

`Microsoft.Office` installs Microsoft 365 Apps. Sign in with the Microsoft account to activate it.
Another way is to download the installer from <https://www.office.com>, which installs the version
that matches the license.

## Media

| App | Installed via | ID |
|---|---|---|
| Netflix | Microsoft Store | `9WZDNCRFJ3TJ` (msstore) |
| Spotify | winget | `Spotify.Spotify` |
| OBS Studio | winget | `OBSProject.OBSStudio` |
| HandBrake | winget | `HandBrake.HandBrake` |
| YouTube | Chrome web app | — see [web apps](#web-apps-chrome) |
| TikTok | Chrome web app | — see [web apps](#web-apps-chrome) (Store app: `9NH2GPH4JZS4`) |

## Browsers

| App | Installed via | ID |
|---|---|---|
| Google Chrome | winget | `Google.Chrome` |
| Mozilla Firefox | winget | `Mozilla.Firefox` |
| Opera | winget | `Opera.Opera` |

## Chat and meetings

| App | Installed via | ID |
|---|---|---|
| Slack | winget | `SlackTechnologies.Slack` |
| Zulip | winget | `Zulip.Zulip` |
| Zoom Workplace | winget | `Zoom.Zoom.EXE` |
| Discord | winget | `Discord.Discord` |
| TeamSpeak 3 | winget | `TeamSpeakSystems.TeamSpeakClient` |

TeamSpeak Overlay comes from the Overwolf app store, not from TeamSpeak
([gaming tools](#gaming-tools)).

## Development

| App | Installed via | ID |
|---|---|---|
| Docker Desktop | Microsoft Store | `XP8CBJ40XLBWKX` (msstore). The winget version is `Docker.DockerDesktop` |
| Visual Studio Code | winget | `Microsoft.VisualStudioCode` |
| Windows Terminal | winget / built in | `Microsoft.WindowsTerminal` ([setup](01-windows-terminal-and-fonts.md)) |
| JetBrains Toolbox | winget | `JetBrains.Toolbox` ([doc 12](12-jetbrains-toolbox.md)) |
| IntelliJ IDEA, CLion, RustRover, PyCharm, WebStorm | JetBrains Toolbox | install from Toolbox, sign in with the JetBrains account |
| Kleopatra | part of Gpg4win | `GnuPG.Gpg4win` ([GPG setup](10-git-ssh-gpg.md)) |

Docker Desktop needs WSL 2 and the WSL integration turned on for each distro (Settings →
Resources → WSL integration), see [doc 11](11-docker.md). [Doc 04](04-zsh.md#5b-broken-completion-links-docker-desktop-_docker) explains why the zsh
config tolerates the integration being turned off.

## AI

| App | Installed via | ID |
|---|---|---|
| Claude | winget | `Anthropic.Claude` |
| ChatGPT | Microsoft Store | `9PLM9XGG6VKS` (msstore) |

## Documents and Estonian ID card

| App | Installed via | ID |
|---|---|---|
| Adobe Acrobat | Adobe installer | `Adobe.Acrobat.Reader.64-bit`. With a subscription, `Adobe.Acrobat.Pro` |
| DigiDoc4 | winget | `RIA.DigiDoc4` (Store: `9PFPFK4DJ1S6`) |
| eID software (ID card drivers, browser signing) | winget | `RIA.eIDsoftware` |

`RIA.eIDsoftware` is the full ID-software bundle from <https://www.id.ee>. It includes DigiDoc4,
the card drivers and the browser extension for signing. Installing the bundle alone is enough.

## Cloud

| App | Installed via | ID |
|---|---|---|
| Google Drive (desktop shortcut) | Chrome web app | — see [web apps](#web-apps-chrome) |
| Google Drive for desktop (sync client, optional) | winget | `Google.GoogleDrive` |

## Hardware and system

| App | Installed via | ID |
|---|---|---|
| NVIDIA App (drivers, GeForce settings) | NVIDIA installer | `XP8CLZL93F5Z4P` (msstore) or <https://www.nvidia.com/en-us/software/nvidia-app/> |
| LG OnScreen Control (monitor settings) | LG installer | manual: [download](#manual-installs) |
| Malwarebytes | winget | `Malwarebytes.Malwarebytes` |

## Game launchers

| App | Installed via | ID |
|---|---|---|
| Steam | winget | `Valve.Steam` |
| Epic Games Launcher | winget | `EpicGames.EpicGamesLauncher` |
| EA app | winget | `ElectronicArts.EADesktop` |
| Ubisoft Connect | winget | `Ubisoft.Connect` |
| Rockstar Games Launcher | winget | `RockstarGames.Launcher` (installs Social Club too) |
| Riot Client | game installer | manual: [download](#manual-installs) |

The Riot Client has no winget package of its own. Installing a Riot game (for example
`RiotGames.Valorant.EU`, `RiotGames.LeagueOfLegends.EUW`) installs the client together with Riot
Vanguard.

## Gaming tools

| App | Installed via | ID |
|---|---|---|
| Overwolf (in-game overlays, TeamSpeak Overlay) | Overwolf installer | manual: [download](#manual-installs) |
| Medal (clip recorder) | winget | `MedalB.V.Medal` |
| FACEIT | winget | `FACEITLTD.FACEITClient` |
| FACEIT Anti-Cheat | winget | `FACEITLTD.FACEITAC` (needs a restart, runs as a kernel driver) |
| Modrinth App (Minecraft mods) | winget | `Modrinth.ModrinthApp` |
| Roblox Studio | winget | `Roblox.RobloxStudio` |
| Mega Hack installer (Geometry Dash mod menu) | installer from the author | manual: [download](#manual-installs) |

## Web apps (Chrome)

YouTube, TikTok and the Google Drive desktop icon are Chrome web apps (PWAs), not separate
programs. Their shortcuts start `chrome_proxy.exe --profile-directory=Default --app-id=…`, so they
appear in Settings → Apps with Chrome's uninstaller. They sync with the Google account, so signing
in to Chrome on a new machine brings them back. To add one by hand, open the site in Chrome and use
⋮ → **Cast, save and share** → **Install page as app…**. Pin it to the taskbar from the Start menu.

| Web app | URL |
|---|---|
| YouTube | <https://www.youtube.com> |
| TikTok | <https://www.tiktok.com> |
| Google Drive | <https://drive.google.com> |

## Manual installs

These have no winget or Store package, or the Store version isn't the one in use:

| App | Download |
|---|---|
| LG OnScreen Control | <https://www.lg.com/support/software-firmware>: search for the monitor model → OnScreen Control |
| Riot Client | <https://playvalorant.com> or <https://www.leagueoflegends.com>: the game installer |
| Overwolf | <https://www.overwolf.com> |
| Mega Hack installer | <https://absolllute.com/store/mega_hack> |
| JetBrains IDEs | through JetBrains Toolbox |

## Check what's installed

```powershell
winget list                                   # everything, incl. apps winget can't upgrade
winget list --upgrade-available               # what has updates
winget export -o "$env:TEMP\winget-now.json"  # dump the current state to compare with apps.json
```

Back to the [README](../README.md).
