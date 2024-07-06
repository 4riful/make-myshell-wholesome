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
