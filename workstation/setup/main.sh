# 
# Environment setup script.
# Expects dotfiles repo to be located at $HOME/code/dotfiles
#

sudo apt install -y tree neovim neofetch cmatrix git htop curl wget

# install bash aliases link
SOURCE=$HOME/code/dotfiles/workstation/bash/.bash_aliases
TARGET=$HOME/.bash_aliases
if [[ -f "$TARGET" ]]; then
	mv $TARGET $TARGET.bkp
fi
ln -s $SOURCE $TARGET

# install neovim config
SOURCE=$HOME/code/dotfiles/workstation/nvim/init.vim
TARGET=$HOME/.config/nvim/init.vim
if [[ -f "TARGET" ]]; then
	mv $TARGET $TARGET.bkp
fi
ln -s $SOURCE $TARGET 
