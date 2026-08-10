#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

# nvim을 쓰므로 EDITOR/VISUAL도 nvim을 가리켜야 한다.
# prezto 기본값은 'vi'인데, 셸 alias(vi=nvim)는 다른 프로그램이 $EDITOR를 exec할 때
# 적용되지 않는다. macOS에서 vi/vim은 Homebrew vim 9.2로 해석되므로 git commit,
# crontab -e, kubectl edit 등이 전부 vim으로 열려 이 저장소의 nvim 설정이
# 적용되지 않았다.
# prezto 기본값은 `[[ -z "$EDITOR" ]]` 가드를 두지만 여기서는 쓰지 않는다.
# herdr 서버 프로세스의 환경에 이전 값(EDITOR=vi)이 굳어 있고 모든 패인이 그것을
# 상속하므로, 가드가 있으면 서버를 재시작할 때까지 새 값이 영원히 적용되지 않는다.
# (실측: herdr server의 환경에 EDITOR=vi VISUAL=vi 가 남아 있었다)
# 세션 단위로 다른 에디터를 쓰려면 명령 앞에 붙이면 된다: EDITOR=vim git commit
if (( $+commands[nvim] )); then
  export EDITOR='nvim'
else
  export EDITOR='vi'
fi
export VISUAL="$EDITOR"
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

#
# Language
#

# ko_KR.UTF-8을 의도적으로 쓴다.
# prezto 기본값은 en_US.UTF-8인데, 실제로는 iTerm2가 "Set locale variables
# automatically"로 ko_KR.UTF-8을 주입하므로 이 블록이 한 번도 발동하지 않아
# 선언이 사실과 달랐다. 선언을 실제 값에 맞춘다.
# 이렇게 두면 iTerm2 밖(다른 터미널, 원격 접속, launchd)에서도 같은 로케일이 된다.
# 영향: ls/sort 정렬 순서가 로케일 규칙을 따르고, 일부 CLI 메시지가 한국어로 나온다.
if [[ -z "$LANG" ]]; then
  export LANG='ko_KR.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X to enable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# brew
# 경로를 하드코딩하지 않는다. Apple Silicon은 /opt/homebrew, Intel은 /usr/local,
# custom prefix도 있다. 하드코딩하면 그 밖의 장비에서 이 줄이 조용히 실패하고
# HOMEBREW_PREFIX가 비어 .zshrc의 fzf 로딩까지 함께 죽는다.
# (.zshrc는 같은 이유로 $HOMEBREW_PREFIX를 쓰고 그 근거를 주석으로 남겨 두었다)
# shellenv가 실제로 출력을 낼 때만 break 한다. 파일이 실행 가능하다는 것만으로
# 멈추면, 깨진 brew가 앞 후보에 있을 때 뒤 후보를 시도하지 않는다.
for _brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  [[ -x "$_brew_candidate" ]] || continue
  if _brew_env="$("$_brew_candidate" shellenv 2>/dev/null)" && [[ -n "$_brew_env" ]]; then
    eval "$_brew_env"
    break
  fi
done
unset _brew_candidate _brew_env

# chatGPT
[[ -r "$HOME/.chatgpt" ]] && source "$HOME/.chatgpt"


# 사내 전용 설정은 추적하지 않는 ~/.zprofile.local에 둔다 (공개 저장소 유입 방지).
if [[ -f "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
