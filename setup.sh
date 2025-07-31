#!/bin/bash

# Script Configuration
SCRIPT_VERSION="2.0.1"
GITHUB_REPO="4riful/make-myshell-wholesome"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/setup.sh"
SCRIPT_PATH="$(realpath "$0")"
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

# Auto-update functionality
check_for_updates() {
    # Skip update check if no repository is configured
    if [[ -z "$GITHUB_REPO" ]]; then
        print_status "Auto-update is disabled (no repository configured)"
        return 0
    fi
    
    print_status "Checking for script updates..."
    
    if ! check_command curl; then
        print_warning "curl not found. Cannot check for updates."
        return 1
    fi
    
    # Get remote version with timeout
    local remote_content
    remote_content=$(timeout 5s curl -s "$GITHUB_RAW_URL" 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$remote_content" ]]; then
        print_warning "Could not fetch remote script (network issue or repository not found)"
        return 1
    fi
    
    # Extract remote version
    local remote_version
    remote_version=$(echo "$remote_content" | grep -o 'SCRIPT_VERSION="[^"]*"' | cut -d'"' -f2)
    
    if [[ -z "$remote_version" ]]; then
        print_warning "Could not determine remote version. Script format may have changed."
        return 1
    fi
    
    # Compare versions
    if [[ "$remote_version" != "$SCRIPT_VERSION" ]]; then
        print_status "New version available: $remote_version (current: $SCRIPT_VERSION)"
        read -p "Would you like to update the script? (y/N): " update_confirm
        
        if [[ $update_confirm =~ ^[Yy]$ ]]; then
            update_script "$remote_content"
            return $?
        else
            print_status "Continuing with current version"
            return 0
        fi
    else
        print_success "Script is up to date (version: $SCRIPT_VERSION)"
        return 0
    fi
}

update_script() {
    local remote_content="$1"
    print_status "Updating script..."
    
    # Backup current script
    local backup_path="${SCRIPT_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SCRIPT_PATH" "$backup_path"
    
    # Write new content
    echo "$remote_content" > "$SCRIPT_PATH"
    
    if [[ $? -eq 0 ]]; then
        chmod +x "$SCRIPT_PATH"
        print_success "Script updated successfully!"
        print_status "Backup saved to: $backup_path"
        print_status "Restarting script with new version..."
        echo ""
        exec "$SCRIPT_PATH" "$@"
    else
        print_error "Failed to update script"
        # Restore backup
        cp "$backup_path" "$SCRIPT_PATH"
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
    print_status "Installing essential plugins..."
    
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
    
    # Install zsh-completions for better tab completion
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions"
    else
        print_warning "zsh-completions already installed"
    fi
    
    # Update .zshrc with plugins
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' "$HOME/.zshrc"
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> "$HOME/.zshrc"
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
    print_status "Installing colorls for better file listings..."
    
    # Check if Ruby is installed
    if ! check_command ruby; then
        print_status "Installing Ruby and development tools..."
        sudo apt-get update
        sudo apt-get install ruby-full build-essential libssl-dev -y
    fi
    
    # Install colorls
    if ! check_command colorls; then
        sudo gem install colorls
    else
        print_warning "colorls is already installed"
    fi
    
    # Add colorls aliases to .zshrc if not already present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'alias ls="colorls' "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Enhanced file listing with colorls' >> "$HOME/.zshrc"
            echo 'if command -v colorls &> /dev/null; then' >> "$HOME/.zshrc"
            echo '  alias ls="colorls --group-directories-first --almost-all"' >> "$HOME/.zshrc"
            echo '  alias ll="colorls -l --group-directories-first"' >> "$HOME/.zshrc"
            echo '  alias la="colorls -la --group-directories-first"' >> "$HOME/.zshrc"
            echo 'fi' >> "$HOME/.zshrc"
        fi
        print_success "colorls installed and configured"
    else
        print_error ".zshrc file not found"
        return 1
    fi
}

install_aurora_minimal_theme() {
    print_status "Installing AuroraMinimal Theme..."
    
    # Create themes directory if it doesn't exist
    mkdir -p "${ZSH_CUSTOM}/themes"
    
    local theme_path="${ZSH_CUSTOM}/themes/AuroraMinimal.zsh-theme"
    cat <<'EOF' > "$theme_path"
# AuroraMinimal Theme - Ultra Clean & Minimal
# Simple two-line prompt with essential info only

# Clean color definitions
readonly C_USER="%F{green}"
readonly C_HOST="%F{blue}" 
readonly C_DIR="%F{cyan}"
readonly C_GIT="%F{magenta}"
readonly C_DIRTY="%F{red}"
readonly C_CLEAN="%F{green}"
readonly C_PROMPT="%F{white}"
readonly C_TIME="%F{242}"
readonly C_RESET="%f"

# Lightning-fast git status
git_info() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && return
    
    # Ultra-fast dirty check
    local status=""
    if [[ -n "$(git status --porcelain 2>/dev/null | head -1)" ]]; then
        status="${C_DIRTY}*${C_RESET}"
    fi
    
    echo " ${C_GIT}($branch)${status}"
}

# Optional: Show execution time for slow commands
preexec() {
    timer=$(($(date +%s%0N)/1000000))
}

precmd() {
    if [ $timer ]; then
        local now=$(($(date +%s%0N)/1000000))
        local elapsed=$(($now-$timer))
        if (( elapsed > 2000 )); then
            echo "${C_TIME}⏱ ${elapsed}ms${C_RESET}"
        fi
        unset timer
    fi
}

# Ultra-minimal two-line prompt
PROMPT='${C_USER}%n${C_RESET}@${C_HOST}%m${C_RESET} ${C_DIR}%~${C_RESET}$(git_info)
${C_PROMPT}> ${C_RESET}'

# Clean right prompt with just time
RPROMPT='${C_TIME}%D{%H:%M}${C_RESET}'

# Enable prompt substitution
setopt PROMPT_SUBST

# Performance settings
setopt NO_BEEP
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Clean, essential aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias l='ls -la'
alias ll='ls -l'
alias la='ls -la'

EOF
    
    if [ -f "$theme_path" ]; then
        print_success "AuroraMinimal Theme created successfully"
        select_theme "AuroraMinimal"
    else
        print_error "Failed to create AuroraMinimal Theme"
        return 1
    fi
}

install_powerlevel10k() {
    print_status "Installing Powerlevel10k theme..."
    
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

optimize_zsh_performance() {
    print_status "Applying performance optimizations..."
    
    if [ -f "$HOME/.zshrc" ]; then
        # Add performance optimizations to .zshrc if not already present
        if ! grep -q "# Performance optimizations" "$HOME/.zshrc"; then
            cat <<'EOF' >> "$HOME/.zshrc"

# Performance optimizations
DISABLE_UPDATE_PROMPT="true"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Disable unnecessary features for speed
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE="true"

EOF
        fi
        print_success "Performance optimizations applied"
    fi
}

auto_install() {
    print_status "Starting automatic installation..."
    echo -e "${CYAN}This will install and configure:${NC}"
    echo "  • Zsh shell"
    echo "  • Oh My Zsh framework"
    echo "  • Essential plugins (autosuggestions, syntax highlighting, completions)"
    echo "  • AuroraMinimal theme (clean and fast)"
    echo "  • Colorls for enhanced file listings"
    echo "  • Performance optimizations"
    echo ""
    
    read -p "Continue with automatic installation? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        install_zsh || return 1
        install_oh_my_zsh || return 1
        install_plugins || return 1
        install_colorls || return 1
        install_aurora_minimal_theme || return 1
        optimize_zsh_performance || return 1
        set_zsh_default
        
        print_success "Automatic installation completed!"
        print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
        echo ""
        print_status "The AuroraMinimal theme is designed to be fast and clean."
        print_status "It automatically adapts to your terminal's Unicode support."
    else
        print_status "Automatic installation cancelled"
    fi
}

show_version() {
    echo -e "${CYAN}Zsh Setup Script${NC}"
    echo -e "Version: ${GREEN}$SCRIPT_VERSION${NC}"
    if [[ -n "$GITHUB_REPO" ]]; then
        echo -e "Repository: ${BLUE}https://github.com/$GITHUB_REPO${NC}"
    else
        echo -e "Repository: ${YELLOW}Not configured (auto-update disabled)${NC}"
    fi
    echo ""
}

show_menu() {
    clear
    show_version
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                ${CYAN}Zsh Configuration Script${NC}                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "  ${GREEN}0)${NC} Auto Install (Recommended - Full setup)"
    echo -e "  ${GREEN}1)${NC} Install Zsh"
    echo -e "  ${GREEN}2)${NC} Install Oh My Zsh"
    echo -e "  ${GREEN}3)${NC} Install essential plugins"
    echo -e "  ${GREEN}4)${NC} Set custom theme"
    echo -e "  ${GREEN}5)${NC} Install colorls"
    echo -e "  ${GREEN}6)${NC} Install AuroraMinimal Theme (Fast & Clean)"
    echo -e "  ${GREEN}7)${NC} Install Powerlevel10k theme"
    echo -e "  ${GREEN}8)${NC} Set Zsh as default shell"
    echo -e "  ${GREEN}9)${NC} Apply performance optimizations"
    echo -e "  ${GREEN}u)${NC} Check for updates"
    echo -e "  ${GREEN}q)${NC} Exit"
    echo ""
}

# Main execution
main() {
    # Check for updates on startup (with timeout) - only if repo is configured
    if [[ "${1}" != "--skip-update" && -n "$GITHUB_REPO" ]]; then
        timeout 10s bash -c 'check_for_updates' 2>/dev/null || print_warning "Update check timed out"
        echo ""
    fi
    
    # Check if running on supported system
    if ! command -v apt-get &> /dev/null; then
        print_error "This script is designed for Debian/Ubuntu systems"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Enter your choice: " choice
        echo ""
        
        case $choice in
            0) auto_install ;;
            1) install_zsh ;;
            2) install_oh_my_zsh ;;
            3) install_plugins ;;
            4) 
                echo -e "${CYAN}Available themes:${NC}"
                echo "  • AuroraMinimal (recommended)"
                echo "  • powerlevel10k/powerlevel10k"
                echo "  • agnoster"
                echo "  • robbyrussell"
                echo ""
                read -p "Enter theme name: " theme
                if [[ -n "$theme" ]]; then
                    select_theme "$theme"
                else
                    print_error "No theme specified"
                fi
                ;;
            5) install_colorls ;;
            6) install_aurora_minimal_theme ;;
            7) install_powerlevel10k ;;
            8) set_zsh_default ;;
            9) optimize_zsh_performance ;;
            u|U) check_for_updates ;;
            q|Q) 
                print_success "Thanks for using the Zsh Setup Script!"
                exit 0
                ;;
            *) 
                print_error "Invalid option. Please choose a valid option."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..." -r
    done
}

# Handle command line arguments
case "${1:-}" in
    --version|-v)
        show_version
        exit 0
        ;;
    --help|-h)
        show_version
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --version, -v     Show version information"
        echo "  --help, -h        Show this help message"
        echo "  --skip-update     Skip automatic update check"
        echo "  --auto            Run automatic installation"
        echo ""
        exit 0
        ;;
    --auto)
        auto_install
        exit $?
        ;;
    --skip-update)
        main --skip-update
        ;;
    *)
        main "$@"
        ;;
esac
