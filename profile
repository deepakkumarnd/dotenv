#!/bin/bash
# initializer for my profile

DOTENV_BASE_PATH=$HOME/.env

if [ ! -d "$DOTENV_BASE_PATH" ]; then
  echo "Error: $DOTENV_BASE_PATH does not exist. Rename the cloned dotenv repository to .env." >&2
  return 1 2>/dev/null || exit 1
fi

echo "Loading profile"

export PATH=$PATH:$DOTENV_BASE_PATH/bin

source $DOTENV_BASE_PATH/git
source $DOTENV_BASE_PATH/shortcuts
source $DOTENV_BASE_PATH/ruby
source $DOTENV_BASE_PATH/net


# shell prompt
parse_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

if [ -n "$ZSH_VERSION" ]; then
  setopt PROMPT_SUBST
  PS1='%F{blue}%n@%m%f:%F{green}%~%F{yellow}$(
    branch=$(parse_git_branch)
    [ -n "$branch" ] && echo " ($branch)"
  )%f%# '
else
  PS1='\[\e[34m\]\u@\h\[\e[0m\]:\[\e[32m\]\w\[\e[33m\]$(
    branch=$(parse_git_branch)
    [ -n "$branch" ] && echo " ($branch)"
  )\[\e[0m\]\$ '
fi
