#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# 자동완성 캐시 디렉토리를 fpath에 먼저 넣는다.
# prezto completion 모듈이 compinit을 실행하므로 그보다 앞이어야 한다.
_zsh_comp_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"

# kubectl 자동완성 — 매 시작 `kubectl completion zsh`를 실행하면 22~23ms가 든다(실측).
# 생성물을 _kubectl 함수 파일로 캐시한다. 출력 첫 줄이 이미 `#compdef kubectl`이라
# fpath autoload 파일로 그대로 쓸 수 있다.
#
# 재생성 판정에 `-nt`를 쓰면 안 된다. zsh의 -nt는 심링크를 역참조하므로
# /opt/homebrew/bin/kubectl 대신 Cellar 바이너리의 mtime(=bottle 빌드 날짜)을 본다.
# 빌드 날짜는 항상 설치 날짜보다 이전이라, 캐시가 새 버전의 빌드 날짜보다 나중이면
# 업그레이드를 감지하지 못하고 stale completion이 남는다. 실측으로 재현했다:
#   바이너리 빌드일 2026-01-01 / 심링크 재생성 지금 / 캐시 2026-08-07
#     [[ link -nt cache ]] -> 거짓 (재사용, 잘못됨)
#     zstat -L 비교         -> 재생성 필요 (정확)
# lstat(zstat -L)으로 심링크 자체의 mtime을 본다. brew는 업그레이드 때 심링크를
# 다시 만들므로 그 mtime이 곧 설치 시각이다. 심링크가 아니어도 같은 값이 나온다.
# zstat은 zsh/stat 모듈의 빌트인이라 서브프로세스를 띄우지 않는다.
if (( $+commands[kubectl] )); then
  zmodload -F zsh/stat b:zstat
  () {
    local cache="$_zsh_comp_cache/_kubectl"
    local -a bin_mt cache_mt
    if [[ -s "$cache" ]]; then
      zstat -L -A bin_mt   +mtime "$commands[kubectl]" 2>/dev/null || return
      zstat    -A cache_mt +mtime "$cache"             2>/dev/null || return
      (( bin_mt[1] > cache_mt[1] )) || return
    fi
    mkdir -p "$_zsh_comp_cache"
    kubectl completion zsh >| "$cache"
  }
fi

fpath=("$_zsh_comp_cache" $fpath)

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
#
# (1)은 nvm의 alias 해석을 흉내내는 것이므로 다룰 수 있는 형태를 좁게 제한한다.
# nvm은 주석 제거, alias chain, `node`/`stable`/`lts/*` 같은 이름까지 해석하는데
# (nvm.sh의 nvm_alias/nvm_resolve_alias) 그걸 전부 재구현하지 않는다.
# 대신 "순수 버전 문자열"만 빠른 경로로 처리하고, 그 밖의 값은 nvm.sh를 실제로
# 로드해 nvm이 직접 해석하게 한다. 느려지지만 틀리지 않는다.
# 실측으로 확인한 실패 형태 — 이 가드가 없으면 전부 조용히 미적용된다:
#   "24 # comment"  후보 0개
#   "lts/*"         후보 0개
#   "node"/"stable" 후보 0개
#   빈 값           후보 3개 -> 아무 버전이나 선택 (더 나쁘다)
() {
  [[ -r "$NVM_DIR/alias/default" ]] || return

  # 첫 줄만 취하고 주석(#...)과 앞뒤 공백을 제거한다
  local -a lines
  lines=("${(f)$(<"$NVM_DIR/alias/default")}")
  local want="${lines[1]%%\#*}"
  want="${want##[[:space:]]##}"
  want="${want%%[[:space:]]##}"

  # 순수 버전 문자열만 빠른 경로. 그 밖(빈 값, lts/*, node, stable, alias 이름)은
  # nvm에게 맡긴다.
  if [[ -z "$want" || "$want" != (v|)<->(.<->)#(-*|) ]]; then
    setopt local_options no_extended_glob
    source "$NVM_SH"
    return
  fi

  local -a cands
  # alias가 "24"처럼 major만 가리킬 수 있으므로 설치된 매칭 버전 중 최신을 고른다.
  # numeric_glob_sort가 없으면 v24.9.0이 v24.13.0보다 뒤로 정렬된다.
  setopt local_options numeric_glob_sort
  cands=("$NVM_DIR/versions/node/v${want#v}"*(/N))
  if (( ! $#cands )); then
    # 버전 형태인데 설치본이 없다 — 조용히 넘기지 말고 nvm이 판단하게 한다
    setopt local_options no_extended_glob
    source "$NVM_SH"
    return
  fi
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
  # `nvm unload`는 upstream이 아는 함수만 지우므로 _nvm_upstream이 셸에 남는다.
  # 래퍼가 직접 정리한다.
  functions[_nvm_upstream]=$functions[nvm]
  nvm() {
    setopt local_options no_extended_glob
    if [[ "$1" == unload ]]; then
      _nvm_upstream "$@" && unfunction _nvm_upstream nvm 2>/dev/null
      return
    fi
    _nvm_upstream "$@"
  }
  nvm "$@"
}

# zoxide — 디렉토리 점프 (fasd 대체)
# prezto fasd 모듈이 제공한 사용자 명령은 대화형 점프 `j` 하나뿐이었으므로
# zoxide의 `zi`에 같은 이름을 붙여 습관을 유지한다.
# (fasd가 "2018년 이후 유지보수 중단"이라는 것은 upstream clvv/fasd 얘기다.
#  prezto가 쓰는 것은 서브모듈 whjvenyl/fasd이고 2025-09에도 태그가 있었다.
#  교체 사유는 zoxide 쪽이 더 활발히 관리되고 도구 생태계가 낫다는 것이다.)
#   z <검색어>   빈도·최근성 기준으로 바로 이동
#   zi <검색어>  fzf로 후보를 골라 이동 (기존 j와 같은 동작)
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  alias j='zi'
fi

# fzf 키바인딩과 자동완성
#   ^R      히스토리 퍼지 검색  (vi 삽입 모드에서 ^R은 원래 redisplay로 비어 있었다)
#   ^T      현재 트리에서 파일 선택 후 커맨드라인에 삽입
#   alt+c   하위 디렉토리 선택 후 cd
#   **<TAB> 경로 퍼지 완성
#
# 경로를 고정한다. `$(brew --prefix fzf)`로 쓰면 서브프로세스 때문에 셸 시작이
# 70ms 늘어난다(실측 0.240s -> 0.310s). 위치가 바뀌면 아래 조건에서 걸러진다.
_fzf_shell="/opt/homebrew/opt/fzf/shell"
if [[ -d "$_fzf_shell" ]]; then
  source "$_fzf_shell/key-bindings.zsh"
  source "$_fzf_shell/completion.zsh"
fi
unset _fzf_shell

# SDKMAN
# 원래 "THIS MUST BE AT THE END OF THE FILE" 주석이 붙어 있었으나 아래로 PATH
# 조작이 계속 이어져 사실이 아니었다. 실제로 옮기면 SDKMAN 후보가 .local/bin,
# bun 등보다 앞서게 되어 우선순위가 바뀌므로 위치는 그대로 두고 주석만 고친다.
# 현재 gradle, mvn, scala, sbt는 SDKMAN이 PATH상 첫 번째다(java/javac은
# /usr/bin 스텁이 먼저지만 JAVA_HOME을 따라 같은 JDK를 실행한다).
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# export NVIM_AVANTE_PROVIDER=copilot

# ── PATH ──────────────────────────────────────────────────
# `export PATH="...:$PATH"` 문자열 대입은 .zprofile의 `typeset -gU path`를
# 우회해 중복이 쌓인다(실측: zsh 5.9에서 배열 대입은 중복 제거, 문자열 대입은 유지).
# 배열로 대입하면 중복이 자동 제거된다. 앞의 항목이 남으므로 prepend/append
# 방향을 그대로 옮기면 기존 명령 우선순위가 보존된다.

# metals, bloop — append (기존 경로가 우선)
path=($path "$HOME/Library/Application Support/Coursier/bin")

# krew
path=("${KREW_ROOT:-$HOME/.krew}/bin" $path)

# Antigravity
path=("$HOME/.antigravity/antigravity/bin" $path)

# bun
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# 로컬 bin — Antigravity와 codebase-memory-mcp 설치 스크립트가 각각 추가해
# 같은 줄이 두 번 있었다. 한 번만 두고 가장 앞에 유지한다.
path=("$HOME/.local/bin" $path)


# 사내 전용 설정은 추적하지 않는 ~/.zshrc.local에 둔다 (공개 저장소 유입 방지).
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
