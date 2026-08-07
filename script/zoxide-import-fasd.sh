#!/bin/bash
#
# fasd 디렉토리 히스토리를 zoxide로 이관한다.
#
# 왜 스크립트가 필요한가 — `zoxide import fasd` 를 그냥 쓰면 안 된다.
# 두 도구의 기본 DB 경로가 다르다.
#   fasd  : $_FASD_DATA -> $XDG_CACHE_HOME/fasd -> ~/.cache/fasd
#           (prezto 번들 fasd의 external/fasd 참조)
#   zoxide: $_FASD_DATA -> ~/.fasd
# 즉 인자 없이 실행하면 zoxide가 ~/.fasd 를 읽는데, 그건 fasd가 실제로 쓰던
# DB가 아니라 오래된 잔재일 수 있다. 실제로 그렇게 이관해서 8개월 묵은 DB
# 429행(유효 디렉토리 61개)만 넘어간 적이 있다. 활성 DB는 412행이었고
# 유효 디렉토리 156개였다.
#
# 그리고 `--merge`는 기존 점수에 더하는 방식이라 반복 실행하면 점수가 부풀려진다.
# 마커 파일로 한 번만 돌게 막는다.
#
# 사용법:
#   ./script/zoxide-import-fasd.sh            # 아직 이관하지 않았으면 이관
#   ./script/zoxide-import-fasd.sh --force    # 마커를 무시하고 다시 이관 (점수 누적됨)
#   ./script/zoxide-import-fasd.sh --dry-run  # 어느 DB를 읽을지만 출력

set -euo pipefail

MARKER="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.fasd-imported-to-zoxide"
FORCE=false
DRY_RUN=false

case "${1:-}" in
  "")        ;;
  --force)   FORCE=true ;;
  --dry-run) DRY_RUN=true ;;
  *)
    echo "알 수 없는 인자: $1" >&2
    echo "사용법: $0 [--force | --dry-run]" >&2
    exit 2
    ;;
esac

if ! command -v zoxide &> /dev/null; then
  echo "zoxide가 없습니다. brew install zoxide 후 다시 실행하세요." >&2
  exit 1
fi

# fasd의 해석 순서를 그대로 따른다. 마지막 ~/.fasd 는 legacy 폴백이다.
FASD_DB=""
for candidate in \
  "${_FASD_DATA:-}" \
  "${XDG_CACHE_HOME:-}${XDG_CACHE_HOME:+/fasd}" \
  "$HOME/.cache/fasd" \
  "$HOME/.fasd"
do
  [ -n "$candidate" ] || continue
  if [ -s "$candidate" ]; then
    FASD_DB="$candidate"
    break
  fi
done

if [ -z "$FASD_DB" ]; then
  echo "이관할 fasd DB가 없습니다. 건너뜁니다."
  exit 0
fi

echo "fasd DB : $FASD_DB ($(wc -l < "$FASD_DB" | tr -d ' ')행)"

if [ "$DRY_RUN" == true ]; then
  echo "현재 zoxide 등록: $(zoxide query --list 2>/dev/null | wc -l | tr -d ' ')개"
  echo "--dry-run 이므로 이관하지 않았습니다."
  exit 0
fi

if [ -f "$MARKER" ] && [ "$FORCE" == false ]; then
  echo "이미 이관했습니다($(cat "$MARKER")). 다시 하려면 --force."
  exit 0
fi

BEFORE="$(zoxide query --list 2>/dev/null | wc -l | tr -d ' ')"

# zoxide의 기본 경로가 아니라 위에서 찾은 실제 DB를 읽게 강제한다.
_FASD_DATA="$FASD_DB" zoxide import fasd --merge

AFTER="$(zoxide query --list 2>/dev/null | wc -l | tr -d ' ')"

mkdir -p "$(dirname "$MARKER")"
date '+%Y-%m-%d %H:%M:%S' > "$MARKER"

echo "이관 완료: zoxide 등록 ${BEFORE} -> ${AFTER}개"
echo "fasd DB는 지우지 않았습니다. 확인 후 직접 정리하세요:"
echo "  rm -f $FASD_DB"
