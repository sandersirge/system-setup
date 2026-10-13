# 07 — Oh My Zsh + Powerlevel10k (Fedora)

Fedora runs [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) with the
[Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme instead of Oh My Posh.
Two prompt engines must not run together, so Oh My Posh is not initialized there.

## Install

```bash
bash scripts/wsl/setup-omz-p10k.sh             # then run the wizard yourself
bash scripts/wsl/setup-omz-p10k.sh --my-p10k   # or reuse configs/wsl/p10k/p10k.zsh
```

What it does:

1. Saves the current `~/.zshrc` as `~/.zshrc.pre-oh-my-zsh` (rollback).
2. Installs Oh My Zsh unattended:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
   ```
3. Clones into `~/.oh-my-zsh/custom`:
   ```bash
   git clone --depth 1 https://github.com/romkatv/powerlevel10k.git          ~/.oh-my-zsh/custom/themes/powerlevel10k
   git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions      ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```
4. Installs [`zshrc.fedora-omz-p10k`](../configs/wsl/zsh/zshrc.fedora-omz-p10k) as `~/.zshrc`:
   ```zsh
   ZSH_THEME="powerlevel10k/powerlevel10k"
   plugins=(git zsh-interactive-cd zsh-autosuggestions zsh-syntax-highlighting)
   ```
   plus the carried-over block: Homebrew, `~/.local/bin`, `COLORTERM`, eza/`lls` aliases,
   grc/bat colors, and `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh`.

Not carried over: Kali's history/completion/key-binding block (Oh My Zsh has its own).
`git` plugin aliases: `gst`, `gco`, `gp`, `gl`, `gd`, … (<https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git>).

## Configuration wizard

Starts automatically on the first `exec zsh` without `~/.p10k.zsh`; rerun any time:

```bash
p10k configure
```

- *Install Meslo Nerd Font?* → **No**. It can't install into Windows from WSL, and
  JetBrainsMono Nerd Font already has every glyph.
- Glyph checks (diamond, lock, arrows…) → **Yes**.
- Style used here: **Rainbow**, Nerd Font v3 + powerline, large icons, unicode, 24h time,
  two lines, frame. Saved in [`configs/wsl/p10k/p10k.zsh`](../configs/wsl/p10k/p10k.zsh).
- *Instant prompt* → **Verbose** (recommended).

## Fixes after the wizard

```bash
bash scripts/wsl/fix-p10k-icons.sh && exec zsh
```

| Problem | Cause | Fix in `~/.p10k.zsh` |
|---|---|---|
| no `❯` arrow on line 2 | Rainbow comments out `prompt_char` | uncomment `prompt_char` in `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` |
| success `✔` looks off | U+2714 not in the font → fallback font | `POWERLEVEL9K_STATUS_OK[_PIPE]_VISUAL_IDENTIFIER_EXPANSION=''` (U+F00C) |
| error `✘` looks off | U+2718 not in the font | `POWERLEVEL9K_STATUS_ERROR[_SIGNAL\|_PIPE]_VISUAL_IDENTIFIER_EXPANSION=''` (U+F00D) |

`p10k configure` rewrites `~/.p10k.zsh`: run `fix-p10k-icons.sh` again after it (or choose
Lean/Classic/Pure, which keep the arrow). `127` next to the cross = exit code (command not found).

## Roll back to Oh My Posh

```bash
cp ~/.zshrc.pre-oh-my-zsh ~/.zshrc && exec zsh
```

Remove Oh My Zsh completely first with `uninstall_oh_my_zsh` (it restores its own backup).
The Arch/Fedora OS icons for Oh My Posh are already fixed in the themes ([06](06-oh-my-posh.md#os-icon-fix-arch--fedora-showed-tux)).
