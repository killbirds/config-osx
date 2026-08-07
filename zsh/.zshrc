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
#
# EXTENDED_GLOB 아래에서 nvm이 깨진다. prezto completion 모듈이 이 옵션을 켜고
# (~/.zprezto/modules/completion/init.zsh), nvm.sh의 ${NVM_ALIAS_LINE%%#*}가
# 그 상태에서 "bad pattern: #*"로 실패한다. 그러면 ~/.nvm/alias/default가
# 해석되지 않아 지정한 기본 버전이 활성화되지 않고 조용히 system node로 떨어진다.
# 증상: nvm current -> system, node -> /opt/homebrew/bin/node
# 확인: nvm_alias default  ->  nvm_alias:32: bad pattern: #*
#       unsetopt extendedglob 후 같은 명령 -> 24
export NVM_DIR="$HOME/.nvm"
export NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"

# nvm.sh를 시작마다 source하면 기본 버전 활성화까지 수행하면서 셸 시작이
# 0.43초 -> 1.54초가 된다(실측). herdr로 패인을 여럿 띄우면 감당이 안 된다.
# 그래서 두 갈래로 나눈다.
#   (1) 기본 버전의 bin만 PATH에 직접 넣어 node/npm/npx를 즉시 쓸 수 있게 한다.
#   (2) nvm 명령 자체는 처음 호출될 때 로드한다.
() {
  [[ -r "$NVM_DIR/alias/default" ]] || return
  local want="$(<"$NVM_DIR/alias/default")"
  local -a cands
  # alias가 "24"처럼 major만 가리킬 수 있으므로 설치된 매칭 버전 중 최신을 고른다.
  # numeric_glob_sort가 없으면 v24.9.0이 v24.13.0보다 뒤로 정렬된다.
  setopt local_options numeric_glob_sort
  cands=("$NVM_DIR/versions/node/v${want#v}"*(/N))
  (( $#cands )) || return
  path=("${cands[-1]}/bin" $path)
}

# nvm / node 버전 전환이 필요할 때만 nvm.sh를 로드하는 지연 셸.
# EXTENDED_GLOB 아래에서 nvm.sh의 ${NVM_ALIAS_LINE%%#*}가 "bad pattern: #*"로
# 깨지므로(prezto completion 모듈이 이 옵션을 켠다) 로드 중에는 반드시 끈다.
# 이 때문에 default alias가 해석되지 않아 조용히 system node로 떨어지고 있었다.
nvm() {
  unfunction nvm
  setopt local_options no_extended_glob
  source "$NVM_SH"
  [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && \
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  # 로드 후에도 nvm 내부가 EXTENDED_GLOB에 취약하므로 호출마다 끈다.
  functions[_nvm_upstream]=$functions[nvm]
  nvm() {
    setopt local_options no_extended_glob
    _nvm_upstream "$@"
  }
  nvm "$@"
}

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
