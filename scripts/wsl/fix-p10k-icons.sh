#!/usr/bin/env bash
# Post-wizard fixes for ~/.p10k.zsh (Rainbow style):
#   - enable the prompt arrow (prompt_char is commented out in Rainbow)
#   - replace ✔/✘ (not in JetBrainsMono Nerd Font -> drawn by a fallback font, looks off)
#     with the Nerd Font check U+F00C and cross U+F00D
# Re-run after every `p10k configure`, which rewrites the file.
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

F="$HOME/.p10k.zsh"
[ -f "$F" ] || die "$F not found, run p10k configure first"
cp "$F" "$F.bak"

CHECK=$(printf '\xef\x80\x8c')   # U+F00C nf-fa-check
CROSS=$(printf '\xef\x80\x8d')   # U+F00D nf-fa-xmark
sed -i -E 's/^(\s*)# prompt_char(\s+# prompt symbol)/\1prompt_char\2/' "$F"
sed -i -E "s/^(\s*typeset -g POWERLEVEL9K_STATUS_OK(_PIPE)?_VISUAL_IDENTIFIER_EXPANSION=).*/\1'${CHECK}'/" "$F"
sed -i -E "s/^(\s*typeset -g POWERLEVEL9K_STATUS_ERROR(_SIGNAL|_PIPE)?_VISUAL_IDENTIFIER_EXPANSION=).*/\1'${CROSS}'/" "$F"

zsh -n "$F" || { cp "$F.bak" "$F"; die "syntax check failed, restored the backup"; }
say "done (backup: $F.bak) -> exec zsh"
