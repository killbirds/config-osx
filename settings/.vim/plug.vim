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
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
"Plug 'majutsushi/tagbar'
Plug 'christoomey/vim-tmux-navigator'
Plug 'terryma/vim-multiple-cursors'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'rizzatti/dash.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/syntastic'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-eunuch'
Plug 'Chiel92/vim-autoformat'
Plug 'ervandew/supertab'
Plug 'shougo/neocomplete.vim'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'editorconfig/editorconfig-vim'
"Plug 'ternjs/tern_for_vim'

"Plug 'sheerun/vim-polyglot'
Plug 'derekwyatt/vim-scala'
Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript'
Plug 'digitaltoad/vim-jade'
Plug 'fatih/vim-go'
Plug 'groenewege/vim-less'
Plug 'vim-ruby/vim-ruby'
Plug 'plasticboy/vim-markdown'

Plug 'altercation/vim-colors-solarized'

Plug 'lambdatoast/elm.vim'

Plug 'jeetsukumaran/vim-buffergator'

"Plug 'ensime/ensime-vim'
call plug#end()

