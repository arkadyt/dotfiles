" ------ Install Plug ------------ "
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



" ------ Set Mappings ------ "

let mapleader = ","

tnoremap <Esc> <C-\><C-n>			        " Easily leave embedded terminal
nnoremap <Leader>d :ALEFix<CR>			        " Run ESLint fixer
nnoremap <Leader>c :tabe ~/.config/nvim/init.vim<CR>    " Edit nvimrc
nnoremap <Leader>n :NERDTreeToggle<CR>                  " Toggle nerd tree

nnoremap <Leader>h :wincmd h<CR>                        " Move one window left
nnoremap <Leader>l :wincmd l<CR>                        " Move one window right
nnoremap <Leader>j :wincmd j<CR>                        " Move one window down
nnoremap <Leader>k :wincmd k<CR>                        " Move one window up
nnoremap <Leader>, :wincmd q<CR>                        " Close window
nnoremap <Leader>w :wincmd w<CR>                        " Next window
nnoremap <Leader>x :x<CR>                               " Save & Exit



" ------ Install Plugins ----- "

call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-fugitive'                       " Git wrapper
Plug 'w0rp/ale'					" Asynchronous Linting Engine
                                                " Deoplete autocompletion framework:
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }			
Plug 'carlitux/deoplete-ternjs' 		" JS autocomplete plugin for Deoplete
						" \ Requires ternjs installed
						" \ globally (npm i -g tern).
						" \ You can use Plug's post
						" \ install hook, unless global npm
						" \ installs require su rights on your
						" \ machine:
						" \ { 'do': 'npm i -g tern' }.
                                                " \ Also make sure to :checkhealth
                                                " \ for troubleshooting info.
Plug 'vim-airline/vim-airline'                  " Pretty status line
Plug 'joshdick/onedark.vim'                     " OneDark UI theme
Plug 'morhetz/gruvbox'                          " Gruvbox UI theme
Plug 'scrooloose/nerdtree'                      " NERDTree file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'              " Show git status in the NERDTree
Plug 'airblade/vim-gitgutter'                   " Show git diff in files
Plug 'pangloss/vim-javascript'                  " Vastly improved JS highlighting and identation
Plug 'mxw/vim-jsx'                              " JSX highlighting, depends on pangloss/vim-javascript
Plug 'jiangmiao/auto-pairs'                     " Much better brackets handling
Plug 'scrooloose/nerdcommenter'                 " Easy code commenting

call plug#end()



" ------ Configure Plugins ------- "

if (has("termguicolors"))                       " Enable true colors
  set termguicolors
endif



"""""""""""""""""""""""""""""""
" w0rp/ale
"
"""""""""""""""""""""""""""""""
                                                " Configure Ale fixers: 
let g:ale_fixers = {                            
  \ 'javascript': ['eslint']
  \ }



"""""""""""""""""""""""""""""""
" pangloss/vim-javascript
"
"""""""""""""""""""""""""""""""
let g:javascript_plugin_jsdoc = 1               " Enable JSDoc syntax highlighting



"""""""""""""""""""""""""""""""
" airblade/vim-gitgutter
"
"""""""""""""""""""""""""""""""
let g:gitgutter_map_keys = 0                    " Do not set up mappings 



"""""""""""""""""""""""""""""""
" Look & Feel
"
"""""""""""""""""""""""""""""""
let g:airline_theme='onedark'                   " Set airline theme [, gruvbox]
let g:deoplete#enable_at_startup = 1		" Enable Deoplete autocompletion framework

syntax on                                       " Enable syntax highlighting
colorscheme onedark                             " Set colorscheme



"""""""""""""""""""""""""""""""
" Other settings
"
"""""""""""""""""""""""""""""""
set number relativenumber       		" Enable line numbers
set expandtab                                   " Expand tab to spaces
set shiftwidth=2                                " Set 2 space chars per tab
set noshowmode                                  " Disable -- INSERT -- line
set updatetime=100                              " Vim's update time, for better vim-gitgutter support
set splitright                                  " Open vertical split right of current window

set foldmethod=indent                           " Fold based on indent
set foldnestmax=10                              " Deepest fold is 10 levels
set nofoldenable                                " Do not fold by default

                                                " Always show SignColumn for
                                                " regular files 
autocmd BufRead,BufNewFile *     setlocal signcolumn=yes
autocmd FileType tagbar,nerdtree setlocal signcolumn=no
