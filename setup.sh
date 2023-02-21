#!/bin/bash
#Author : Ariful Anik aka xettabyte
# echo 'This script will going to change your boring shell to wholesome one'
# colorplate


# Define text colors and emojis
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'
WARNING='⚠️ '
CHECK='✔️ '

# Warning message with emoji and color
function warning() {
  echo -e "${YELLOW}${WARNING}$1${NC}"
}

# Success message with emoji and color
function success() {
  echo -e "${GREEN}${CHECK} $1 ${NC}"
}


# Check for confirmation before proceeding
function confirm() {
  read -p $'\e[33m'"$1 [y/n]"$'\e[0m ' -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    return 0
  else
    return 1
  fi
}
bannner
# Install dependencies for terminal colors and zsh
warning "This script will install dependencies for terminal colors and set zsh as the default shell."
if confirm "Do you want to proceed?"
then
  sudo apt-get update
  sudo apt-get install -y git zsh curl
  success "Dependencies installed successfully."
else
  warning "Installation cancelled by user."
  exit 1
fi

# Set zsh as the default shell
warning "This script will set zsh as the default shell."
if confirm "Do you want to proceed?"
then
  chsh -s /bin/zsh

success "Zsh set as the default shell successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Install Oh My Zsh
warning "This script will install Oh My Zsh."
if confirm "Do you want to proceed?"
then
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
success "Oh My Zsh installed successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Install zsh-autosuggestions
warning "This script will install zsh-autosuggestions."
if confirm "Do you want to proceed?"
then
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
success "zsh-autosuggestions installed successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Install zsh-completions
warning "This script will install zsh-completions."
if confirm "Do you want to proceed?"
then
git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
success "zsh-completions installed successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Install Powerlevel10k theme for Oh My Zsh
warning "This script will install the Powerlevel10k theme for Oh My Zsh."
if confirm "Do you want to proceed?"
then
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k/powerlevel10k"/' ~/.zshrc
success "Powerlevel10k theme installed successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Reload zsh configuration
warning "This script will reload the zsh configuration."
if confirm "Do you want to proceed?"
then
source ~/.zshrc
success "Zsh configuration reloaded successfully."
else
warning "Installation cancelled by user."
exit 1
fi

#Display final success message
echo -e "${GREEN}All installations completed successfully.${NC}"
echo -e "${YELLOW}Please logout and log back in for the changes to take effect.${NC}"


function bannner(){
     echo -e '\n'
     echo -e " ${GREEN}█▀▄▀█ ▄▀█ █▄▀ █▀▀ ▄▄ █▀▄▀█ █▀▀ ▄▄ █░█░█ █░█ █▀█ █░░ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀ "
     echo -e " █░▀░█ █▀█ █░█ ██▄ ░░ █░▀░█ ██▄ ░░ ▀▄▀▄▀ █▀█ █▄█ █▄▄ ██▄ ▄█ █▄█ █░▀░█ ██▄${NC} "
     echo -e "                                coded with ${RED}<3 ${NC}By ${GREEN}Ariful Anik AKA xettabyte${NC}"
}









#bannner

