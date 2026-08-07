#!/bin/bash
#
# herdr을 iTerm2 안에서 쓰기 위한 프로파일 설정을 일괄 적용한다.
#
#   1) 모든 프로파일의 Option Key를 Esc+ 로 (alt 계열 chord 전달에 필수)
#   2) 무제한 스크롤백 해제 + 상한 설정
#      herdr은 대체 화면(alternate screen)에 그리므로 패인 내용은 iTerm2
#      스크롤백에 애초에 들어가지 않는다. 스크롤백은 herdr이 자체 관리한다
#      (advanced.scrollback_limit_bytes, 기본 10MB/패인).
#      즉 무제한 설정은 herdr 실행 전 셸 출력만 담으면서 메모리는 계속 늘어난다.
#
# iTerm2가 실행 중이면 종료할 때 메모리 상태를 plist에 덮어써서 이 변경이 조용히
# 사라진다. 그래서 실행 중이면 거부한다.
#
# 사용법:
#   ./script/iterm2-herdr-setup.sh --dry-run   # 무엇이 바뀌는지만 출력
#   ./script/iterm2-herdr-setup.sh             # 실제 적용 (iTerm2 종료 후)
#   ./script/iterm2-herdr-setup.sh --defer     # iTerm2 종료를 기다렸다가 자동 적용
#
# --defer는 herdr을 iTerm2 안에서 쓸 때를 위한 것이다. herdr 서버가 iTerm2의
# 자식 프로세스라 iTerm2를 종료하면 herdr 세션도 함께 죽는다. 그래서 "종료 후
# 실행"을 사람이 직접 하기 번거롭다. --defer는 launchd에 일회용 에이전트를 걸어
# iTerm2가 사라지면 자동으로 적용하고 iTerm2를 다시 띄운 뒤 스스로를 제거한다.
#
# 스크롤백 줄 수는 환경변수로 바꿀 수 있다: SCROLLBACK_LINES=20000 ./script/...

set -euo pipefail

DOMAIN="com.googlecode.iterm2"
LAUNCH_LABEL="com.config-osx.iterm2-herdr-setup"
LAUNCH_PLIST="$HOME/Library/LaunchAgents/${LAUNCH_LABEL}.plist"
LAUNCH_LOG="$HOME/Library/Logs/iterm2-herdr-setup.log"
RUNNER="$HOME/Library/Application Support/config-osx/iterm2-herdr-setup.sh"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

export SCROLLBACK_LINES="${SCROLLBACK_LINES:-10000}"
export DRY_RUN=false
MODE="${1:-}"
case "$MODE" in
  "")                 ;;
  --dry-run)          DRY_RUN=true ;;
  --defer)            ;;
  --wait-and-apply)   ;;   # launchd 전용 내부 모드
  *)
    echo "알 수 없는 인자: $MODE" >&2
    echo "사용법: $0 [--dry-run | --defer]" >&2
    exit 2
    ;;
esac

# pgrep은 쓰지 않는다. 이 환경에서 실측하면 신뢰할 수 없다:
#   pgrep -f iTerm   -> 8개
#   pgrep -f iTerm2  -> 0개   (같은 프로세스인데 더 긴 패턴이 안 맞는다)
#   pgrep -f herdr   -> 0개   (herdr이 실행 중인데도 0)
# ps는 정상 동작하므로 comm 전체 경로를 끝에 앵커해서 판정한다.
# iTermServer(종료 후에도 남는 세션 복원 서버)의 comm은
# ".../Application Support/iTerm2/iTermServer-3.6.11"이라 이 패턴에 걸리지 않는다.
# grep -q는 쓰지 않는다. 매치 즉시 파이프를 닫아 ps가 SIGPIPE(141)로 죽고,
# set -o pipefail이 그 141을 파이프라인 결과로 삼아 "매치했는데 실패"가 된다.
# -q 없이 /dev/null로 버리면 grep이 입력을 끝까지 읽어 SIGPIPE가 나지 않는다.
is_iterm_running() {
  ps -Ao comm= | grep "/iTerm\.app/Contents/MacOS/iTerm2$" > /dev/null
}

# ── --defer: iTerm2 종료를 기다렸다가 자동 적용하는 launchd 에이전트를 건다 ──
if [ "$MODE" == "--defer" ]; then
  mkdir -p "$(dirname "$LAUNCH_PLIST")" "$(dirname "$LAUNCH_LOG")" "$(dirname "$RUNNER")"
  # launchd 에이전트는 ~/Documents 아래 스크립트를 실행하지 못한다 (macOS TCC).
  # 실측: "Operation not permitted" + 종료 코드 126.
  # 그래서 실행용 사본을 ~/Library 아래에 두고 그쪽을 가리킨다.
  # 이 사본은 --wait-and-apply가 끝날 때 스스로 지운다.
  cp "$SELF" "$RUNNER"
  chmod +x "$RUNNER"
  # 이미 걸려 있으면 갈아끼운다
  launchctl bootout "gui/$(id -u)/${LAUNCH_LABEL}" 2>/dev/null || true
  cat > "$LAUNCH_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>${LAUNCH_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${RUNNER}</string>
    <string>--wait-and-apply</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict><key>SCROLLBACK_LINES</key><string>${SCROLLBACK_LINES}</string></dict>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>${LAUNCH_LOG}</string>
  <key>StandardErrorPath</key><string>${LAUNCH_LOG}</string>
</dict>
</plist>
PLIST
  launchctl bootstrap "gui/$(id -u)" "$LAUNCH_PLIST"
  echo "예약 완료. iTerm2를 Cmd+Q로 종료하면 자동으로 적용하고 iTerm2를 다시 띄웁니다."
  echo "  로그  : $LAUNCH_LOG"
  echo "  취소  : launchctl bootout gui/$(id -u)/${LAUNCH_LABEL} && rm -f '$LAUNCH_PLIST'"
  exit 0
fi

# ── --wait-and-apply: launchd가 실행하는 내부 모드 ──
if [ "$MODE" == "--wait-and-apply" ]; then
  echo "[$(date '+%F %T')] iTerm2 종료 대기 시작"
  # 최대 12시간. 그 안에 종료하지 않으면 스스로 물러난다.
  for _ in $(seq 1 8640); do
    is_iterm_running || break
    sleep 5
  done
  if is_iterm_running; then
    echo "[$(date '+%F %T')] 12시간 내에 종료되지 않아 포기합니다."
  else
    echo "[$(date '+%F %T')] iTerm2 종료 확인 — 설정 적용"
    # 종료 직후 iTerm2가 prefs를 쓰는 중일 수 있으니 잠깐 기다린다
    sleep 3
    SCROLLBACK_LINES="$SCROLLBACK_LINES" "$SELF" || echo "적용 실패 (종료 코드 $?)"
    echo "[$(date '+%F %T')] iTerm2 재실행"
    open -a iTerm || true
  fi
  # 스스로를 제거한다 (실행용 사본 포함)
  rm -f "$LAUNCH_PLIST" "$RUNNER"
  launchctl bootout "gui/$(id -u)/${LAUNCH_LABEL}" 2>/dev/null || true
  exit 0
fi

if [ "$DRY_RUN" == false ] && is_iterm_running; then
  echo "오류: iTerm2가 실행 중입니다." >&2
  echo "      종료하지 않고 바꾸면 iTerm2가 종료할 때 메모리 상태로 덮어써서" >&2
  echo "      변경이 조용히 사라집니다. Cmd+Q로 완전히 종료한 뒤 다시 실행하세요." >&2
  echo "      종료를 기다렸다가 자동 적용하려면: $0 --defer" >&2
  echo "      먼저 확인만 하려면: $0 --dry-run" >&2
  exit 1
fi

# cfprefsd 캐시와 어긋나지 않도록 defaults export/import로 왕복한다.
# plist 파일을 직접 고치면 cfprefsd가 캐시 내용으로 되돌릴 수 있다.
OUT="$(mktemp -t iterm2-prefs)"
export OUT
trap 'rm -f "$OUT"' EXIT

PY_TRANSFORM='
import os, plistlib, sys

dry   = os.environ["DRY_RUN"] == "true"
lines = int(os.environ["SCROLLBACK_LINES"])

data = plistlib.loads(sys.stdin.buffer.read())
default_guid = data.get("Default Bookmark Guid")
changes = []

for profile in data.get("New Bookmarks", []):
    label = profile.get("Name", "<이름 없음>")
    if profile.get("Guid") == default_guid:
        label += " (기본)"

    # 0 = Normal, 1 = Meta, 2 = Esc+
    for key in ("Option Key Sends", "Right Option Key Sends"):
        current = profile.get(key, 0)
        if current != 2:
            changes.append(f"  [{label}] {key}: {current} -> 2 (Esc+)")
            profile[key] = 2

    if profile.get("Unlimited Scrollback", False):
        changes.append(f"  [{label}] Unlimited Scrollback: True -> False")
        profile["Unlimited Scrollback"] = False

    current = profile.get("Scrollback Lines", 0)
    if current != lines:
        changes.append(f"  [{label}] Scrollback Lines: {current} -> {lines}")
        profile["Scrollback Lines"] = lines

if not changes:
    print("바꿀 것이 없습니다. 이미 모두 적용된 상태입니다.")
    sys.exit(10)          # 10 = 적용 불필요 (오류가 아님)

print("변경 대상:")
print("\n".join(changes))

if dry:
    print()
    print("--dry-run 이므로 적용하지 않았습니다.")
    sys.exit(10)          # 10 = 적용 불필요

with open(os.environ["OUT"], "wb") as fh:
    plistlib.dump(data, fh)
'

# 위 파이프라인의 종료 코드를 그대로 받는다.
#   0  = 변환 성공, OUT에 plist를 썼다 -> import 진행
#   10 = 적용할 것이 없거나 드라이런    -> 정상 종료
#   그 외 = 실제 오류                   -> 그대로 전파 (이전에는 || exit 0 이 전부 삼켰다)
rc=0
defaults export "$DOMAIN" - | python3 -c "$PY_TRANSFORM" || rc=$?
case "$rc" in
  0)  ;;
  10) exit 0 ;;
  *)  echo "설정 변환 실패 (종료 코드 $rc)" >&2; exit "$rc" ;;
esac

defaults import "$DOMAIN" "$OUT"
killall cfprefsd 2>/dev/null || true

echo
echo "적용 완료. iTerm2를 실행하면 반영됩니다."
echo "확인:"
echo "  Settings > Profiles > Keys > General  -> Left/Right Option Key = Esc+"
echo "  Settings > Profiles > Terminal        -> Scrollback lines = ${SCROLLBACK_LINES}"
