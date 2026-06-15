# dotfiles

my dotfiles — a collection of scripts, tools, and configurations to set up a new machine, for me :)

## quickstart

```bash
git clone https://github.com/toommyliu/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

## contents

- [`setup.sh`](setup.sh) — the main setup script that orchestrates most of the setup process.
- [`setup_macos.sh`](setup_macos.sh) — configures macOS settings and preferences.
- [`setup_raycast.sh`](setup_raycast.sh) — imports the latest Raycast `.rayconfig`.
- [`setup_tools.sh`](setup_tools.sh) — sets up my series of custom apps and tools i use.
- [`setup_agents.sh`](setup_agents.sh) — symlinks content for agents.
- [`setup_github.sh`](setup_github.sh) — configures GitHub SSH keys.
