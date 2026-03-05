# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# DISABLE_AUTO_UPDATE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_COMPFIX="true"

# fnm
eval "$(fnm env --use-on-cd)"

# SDKMAN
if command -v brew &>/dev/null; then
  export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# Go
if command -v go &>/dev/null; then
  export GOPATH="$HOME/go"
  export PATH="$GOPATH/bin:$PATH"
fi

# Python 3.13
if [[ -d /opt/homebrew/opt/python@3.13/bin ]]; then
  export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Added by Antigravity
export PATH="/Users/tommyliu/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/tommyliu/.bun/_bun" ] && source "/Users/tommyliu/.bun/_bun"
