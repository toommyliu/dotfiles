# dotfiles

## quickstart

```bash
git clone https://github.com/toommyliu/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

During an interactive run, `setup.sh` prompts for optional setup:

- `./setup_raycast.sh` imports the latest Raycast `.rayconfig`.
- `./setup_tools.sh` sets up personal utilities and installs app artifacts.
- `./setup_agents.sh` symlinks `~/.agents` to the versioned agents setup.

You can also run either script directly:

```bash
./setup_raycast.sh
./setup_tools.sh
./setup_agents.sh
```
