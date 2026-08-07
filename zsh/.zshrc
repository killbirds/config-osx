#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# alias
alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"
alias vimdiff="nvim -d"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# kubectl 자동완성
# https://kubernetes.io/ko/docs/tasks/tools/included/optional-kubectl-configs-zsh/
(( $+commands[kubectl] )) && source <(kubectl completion zsh)

# zoxide — 디렉토리 점프 (fasd 대체)
# fasd는 2018년 이후 유지보수가 끊겼다. prezto fasd 모듈이 제공한 사용자 명령은
# 대화형 점프 `j` 하나뿐이었으므로 zoxide의 `zi`에 같은 이름을 붙여 습관을 유지한다.
#   z <검색어>   빈도·최근성 기준으로 바로 이동
#   zi <검색어>  fzf로 후보를 골라 이동 (기존 j와 같은 동작)
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  alias j='zi'
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# export NVIM_AVANTE_PROVIDER=copilot

# for metals, bloop
export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"

# for krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by codebase-memory-mcp install
export PATH="$HOME/.local/bin:$PATH"


# 사내 전용 설정은 추적하지 않는 ~/.zshrc.local에 둔다 (공개 저장소 유입 방지).
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
