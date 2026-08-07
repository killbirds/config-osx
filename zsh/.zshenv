#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# path 중복 제거를 모든 셸에서 보장한다.
# prezto는 이 선언을 .zprofile에만 두는데, 그건 로그인 셸에서만 읽힌다.
# 그래서 non-login interactive 셸(중첩 zsh, 일부 런처)에서는 unique 속성이 없어
# .zshrc의 path 조작이 중복을 쌓았다. 실측:
#   zsh -l -i  -> typeset -aUT, 35개
#   zsh -i     -> typeset -aT,  46개  (unique 없음)
typeset -gU cdpath fpath mailpath path

# 비밀정보는 추적되지 않는 ~/.zshenv.local에 둔다 (저장소에 커밋되지 않도록).
if [[ -f "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi
