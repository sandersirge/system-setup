# 11 — Docker in WSL (Docker Desktop integration)

Error in a distro:

```text
The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.
```

Docker Desktop runs on Windows and only injects the `docker` CLI into distros you enable.

1. Start **Docker Desktop** (not paused).
2. **Settings** → **Resources** → **WSL integration**.
3. Check *Enable integration with my default WSL distro*.
4. Toggle each distro (Ubuntu, Ubuntu-26.04, Debian, kali-linux, archlinux, FedoraLinux-44).
5. **Apply & restart**.

Then in the distro (new tab or `exec zsh`):

```bash
docker run --rm hello-world
```

- `docker` in WSL only works while Docker Desktop is running.
- Don't also install Docker Engine with apt/dnf/pacman in those distros.
- grc does not wrap `docker`, so `docker run -it` / `docker exec -it` work normally ([09](09-ls-colors-and-cli-tools.md)).
- The Oh My Posh `docker` segment shows the context in folders with a Dockerfile/compose file ([06](06-oh-my-posh.md)).

Docs: <https://docs.docker.com/desktop/features/wsl/>
