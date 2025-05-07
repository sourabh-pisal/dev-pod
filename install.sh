#!/bin/bash

# Exit immediately
set -e 

# Set dotfiles marker for idempotency
DOTFILES_MARKER="$HOME/.dotfiles-installed"

if [ -f "$DOTFILES_MARKER" ]; then
  echo "Dotfiles already installed, skipping..."
  exit 0
fi

# Update package manager
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y 

# Install git
sudo apt-get install build-essential procps curl file git zsh -y

# Create Workplace dir
mkdir -p $HOME/Workplace

# cleanup old dotfiles
rm -rf $HOME/Workplace/dotfiles

# Install omzsh
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add homebrew to PATH of current shell
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install required packages from homebrew
brew install $(curl -fsSL https://raw.githubusercontent.com/sourabh-pisal/setup-ubuntu/refs/heads/main/brew-package-list.txt)

# Change dir to Workplace
cd $HOME/Workplace

# Create alias for dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/Workplace/dotfiles --work-tree=$HOME"

# Clone dotfiles bare repository
git clone --bare https://github.com/sourabh-pisal/dotfiles.git $HOME/Workplace/dotfiles

# Change dir to dotfiles
cd $HOME/Workplace/dotfiles

# Setup dotfiles
/usr/bin/git --git-dir=$HOME/Workplace/dotfiles --work-tree=$HOME switch -f mainline
/usr/bin/git --git-dir=$HOME/Workplace/dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no

# Set shell to zsh
if command -v zsh >/dev/null; then
  sudo chsh -s $(command -v zsh) $USER
fi


# Create marker file
touch "$DOTFILES_MARKER"
