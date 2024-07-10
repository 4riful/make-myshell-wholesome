#!/bin/bash

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Function declarations

install_zsh() {
    echo "🔽 Installing Zsh..."
    sudo apt-get install zsh -y
    echo "✅ Zsh installed successfully."
}

install_oh_my_zsh() {
    echo "🔽 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed successfully."
}

install_plugins() {
    echo "🔌 Installing zsh-autosuggestions and zsh-syntax-highlighting plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
    sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/" ~/.zshrc
    echo "✅ Plugins installed."
}

select_theme() {
    echo "🎨 Setting theme to $1."
    sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"$1\"/" ~/.zshrc
    echo "✅ Theme set to $1."
}

install_colorls() {
    echo "🔽 Installing Ruby and development tools..."
    sudo apt-get install ruby-full build-essential libssl-dev -y
    echo "💎 Installing colorls..."
    sudo gem install colorls
    echo 'alias ls="colorls --group-directories-first"' >> ~/.zshrc
    echo "✅ colorls installed and configured."
}

install_aurora_modern_theme() {
    echo "🎨 Setting up AuroraModern Theme for Oh My Zsh..."
    local theme_path="${ZSH_CUSTOM}/themes/AuroraModern.zsh-theme"
    cat <<'EOF' > $theme_path
# AuroraModern Theme for Oh My Zsh

# Determine the OS and set the host symbol
os_name="$(uname -s)"
case "$os_name" in
    Linux*)     distro=$(cat /etc/*release | grep -w NAME | cut -d "=" -f 2 | tr -d '"' | head -n 1);;
    Darwin*)    distro="macOS";;
    *)          distro="unknown";;
esac

if [[ $distro == "Ubuntu" ]]; then
    local host_symbol="" # Ubuntu logo from Nerd Fonts
else
    local host_symbol="" # Generic computer symbol for other OSes
fi

# Define colors
local user_color="%{$fg[green]%}"
local host_color="%{$fg_bold[blue]%}"
local directory_color="%{$fg_bold[cyan]%}"
local git_color="%{$fg_bold[purple]%}"
local dirty_color="%{$fg[red]%}"
local clean_color="%{$fg[green]%}"
local prompt_color="%{$fg_bold[yellow]%}"

# Define Nerd Font symbols
local user_symbol="" # Nerd Font symbol for user icon
local directory_symbol="" # Nerd Font symbol for directory icon
local git_branch_symbol="" # Nerd Font symbol for git branch
local dirty_status_symbol="✗" # Symbol for dirty status
local clean_status_symbol="✔" # Symbol for clean status

# Git prompt details
ZSH_THEME_GIT_PROMPT_PREFIX="${git_color}["
ZSH_THEME_GIT_PROMPT_SUFFIX="${git_color}]"
ZSH_THEME_GIT_PROMPT_DIRTY="${dirty_color}${dirty_status_symbol}"
ZSH_THEME_GIT_PROMPT_CLEAN="${clean_color}${clean_status_symbol}"

# Function to build the Git prompt
git_prompt_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local branch=$(git branch --show-current 2>/dev/null)
    [ -n "$branch" ] && echo "${git_color}${git_branch_symbol} ${branch}$(parse_git_dirty)"
  fi
}

parse_git_dirty() {
  local git_status=$(git status --porcelain 2>/dev/null)
  [ -n "$git_status" ] && echo " ${ZSH_THEME_GIT_PROMPT_DIRTY}" || echo " ${ZSH_THEME_GIT_PROMPT_CLEAN}"
}

# Build the prompt
PROMPT='
${user_color}${user_symbol} %n ${host_color}${host_symbol} %m ${directory_color}${directory_symbol} %3~$(git_prompt_info)
${prompt_color}>%f '
RPROMPT='%{$fg_bold[white]%}%*%{$reset_color%}'
EOF
    echo "✅ AuroraModern Theme set up successfully."
    select_theme "AuroraModern"
}

install_powerlevel10k() {
    echo "🔽 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
    sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc
    echo "✅ Powerlevel10k theme installed and configured."
}

# Main menu for selections
echo "📋 Select the features you want to install/configure:"
echo "  1) Install Zsh"
echo "  2) Install Oh My Zsh"
echo "  3) Install zsh-autosuggestions & zsh-syntax-highlighting plugins"
echo "  4) Set theme (Enter theme name after selection)"
echo "  5) Install colorls"
echo "  6) Install AuroraModern Theme"
echo "  7) Install Powerlevel10k theme"
echo "  8) Exit"
read -p "Enter your choice (1-8): " choice

case $choice in
    1) install_zsh ;;
    2) install_oh_my_zsh ;;
    3) install_plugins ;;
    4) 
        echo "🎨 Enter the theme name (e.g., agnoster, robbyrussell):"
        read theme
        select_theme $theme ;;
    5) install_colorls ;;
    6) install_aurora_modern_theme ;;
    7) install_powerlevel10k ;;
    8) echo "👋 Exiting script." ;;
    *) echo "❌ Invalid option selected." ;;
esac

echo "🎉 Operation completed. Please restart your terminal or source your .zshrc file to apply the changes."
