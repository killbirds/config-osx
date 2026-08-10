#!/bin/bash

isRecursive() {
  if [ -f _recursive_ ]; then
    echo true
  else
    echo false
  fi
}

# 설치하지 않고 건너뛸 항목.
# 주의: 글로브(*.swp)로 판정하면 안 된다. 이 함수가 호출되는 시점에는 dotglob이
# 꺼져 있어 실제 vim 스왑 파일(.zshrc.swp 같은 숨김 파일)이 매치되지 않았고,
# 항목 수집 쪽은 dotglob을 켜므로 그 파일이 그대로 홈에 링크되고 있었다.
# 접미사 패턴으로 직접 판정한다.
isIgnored() {
  case "$1" in
    *.swp | *.swo) return 0 ;;
    _recursive_) return 0 ;;
    # 에이전트 런타임 상태. 저장소에는 있지만 설치 대상은 아니다
    # (nvim/.omo가 ~/.config/nvim/.omo로 링크되고 있었다).
    .omo | .sisyphus) return 0 ;;
  esac
  return 1
}

# 원본이 사라진 심링크 정리.
# 설치기는 "현재 source에 있는 항목"만 순회하므로, source에서 삭제된 스크립트의
# 링크는 대상에 영구히 남는다(실제로 ~/bin/open_tmux가 그렇게 남아 있었다).
# 이 저장소가 만든 링크(= src_root 아래를 가리키는 링크)이고 지금 끊어져 있는
# 것만 지운다. 살아 있는 링크와 남이 만든 링크는 건드리지 않는다.
pruneStaleLinks() {
  local base="$1" src_root="$2"
  local dotglob_setting nullglob_setting
  dotglob_setting=$(shopt -p dotglob)
  nullglob_setting=$(shopt -p nullglob)
  shopt -s dotglob nullglob

  local prune_status=0
  local link link_target
  for link in "$base"/*; do
    [ -L "$link" ] || continue
    [ -e "$link" ] && continue # 살아 있는 링크는 그대로

    # readlink는 링크에 적힌 값을 그대로 돌려주므로 상대 경로일 수 있다.
    # 아래 case는 절대 경로만 매치하는데, 이 설치기는 항상 절대 경로로 링크를
    # 만들기 때문에(`ln -s "$current/$file"`) 우리가 만든 링크는 전부 걸린다.
    # 상대 경로 링크는 남이 만든 것이므로 건드리지 않는 편이 맞다.
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$src_root"/*)
        echo "rm (원본 없음) $link -> $link_target"
        if ! rm -f "$link"; then
          echo "  !! 끊긴 링크를 지울 수 없습니다: $link" >&2
          prune_status=1
        fi
        ;;
    esac
  done

  eval "$dotglob_setting"
  eval "$nullglob_setting"
  return "$prune_status"
}

install() {
  # 진입 실패를 전파하지 않으면 호출자의 현재 디렉토리를 대상에 설치해버린다.
  pushd "$1" > /dev/null || return 1

  local base="$2"
  local recursive="${3:-$(isRecursive)}"

  echo
  echo "INSTALL: $1 $base $recursive"
  echo

  if [ ! -d "$base" ]; then
    if ! mkdir -p "$base"; then
      echo "  !! 대상 디렉토리를 만들 수 없습니다: $base" >&2
      popd > /dev/null
      return 1
    fi
  fi

  local current="$(pwd)"

  # source와 대상이 같은 디렉토리면 즉시 멈춘다.
  # 아래 루프는 링크를 만들기 전에 대상을 먼저 지우므로, 두 경로가 같으면
  # 원본을 지운 뒤 자기 자신을 가리키는 끊긴 링크를 만든다(= source 파괴).
  # `cd script && ./install.sh .` 같은 오타 한 번으로 일어날 수 있다.
  local base_real
  base_real="$(cd "$base" && pwd -P)" || {
    echo "  !! 대상 디렉토리에 들어갈 수 없습니다: $base" >&2
    popd > /dev/null
    return 1
  }
  if [ "$base_real" == "$(pwd -P)" ]; then
    echo "  !! source와 대상이 같은 디렉토리입니다: $base_real" >&2
    echo "     그대로 진행하면 원본을 지우고 자기 자신을 가리키는 링크를 만듭니다." >&2
    popd > /dev/null
    return 1
  fi
  local dotglob_setting
  local nullglob_setting
  dotglob_setting=$(shopt -p dotglob)
  nullglob_setting=$(shopt -p nullglob)
  shopt -s dotglob nullglob
  local files=(*)
  eval "$dotglob_setting"
  eval "$nullglob_setting"

  # 하나가 실패해도 나머지는 계속 설치하되, 종료 코드에는 반영한다.
  # 예전에는 ln -s / mkdir / 재귀 설치 실패가 전부 무시되고 마지막 popd가
  # 성공하면 함수가 0을 돌려주어, 호출자의 `|| exit 1`이 아무 의미가 없었다.
  # (실측: mkdir과 ln이 모두 실패해 아무것도 설치되지 않았는데 exit 0)
  local status=0

  for file in "${files[@]}"; do
    local src="$current/$file"
    local target="$base/$file"

    # 무시 판정을 삭제보다 먼저 한다.
    # 예전에는 순서가 반대여서 "설치하지 않는 항목"도 동명 대상을 먼저 지웠다.
    if isIgnored "$file"; then
      continue
    fi

    if [ -L "$target" ] || [ -f "$target" ]; then
      if ! rm -f "$target"; then
        echo "  !! 기존 대상을 지울 수 없습니다: $target" >&2
        status=1
        continue
      fi
    elif [ -d "$target" ]; then
      if ! rm -rf "$target"; then
        echo "  !! 기존 대상을 지울 수 없습니다: $target" >&2
        status=1
        continue
      fi
    fi

    # 주의: 재귀는 한 단계씩만 내려간다. 아래 호출은 세 번째 인자를 넘기지 않으므로
    # 자식 디렉토리는 자기 자신의 _recursive_ 마커로 다시 판정된다. 마커가 없으면
    # 그 아래 디렉토리는 링크로 처리된다.
    # 그리고 recursive 설치에서 source에 디렉토리를 추가하면 위 rm -rf가 **먼저**
    # 돌아 동명의 기존 대상 디렉토리를 지운다. settings/ 에 홈 디렉토리와 같은
    # 이름(bin, Documents 등)을 만들지 말 것.
    if [ "$recursive" == true ] && [ -d "$src" ]; then
      if ! (install "$file" "$target"); then
        echo "  !! 하위 디렉토리 설치 실패: $src" >&2
        status=1
      fi
    elif [ -f "$src" ] && [ "$file" == "_install_" ]; then
      if ! bash "$src"; then
        echo "  !! _install_ 실행 실패: $src" >&2
        status=1
      fi
    else
      echo "ln -s $src $target"
      if ! ln -s "$src" "$target"; then
        echo "  !! 링크를 만들 수 없습니다: $target" >&2
        status=1
      fi
    fi
  done

  if ! pruneStaleLinks "$base" "$current"; then
    status=1
  fi

  popd > /dev/null
  return "$status"
}

install . "${1:-$HOME}"
