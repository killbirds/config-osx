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

Plug 'terryma/vim-multiple-cursors'
"Plug 'mg979/vim-visual-multi'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'rizzatti/dash.vim'

Plug 'w0rp/ale'
"Plug 'vim-syntastic/syntastic'
"Plug 'Chiel92/vim-autoformat'

Plug 'qpkorr/vim-bufkill'
Plug 'airblade/vim-gitgutter'
"Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'
"Plug 'ternjs/tern_for_vim'

"Plug 'sheerun/vim-polyglot'

Plug 'derekwyatt/vim-scala'
Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript'
Plug 'digitaltoad/vim-pug'
Plug 'fatih/vim-go'
Plug 'groenewege/vim-less'
Plug 'vim-ruby/vim-ruby'
Plug 'plasticboy/vim-markdown'
Plug 'elmcast/elm-vim'
Plug 'posva/vim-vue'
Plug 'jparise/vim-graphql'
Plug 'dart-lang/dart-vim-plugin'

" use yats.vim for typescript because  https://github.com/neoclide/coc.nvim/issues/135
"Plug 'leafgarland/typescript-vim'
Plug 'HerringtonDarkholme/yats.vim'

Plug 'altercation/vim-colors-solarized'

Plug 'jeetsukumaran/vim-buffergator'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" removed because use coc.nvim
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }

" removed because use coc.nvim
"if has('nvim')
"  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"else
"  Plug 'Shougo/deoplete.nvim'
"  Plug 'roxma/nvim-yarp'
"  Plug 'roxma/vim-hug-neovim-rpc'
"endif

call plug#end()

