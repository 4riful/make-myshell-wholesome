#!/bin/bash

# Ensure the script is run with normal user privileges, not root
if [[ $EUID -eq 0 ]]; then
    echo "🚫 This script should not be run as root. Please run it as your normal user."
    exit 1
fi

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

# Main menu for selections
echo "📋 Select the features you want to install/configure:"
echo "  1) Install Zsh"
echo "  2) Install Oh My Zsh"
echo "  3) Install zsh-autosuggestions & zsh-syntax-highlighting plugins"
echo "  4) Set theme (Enter theme name after selection)"
echo "  5) Install colorls"
echo "  6) Exit"
read -p "Enter your choice (1-6): " choice

case $choice in
    1) install_zsh ;;
    2) install_oh_my_zsh ;;
    3) install_plugins ;;
    4) 
        echo "🎨 Enter the theme name (e.g., agnoster, robbyrussell):"
        read theme
        select_theme $theme ;;
    5) install_colorls ;;
    6) echo "👋 Exiting script." ;;
    *) echo "❌ Invalid option selected." ;;
esac

echo "🎉 Operation completed. Please restart your terminal or source your .zshrc file to apply the changes."
