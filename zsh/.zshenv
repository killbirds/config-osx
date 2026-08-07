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

# 비밀정보는 추적되지 않는 ~/.zshenv.local에 둔다 (저장소에 커밋되지 않도록).
if [[ -f "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi
