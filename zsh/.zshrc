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
