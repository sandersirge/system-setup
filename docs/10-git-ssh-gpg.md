# 10 — Git, SSH keys and GPG commit signing (Windows)

SSH keys were moved from the old computer by copying `~/.ssh`. This page covers the GPG signing
key and Git config. Placeholders: `YOUR_KEY_ID`, `you@example.com`, `OLD_USER`.

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

## 5. Add the public key to GitHub / GitLab

```powershell
& 'C:\Program Files\GnuPG\bin\gpg.exe' --armor --export YOUR_KEY_ID
```

- GitHub: Settings → SSH and GPG keys → New GPG key
- GitLab: Preferences → GPG Keys

The public key is safe to share; **never** share the secret export. A key with several `uid`s
(e-mails) verifies commits made with any of those e-mails.

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
