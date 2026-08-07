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

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
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
eval "$(/opt/homebrew/bin/brew shellenv)"

# chatGPT
[[ -r "$HOME/.chatgpt" ]] && source "$HOME/.chatgpt"


# 사내 전용 설정은 추적하지 않는 ~/.zprofile.local에 둔다 (공개 저장소 유입 방지).
if [[ -f "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
