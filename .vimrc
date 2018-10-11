set nocompatible		" be iMproved, required
filetype off			" required

" \\\ *** VUNDLE *** ///
" set the runtime path to include Vundle and initialize
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()
" alternatively pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')
" let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'
" Git wrapper
" Plugin 'tpope/vim-fugitive'
" JS Beautifier
" Plugin 'maksimr/vim-jsbeautify'
" call vundle#end()
" filetype plugin indent on

call plug#begin('~/.vim/plugged')
" Plug ''
call plug#end()

" Add line numbers
set number

" No hard tabs
set expandtab
set shiftwidth=4
set softtabstop=4

" Key mapping
:map <F2> :echo 'Current time is ' . strftime('%c')<CR>
:map <C-F> :call JsBeautify()<CR>
:map <F3> :call JsBeautify()<CR>
