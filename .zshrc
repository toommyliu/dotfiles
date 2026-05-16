# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# DISABLE_MAGIC_FUNCTIONS="true"

typeset -U path PATH

# fnm
eval "$(fnm env --use-on-cd)"

# SDKMAN
export SDKMAN_DIR="/opt/homebrew/opt/sdkman-cli/libexec"
if [[ -d "${SDKMAN_DIR}/candidates/java/current" ]]; then
  export JAVA_HOME="${SDKMAN_DIR}/candidates/java/current"
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  sdk() {
    unfunction sdk
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk "$@"
  }
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
[[ -d "$PNPM_HOME/bin" ]] && export PATH="$PNPM_HOME/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Added by Antigravity
export PATH="/Users/tommyliu/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/tommyliu/.bun/_bun" ] && source "/Users/tommyliu/.bun/_bun"
