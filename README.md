# Development Environment 

## Preparation

- ctags
```
brew install ctags
or

brew tap universal-ctags/universal-ctags
brew install --HEAD universal-ctags
```

- cscope
```
brew install cscope
```

- brew install vim --override-system-vi --with-lua

- powerline font
```
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
```

- scalafmt
https://scalameta.org/scalafmt/docs/installation.html#nailgun
```
// https://scalameta.org/scalafmt/
brew tap olafurpg/scalafmt
brew install scalafmt
```

- ag
```
brew install ag
```

- metals
```
// https://scalameta.org/metals/
// https://scalameta.org/metals/docs/editors/vim.html

coursier bootstrap \
  --java-opt -Xss4m \
  --java-opt -Xms100m \
  --java-opt -Dmetals.client=coc.nvim \
  org.scalameta:metals_2.12:0.7.6 \
  -r bintray:scalacenter/releases \
  -r sonatype:snapshots \
  -o ~/bin/metals-vim -f
```

- flow-language-server
```
// https://github.com/flowtype/flow-language-server
yarn global add flow-language-server
```

- google-java-format
```
brew install google-java-format
```

<!--- ensime-sbt-->
<!--http://ensime.github.io/editors/vim/install/-->
<!--```-->
<!--pip install websocket-client sexpdata-->
<!--```-->

## install
```
./install
```

