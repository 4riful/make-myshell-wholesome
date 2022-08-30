#!/bin/bash
#Author : Ariful Anik aka xettabyte
# echo 'This script will going to change your boring shell to wholesome one'
# colorplate
bold="\e[1m"
red="\e[1;31m"
green="\e[32m"
blue="\e[34m"
cyan="\e[0;36m"
yellow='\033[0;33m'
end="\e[0m"


function set_zsh(){
    sudo apt install zsh ;  
}



function set_ohmyzsh(){
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh ;
    if [ -f "install.sh" ]; then
     echo "installer script downloaded succesfully";chmod +x install.sh;bash install.sh ;
    else
      echo "installer script Not found" 
    fi
  
}




function clonep10k(){
  cd $HOME;
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc;

}




function set_extension() {
  cd /root/.oh-my-zsh/custom/plugins;
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ;
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ;
  cd ;
  sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/" .zshrc
 echo 'done'
 

}





function set_colorls(){
  sudo apt install ruby-full -y ;
  gem install colorls ;
  cd $HOME; 
  echo "source \$(dirname \$(gem which colorls))/tab_complete.sh" >> .zshrc
  echo "alias ls='colorls'" >> .zshrc
  echo "alias update='apt update && apt dist-upgrade'" >> .zshrc
  
}






function bannner(){
     echo -e '\n'
     echo -e " ${green}█▀▄▀█ ▄▀█ █▄▀ █▀▀ ▄▄ █▀▄▀█ █▀▀ ▄▄ █░█░█ █░█ █▀█ █░░ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀ "
     echo -e " █░▀░█ █▀█ █░█ ██▄ ░░ █░▀░█ ██▄ ░░ ▀▄▀▄▀ █▀█ █▄█ █▄▄ ██▄ ▄█ █▄█ █░▀░█ ██▄${end} "
     echo -e "                                coded with ${red}<3 ${end}By ${cyan}Ariful Anik AKA xettabye"
}






# execution parts start form here
# bannner
# echo -e "\n\n${red}[PROITP] : PLEASE MAKE SURE THAT YOU HAVE INSTALLED NERD FONT ON YOUR SYSTEM CORRECTLY , IF NOT PLEASE GO HERE AND FIND ONE FOR YOURS${end}"
# echo -e '[LINK]   : https://www.nerdfonts.com/font-downloads'
# echo -e "Are you want to install and configure zsh as your deafault shelll ?[y/n]" 
# read userinput
# if [ "$userinput" == "y" ]; then
# set_zsh && echo -e "Installing zsh to your system ......." 
# else
#  echo 'bye'
# fi
# echo 'Installing Oh-my-zsh'
# #set_ohmyzsh

# echo 'Downloading and Configuring zsh-autocompletation and zsh-autosuggestion'
# # set_extension
# echo 'Installing colorls '
# set_colorls
# echo "Now setting up p10k as deafault theme "
# # sedding_theme
# echo 'Done , Now restart your terminal or simply type zsh'
# #clonep10k

bannner
set_extension
set_colorls
clonep10k
