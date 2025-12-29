tap "sdkman/tap"
tap "oven-sh/bun"

# Apps
    # (chromium-based) browsers
    cask "helium-browser"
    cask "google-chrome"
    cask "brave-browser"

    # (gecko-based) browsers
    cask "zen"

    # productivity
    cask "spotify" # audio client
    cask "notion" # productivity workspace
    cask "notion-calendar" # elegant calendar
    cask "raycast" # supercharged command launcher
    cask "rectangle" # window management
    cask "alt-tab" # windows-like alt-tab
    cask "todoist-app" # task management

    # communication
    cask "zoom" if ENV['HOMEBREW_BUNDLE_INSTALL_ZOOM']
    # cask "discord"
    cask "legcord" # custom discord client - has a menubar icon

    # utilities
    cask "stats" # menubar resource monitor
    cask "onyx" # system utilities & maintenance
    cask "omnidisksweeper" # disk maintenance
    cask "keyboardcleantool" # disables keyboard to clean
    cask "pearcleaner" # app uninstaller
    cask "jordanbaird-ice" # menubar management
    cask "karabiner-elements" # keyboard remapping for hyperkey

    if ENV['HOMEBREW_BUNDLE_INSTALL_BITWARDEN']
      if OS.mac?
        brew "mas" # Mac App Store CLI
        mas "Bitwarden", id: 1352778147 # MAS version for browser integration
      else
        cask "bitwarden"
      end
    end

    cask "ente-auth" # 2fa

    # dev apps
    cask "ghostty" # terminal emulator
    cask "sublime-merge" # git source control app
    cask "visual-studio-code" # code editor
    cask "antigravity" # code editor
    cask "zed" # code editor
    cask "intellij-idea" # java IDE
    cask "jetbrains-toolbox" # manage JetBrains IDEs

# Media stuff
brew "yt-dlp" # youtube downloader
brew "ffmpeg" # a/v processing
brew "gallery-dl" # social-media downloader

# AI stuff
brew "gemini-cli" # cli for Google Gemini

# Dev stuff
brew "dockutil" # manage dock items
cask "font-cascadia-code"
cask "font-commit-mono"
cask "font-noto-sans-mono"
cask "font-ubuntu-mono"
cask "font-jetbrains-mono"
cask "font-jetbrains-mono-nerd-font"
brew "gh" # github cli
brew "git" # version control
brew "sdkman/tap/sdkman-cli" # java version manager

# Languages
brew "go"
brew "python@3.13"

# Javascript stuff
brew "pnpm" # efficient package manager
brew "yarn"
brew "oven-sh/bun/bun" # all-in-one javascript runtime, bundler, package manager
brew "deno" # next-generation javascript runtime

# Python stuff
brew "virtualenv" # manage virtual environments
