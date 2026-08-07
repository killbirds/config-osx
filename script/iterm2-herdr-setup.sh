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
#
# 스크롤백 줄 수는 환경변수로 바꿀 수 있다: SCROLLBACK_LINES=20000 ./script/...

set -euo pipefail

DOMAIN="com.googlecode.iterm2"
export SCROLLBACK_LINES="${SCROLLBACK_LINES:-10000}"
export DRY_RUN=false
[ "${1:-}" == "--dry-run" ] && DRY_RUN=true

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

if [ "$DRY_RUN" == false ] && is_iterm_running; then
  echo "오류: iTerm2가 실행 중입니다." >&2
  echo "      종료하지 않고 바꾸면 iTerm2가 종료할 때 메모리 상태로 덮어써서" >&2
  echo "      변경이 조용히 사라집니다. Cmd+Q로 완전히 종료한 뒤 다시 실행하세요." >&2
  echo "      먼저 확인만 하려면: $0 --dry-run" >&2
  exit 1
fi

# cfprefsd 캐시와 어긋나지 않도록 defaults export/import로 왕복한다.
# plist 파일을 직접 고치면 cfprefsd가 캐시 내용으로 되돌릴 수 있다.
OUT="$(mktemp -t iterm2-prefs)"
export OUT
trap 'rm -f "$OUT"' EXIT

defaults export "$DOMAIN" - | python3 -c '
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
    sys.exit(0)

print("변경 대상:")
print("\n".join(changes))

if dry:
    print()
    print("--dry-run 이므로 적용하지 않았습니다.")
    sys.exit(0)

with open(os.environ["OUT"], "wb") as fh:
    plistlib.dump(data, fh)
print()
print("PLIST_WRITTEN")
' | tee /dev/stderr | grep -q "PLIST_WRITTEN" || exit 0

defaults import "$DOMAIN" "$OUT"
killall cfprefsd 2>/dev/null || true

echo
echo "적용 완료. iTerm2를 실행하면 반영됩니다."
echo "확인:"
echo "  Settings > Profiles > Keys > General  -> Left/Right Option Key = Esc+"
echo "  Settings > Profiles > Terminal        -> Scrollback lines = ${SCROLLBACK_LINES}"
