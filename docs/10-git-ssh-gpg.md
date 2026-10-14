# 10 — Git, SSH keys and GPG commit signing (Windows)

SSH keys were moved from the old computer by copying `~/.ssh`. This page covers the GPG signing
key, Git config, and making SSH pick the right key for GitHub ([section 6](#6-ssh-keys-for-github-push--pull)).
Placeholders: `YOUR_KEY_ID`, `you@example.com`, `OLD_USER`.

## Do you need the old computer's `.gitconfig`?

No. Only the signing-related keys matter (`user.signingkey`, `commit.gpgsign`, `gpg.program`,
`gpg.format`) and you set them fresh — `gpg.program` differs per machine anyway. Copy aliases by
hand if you had any. Example: [`configs/windows/git/gitconfig.example`](../configs/windows/git/gitconfig.example).

## 1. Install GnuPG (Gpg4win)

```powershell
winget install GnuPG.Gpg4win
```

Open a new terminal so `gpg` is on `PATH` (`C:\Program Files\GnuPG\bin\gpg.exe`).
Git for Windows bundles its own gpg, but Gpg4win has a proper Windows pinentry (passphrase dialog).

## 2a. Migrate the existing key (what was done)

**Old computer** — the key lives in `C:\Users\OLD_USER\.gnupg`. Export to your user folder,
not to the USB drive:

```powershell
& 'C:\Program Files\GnuPG\bin\gpg.exe' --list-secret-keys --keyid-format=long

& 'C:\Program Files\GnuPG\bin\gpg.exe' `
  --homedir 'C:\Users\OLD_USER\.gnupg' `
  --output "$HOME\gpg-key-backup.asc" `
  --armor `
  --export-secret-keys YOUR_KEY_ID

& 'C:\Program Files\GnuPG\bin\gpg.exe' --export-ownertrust > "$HOME\trust.txt"
```

The `.asc` file **is your secret key**: never email it, upload it or put it in a shared folder.
Move it with a USB drive or another channel you trust.

**New computer:**

```powershell
& 'C:\Program Files\GnuPG\bin\gpg.exe' --import "$HOME\gpg-key-backup.asc"
& 'C:\Program Files\GnuPG\bin\gpg.exe' --import-ownertrust "$HOME\trust.txt"
& 'C:\Program Files\GnuPG\bin\gpg.exe' --list-secret-keys --keyid-format LONG YOUR_KEY_ID
```

The listing must show a `sec` line (secret key present) and `[ultimate]` trust on the `uid`s.
Afterwards delete `gpg-key-backup.asc` / `trust.txt` from both computers and the USB drive,
unless you keep it on purpose as a protected backup.

## 2b. Or create a new key

```powershell
gpg --full-generate-key                       # default ECC (ed25519), pick an expiry
gpg --armor --export YOUR_KEY_ID              # public key -> GitHub/GitLab
```

Use an e-mail that is verified on your GitHub/GitLab account. Keep old public keys on the
account so old commits stay "Verified".

## 3. Configure Git

```powershell
git config --global gpg.program 'C:\Program Files\GnuPG\bin\gpg.exe'
git config --global gpg.format openpgp
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

GnuPG uses its default home directory for your Windows account; you don't need `GNUPGHOME`
unless you use a custom one. Remove a stray/typo key, e.g.: `git config --global --unset user.mail`.

## 4. Verify signing

```powershell
'Git signing check' | & 'C:\Program Files\GnuPG\bin\gpg.exe' --armor --local-user YOUR_KEY_ID --clearsign
git log -1 --show-signature      # after a commit
```

### Passphrase cache (how often GPG asks)

gpg-agent remembers the passphrase only **10 minutes** by default (`default-cache-ttl 600`), so with
`commit.gpgsign=true` a pinentry window pops up again and again. If nobody answers it, the commit
fails with `gpg: signing failed: Timeout` / `fatal: failed to write commit object` (the staged
changes stay staged; just commit again). This setup caches it for **8 hours**:

`%APPDATA%\gnupg\gpg-agent.conf` (the GnuPG home is shown by `gpgconf --list-dirs homedir`):

```text
default-cache-ttl 28800
max-cache-ttl 28800
```

```powershell
& 'C:\Program Files\GnuPG\bin\gpgconf.exe' --reload gpg-agent
& 'C:\Program Files\GnuPG\bin\gpgconf.exe' --list-options gpg-agent | Select-String '^(default|max)-cache-ttl:'
```

`default-cache-ttl` = seconds since the passphrase was last *used*; `max-cache-ttl` = hard limit since
it was *entered*. Forget it immediately: `gpgconf --reload gpg-agent` (or `gpg-connect-agent reloadagent /bye`).

## 5. Add the public key to GitHub / GitLab

```powershell
& 'C:\Program Files\GnuPG\bin\gpg.exe' --armor --export YOUR_KEY_ID
```

- GitHub: Settings → SSH and GPG keys → New GPG key
- GitLab: Preferences → GPG Keys

The public key is safe to share; **never** share the secret export. A key with several `uid`s
(e-mails) verifies commits made with any of those e-mails.

## 6. SSH keys for GitHub (push / pull)

### Symptom

```text
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

even though the key is on your GitHub account.

### Cause

Without `~/.ssh/config`, SSH only offers the **default key names** (`id_rsa`, `id_ecdsa`,
`id_ed25519`, …). A key with a custom name such as `id_ed25519_github` is never tried.

### Diagnose (no secrets shown)

```powershell
ssh -v -T git@github.com 2>&1 | Select-String 'Will attempt|Offering|Authenticated'   # which keys SSH tries
Get-ChildItem $HOME\.ssh                                                              # which keys exist
Invoke-RestMethod https://github.com/<github-user>.keys                               # public keys on the account
ssh-keygen -lf $HOME\.ssh\id_ed25519_github.pub                                       # fingerprint of a local key
```

Compare the public key on GitHub (Settings → SSH and GPG keys) with your local `.pub` files.

### Fix: `~/.ssh/config`

`C:\Users\<you>\.ssh\config` (no extension, UTF-8 **without** BOM, LF or CRLF both fine). Repo copy:
[`configs/windows/ssh/config`](../configs/windows/ssh/config).

```sshconfig
# GitHub: always use the key registered on the account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```

- `IdentityFile` — the key to use for this host.
- `IdentitiesOnly yes` — offer **only** that key (avoids "Too many authentication failures" when
  you have several keys).
- Add one `Host` block per service (e.g. `Host gitlab.com` with its own key).

Check what SSH will use, then test:

```powershell
ssh -G github.com | Select-String '^(identityfile|identitiesonly|user) '
ssh -T git@github.com      # "Hi <user>! You've successfully authenticated..."
```

Git for Windows' `ssh` and Windows' OpenSSH (`C:\Windows\System32\OpenSSH\ssh.exe`) both read
`~/.ssh/config`.

### Passphrase once per login: ssh-agent

A key with a passphrase asks for it on every `git push` / `pull` / `fetch`. Let the Windows
ssh-agent remember it. **Administrator** PowerShell (the service is disabled by default):

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
```

Normal PowerShell:

```powershell
ssh-add $HOME\.ssh\id_ed25519_github
ssh-add -l          # lists the loaded key
```

Make Git use Windows' OpenSSH, so it talks to that agent (Git's bundled ssh has its own agent):

```powershell
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

`Error connecting to agent: No such file or directory` from `ssh-add` = the ssh-agent service
isn't running.

### First push of a new repo

```powershell
git remote add origin git@github.com:<github-user>/<repo>.git
git branch -M main
git push -u origin main
```

If the key has a passphrase and no agent is running, run the push in an interactive terminal so
you can type it.

## Alternative: sign with your SSH key

No GPG at all — reuse the migrated SSH key (add it on GitHub again as a **Signing key**):

```powershell
git config --global gpg.format ssh
git config --global user.signingkey "$HOME\.ssh\id_ed25519.pub"
git config --global commit.gpgsign true
```

## Links

- Gpg4win: <https://www.gpg4win.org/>
- GitHub commit signing: <https://docs.github.com/en/authentication/managing-commit-signature-verification>
- GitLab GPG signed commits: <https://docs.gitlab.com/user/project/repository/signed_commits/gpg/>
- Git signing docs: <https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work>
