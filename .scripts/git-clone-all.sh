#!/bin/bash

if ! [ -x "$(command -v git)" ]; then
    echo "[$0] git is not installed, please install it first"
    exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
    echo "[$0] jq is not installed, please install it first"
    exit 1
fi

username=$1

if [ -z "$username" ]; then
    echo "[$0] Please provide a username as the first argument"
    exit 1
fi

if [ ! -d "$HOME/repos/$username" ]; then
    echo "[$0] $HOME/repos/$username doesn't exist, please create it first, and create a .gitconfig file with your credentials. Then update the root .gitconfig to include the following:"
    echo "[includeIf \"gitdir:~/repos/$username/\"]"
    echo "    path = ~/repos/$username/.gitconfig"
    exit 1
fi

if [ ! -f "$HOME/repos/$username/.gitconfig" ]; then
    echo "[$0] $HOME/repos/$username/.gitconfig doesn't exist, please create it first, and add your credentials"
    exit 1
fi

cd "$HOME/repos/$username"

for url in $(curl -s "https://api.github.com/users/$username/repos?per_page=100" | jq -r '.[].clone_url'); do
    git clone "$url"
done