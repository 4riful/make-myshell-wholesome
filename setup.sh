#!/bin/bash

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function declarations

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_zsh() {
    print_status "Installing Zsh..."
    if check_command zsh; then
        print_warning "Zsh is already installed"
        return 0
    fi
    
    sudo apt-get update
    sudo apt-get install zsh -y
    
    if check_command zsh; then
        print_success "Zsh installed successfully"
    else
        print_error "Failed to install Zsh"
        return 1
    fi
}

install_oh_my_zsh() {
    print_status "Installing Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh is already installed"
        return 0
    fi
    
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh installed successfully"
    else
        print_error "Failed to install Oh My Zsh"
        return 1
    fi
}

install_plugins() {
    print_status "Installing zsh-autosuggestions and zsh-syntax-highlighting plugins..."
    
    # Create plugins directory if it doesn't exist
    mkdir -p "${ZSH_CUSTOM}/plugins"
    
    # Install zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    else
        print_warning "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    else
        print_warning "zsh-syntax-highlighting already installed"
    fi
    
    # Update .zshrc with plugins
    if [ -f "$HOME/.zshrc" ]; then
        # Check if plugins line exists and update it
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
        fi
        print_success "Plugins installed and configured"
    else
        print_error ".zshrc file not found"
        return 1
    fi
}

select_theme() {
    local theme=$1
    print_status "Setting theme to $theme"
    
    if [ -f "$HOME/.zshrc" ]; then
        sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"$theme\"/" "$HOME/.zshrc"
        print_success "Theme set to $theme"
    else
        print_error ".zshrc file not found"
        return 1
    fi
}

install_colorls() {
    print_status "Installing Ruby and development tools..."
    sudo apt-get update
    sudo apt-get install ruby-full build-essential libssl-dev -y
    
    print_status "Installing colorls..."
    sudo gem install colorls
    
    # Add colorls alias to .zshrc if not already present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'alias ls="colorls' "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Colorls aliases' >> "$HOME/.zshrc"
            echo 'alias ls="colorls --group-directories-first"' >> "$HOME/.zshrc"
            echo 'alias ll="colorls -l --group-directories-first"' >> "$HOME/.zshrc"
            echo 'alias la="colorls -la --group-directories-first"' >> "$HOME/.zshrc"
        fi
        print_success "colorls installed and configured"
    else
        print_error ".zshrc file not found"
        return 1
    fi
}

install_aurora_modern_theme() {
    print_status "Setting up AuroraModern Theme for Oh My Zsh..."
    
    # Create themes directory if it doesn't exist
    mkdir -p "${ZSH_CUSTOM}/themes"
    
    local theme_path="${ZSH_CUSTOM}/themes/AuroraModern.zsh-theme"
    cat <<'EOF' > "$theme_path"
# AuroraModern Theme for Oh My Zsh - Enhanced Version
# Modern, clean theme with excellent fallback support

# Function to detect if terminal supports Unicode
supports_unicode() {
    [[ "${LC_ALL:-${LC_CTYPE:-${LANG}}}" =~ UTF-8$ ]] || [[ "$TERM_PROGRAM" == "vscode" ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]
}

# Function to get OS-specific symbol
get_os_symbol() {
    local os_name="$(uname -s)"
    
    if supports_unicode; then
        case "$os_name" in
            Linux*)
                if [[ -f /etc/os-release ]]; then
                    local distro=$(grep -w NAME /etc/os-release | cut -d "=" -f 2 | tr -d '"' | head -n 1)
                    case "$distro" in
                        *Ubuntu*) echo "🐧" ;;
                        *Debian*) echo "🌀" ;;
                        *Arch*) echo "🏔️" ;;
                        *) echo "🐧" ;;
                    esac
                else
                    echo "🐧"
                fi
                ;;
            Darwin*) echo "🍎" ;;
            *) echo "💻" ;;
        esac
    else
        case "$os_name" in
            Linux*) echo "[L]" ;;
            Darwin*) echo "[M]" ;;
            *) echo "[?]" ;;
        esac
    fi
}

# Set symbols based on Unicode support
if supports_unicode; then
    local user_symbol="👤"
    local directory_symbol="📁"
    local git_branch_symbol="🌿"
    local dirty_status_symbol="⚡"
    local clean_status_symbol="✨"
    local arrow_symbol="→"
else
    local user_symbol="@"
    local directory_symbol="~"
    local git_branch_symbol="git:"
    local dirty_status_symbol="*"
    local clean_status_symbol="+"
    local arrow_symbol=">"
fi

local host_symbol="$(get_os_symbol)"

# Define colors with better contrast
local user_color="%{$fg_bold[green]%}"
local host_color="%{$fg_bold[blue]%}"
local directory_color="%{$fg_bold[cyan]%}"
local git_color="%{$fg_bold[magenta]%}"
local dirty_color="%{$fg_bold[red]%}"
local clean_color="%{$fg_bold[green]%}"
local prompt_color="%{$fg_bold[yellow]%}"
local time_color="%{$fg[white]%}"
local reset_color="%{$reset_color%}"

# Enhanced Git prompt function
aurora_git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
            local git_status=$(git status --porcelain 2>/dev/null)
            local status_symbol
            
            if [[ -n "$git_status" ]]; then
                status_symbol="${dirty_color}${dirty_status_symbol}"
            else
                status_symbol="${clean_color}${clean_status_symbol}"
            fi
            
            echo " ${git_color}${git_branch_symbol} ${branch} ${status_symbol}${reset_color}"
        fi
    fi
}

# Function to get current time
get_time() {
    echo "${time_color}%D{%H:%M:%S}${reset_color}"
}

# Function to show last command status
command_status() {
    echo "%(?..${dirty_color}✘${reset_color} )"
}

# Build the modern prompt
PROMPT='
╭─ ${user_color}${user_symbol} %n${reset_color} ${host_color}${host_symbol} %m${reset_color} ${directory_color}${directory_symbol} %3~${reset_color}$(aurora_git_prompt_info)
╰─ $(command_status)${prompt_color}${arrow_symbol}${reset_color} '

# Right prompt with time
RPROMPT='$(get_time)'

# Additional configurations for better experience
setopt PROMPT_SUBST
autoload -U colors && colors

# Custom aliases for the theme
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=tty'
alias lsa='ls -lah'
alias md='mkdir -p'
alias rd='rmdir'

EOF
    
    if [ -f "$theme_path" ]; then
        print_success "AuroraModern Theme created successfully"
        select_theme "AuroraModern"
    else
        print_error "Failed to create AuroraModern Theme"
        return 1
    fi
}

install_powerlevel10k() {
    print_status "Installing Powerlevel10k theme..."
    
    # Create themes directory if it doesn't exist
    mkdir -p "${ZSH_CUSTOM}/themes"
    
    if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
    else
        print_warning "Powerlevel10k already installed"
    fi
    
    select_theme "powerlevel10k/powerlevel10k"
    print_success "Powerlevel10k theme installed and configured"
}

set_zsh_default() {
    print_status "Setting Zsh as default shell..."
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s $(which zsh)
        print_success "Zsh set as default shell (restart terminal to take effect)"
    else
        print_warning "Zsh is already the default shell"
    fi
}

auto_install() {
    print_status "Starting automatic installation..."
    echo -e "${CYAN}This will install:${NC}"
    echo "  • Zsh"
    echo "  • Oh My Zsh"
    echo "  • Useful plugins (autosuggestions, syntax highlighting)"
    echo "  • AuroraModern theme"
    echo "  • Colorls for better file listings"
    echo ""
    
    read -p "Continue with automatic installation? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        install_zsh || return 1
        install_oh_my_zsh || return 1
        install_plugins || return 1
        install_colorls || return 1
        install_aurora_modern_theme || return 1
        set_zsh_default
        
        print_success "Automatic installation completed!"
        print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    else
        print_status "Automatic installation cancelled"
    fi
}

show_menu() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                 ${CYAN}Zsh Configuration Script${NC}                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "  ${GREEN}0)${NC} Auto Install (Recommended)"
    echo -e "  ${GREEN}1)${NC} Install Zsh"
    echo -e "  ${GREEN}2)${NC} Install Oh My Zsh"
    echo -e "  ${GREEN}3)${NC} Install plugins (autosuggestions & syntax highlighting)"
    echo -e "  ${GREEN}4)${NC} Set custom theme"
    echo -e "  ${GREEN}5)${NC} Install colorls"
    echo -e "  ${GREEN}6)${NC} Install AuroraModern Theme"
    echo -e "  ${GREEN}7)${NC} Install Powerlevel10k theme"
    echo -e "  ${GREEN}8)${NC} Set Zsh as default shell"
    echo -e "  ${GREEN}9)${NC} Exit"
    echo ""
}

# Main execution
main() {
    # Check if running on supported system
    if ! command -v apt-get &> /dev/null; then
        print_error "This script is designed for Debian/Ubuntu systems"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Enter your choice (0-9): " choice
        echo ""
        
        case $choice in
            0) auto_install ;;
            1) install_zsh ;;
            2) install_oh_my_zsh ;;
            3) install_plugins ;;
            4) 
                echo -e "${CYAN}Available themes:${NC} agnoster, robbyrussell, powerlevel10k/powerlevel10k, AuroraModern"
                read -p "Enter theme name: " theme
                if [[ -n "$theme" ]]; then
                    select_theme "$theme"
                else
                    print_error "No theme specified"
                fi
                ;;
            5) install_colorls ;;
            6) install_aurora_modern_theme ;;
            7) install_powerlevel10k ;;
            8) set_zsh_default ;;
            9) 
                print_status "Exiting script. Have a great day!"
                exit 0
                ;;
            *) 
                print_error "Invalid option selected. Please choose 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Run main function
main
