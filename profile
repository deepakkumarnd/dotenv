#!/bin/bash
# initializer for my profile

DOTENV_BASE_PATH=$HOME/.dotenv

echo "Loading profile"

export PATH=$PATH:$DOTENV_BASE_PATH/bin

source $DOTENV_BASE_PATH/git
source $DOTENV_BASE_PATH/shortcuts
source $DOTENV_BASE_PATH/ruby
source $DOTENV_BASE_PATH/net
source /home/deepak/.rvm/scripts/rvm


# bash prompt
parse_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

PS1='\[\e[34m\]\u@\h\[\e[0m\]:\[\e[32m\]\w\[\e[33m\]$(
  branch=$(parse_git_branch)
  [ -n "$branch" ] && echo " ($branch)"
)\[\e[0m\]\$ '
