" Load vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Plug for vim-plug
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-eunuch'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
"Plug 'majutsushi/tagbar'
Plug 'christoomey/vim-tmux-navigator'

Plug 'mg979/vim-visual-multi', {'branch': 'master'}

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'rizzatti/dash.vim'

Plug 'w0rp/ale'

Plug 'qpkorr/vim-bufkill'
Plug 'airblade/vim-gitgutter'
"Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'

"Plug 'sheerun/vim-polyglot'

"Plug 'derekwyatt/vim-scala'
"Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript'
"Plug 'digitaltoad/vim-pug'
Plug 'fatih/vim-go'
"Plug 'groenewege/vim-less'
"Plug 'vim-ruby/vim-ruby'
Plug 'preservim/vim-markdown'
Plug 'elmcast/elm-vim'
Plug 'jparise/vim-graphql'
"Plug 'dart-lang/dart-vim-plugin'
Plug 'leafgarland/typescript-vim'

Plug 'altercation/vim-colors-solarized'

Plug 'jeetsukumaran/vim-buffergator'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

