" ------ Install Plug ------------ "
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



" ------ Mapping keys ------------ "

let mapleader = ","

tnoremap <Esc> <C-\><C-n>			        " Make it easy to leave embedded terminal
nnoremap <Leader>d :ALEFix<CR>			        " Run ESLint fixer
nnoremap <Leader>c :tabe ~/.config/nvim/init.vim<CR>    " Edit nvimrc


" ------ Installing plugins ------ "

call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-fugitive'                       " Git wrapper
Plug 'w0rp/ale'					" Asynchronous Linting Engine
                                                " Deoplete autocompletion framework:
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }			
Plug 'carlitux/deoplete-ternjs' 		" JS autocomplete plugin for Deoplete
						" \ Requires ternjs installed
						" \ globally (npm i -g tern).
						" \ You can use Plug's post
						" \ install hook, unless npm
						" \ requires su rights on your
						" \ machine:
						" \ { 'do': 'npm i -g tern' }.
                                                " \ Also make sure to :checkhealth
                                                " \ for troubleshooting info.
Plug 'vim-airline/vim-airline'                  " Pretty status line
Plug 'joshdick/onedark.vim'                     " OneDark UI theme

call plug#end()



" ------ Configure Plugins ------- "

if (has("termguicolors"))                       " Enable true colors
  set termguicolors
endif
syntax on                                       " Enable syntax highlighting
colorscheme onedark                             " Set colorscheme
let g:airline_theme='onedark'                   " Set airline theme
let g:airline_powerline_fonts=1                 " Enable powerline fonts for Airline
set guifont=Arimo\ for\ Powerline:h8

let g:deoplete#enable_at_startup = 1		" Enable Deoplete framework
                                                " Configure Ale fixers: 
let g:ale_fixers = {                            
  \ 'javascript': ['eslint']
  \ }

let g:netrw_localrmdir='rm -r'                  " Allow netrw to remove non-empty local directories

set number					" Enable line numbers
set expandtab                                   " Expand tab to spaces
set shiftwidth=2                                " Set 2 space chars per tab
set noshowmode                                  " Disable -- INSERT -- line
