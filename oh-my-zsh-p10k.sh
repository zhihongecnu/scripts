#!/bin/bash

set -e

# Check if zsh is already installed
if ! command -v zsh &> /dev/null; then
    echo "zsh is not installed. Installing..."
    sudo apt install zsh -y
else
    echo "zsh is already installed"
fi

# oh-my-zsh
OMZ_DIR=$HOME/.oh-my-zsh
if [ ! -d "$OMZ_DIR" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
    echo "oh-my-zsh already cloned, skipping"
fi
if [ ! -f "$HOME/.zshrc" ]; then
    cp "$OMZ_DIR/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

# download plugins of oh-my-zsh
ZSH_CUSTOM="$OMZ_DIR/custom"
check_and_clone_plugin() {
    local plugin_name=$1
    local plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    if [ ! -d "$plugin_dir" ]; then
        git clone "https://github.com/zsh-users/$plugin_name.git" "$plugin_dir"
    else
        echo "$plugin_name already cloned, skipping"
    fi
}

check_and_clone_plugin "zsh-syntax-highlighting"
check_and_clone_plugin "zsh-autosuggestions"
check_and_clone_plugin "zsh-completions"

# edit config and theme
if ! grep -q "autoload -U compinit && compinit" ~/.zshrc; then
    echo "autoload -U compinit && compinit" >> ~/.zshrc
fi
sed -i '/^plugins=/c\plugins=(git sudo z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc

# use p10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "powerlevel10k theme already cloned, skipping"
fi
sed -i '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc

# change default shell
if [ ! -f ~/.bash_profile ]; then
    touch ~/.bash_profile
    echo ".bash_profile created"
fi
changeshell="exec $(which zsh) -l"
if ! grep -q "$changeshell" ~/.bash_profile; then
    echo "$changeshell" >> ~/.bash_profile
fi

echo "Installation complete!"