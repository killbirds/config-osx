#!/usr/bin/env bash
# Neovim 설정(nvim/)의 Lua 정적 검사.
#
# 왜 별도 스크립트인가:
#   편집기 안에서 보는 lua_ls 진단은 신뢰할 수 없다. lua_ls가 stdlib/워크스페이스를
#   다 읽기 전에 중간 진단을 발행해서, 같은 파일이 실행마다 undefined-global을
#   0건에서 수십 건까지 오락가락 보고한다. --check는 인덱싱이 끝난 뒤 한 번에
#   판정하므로 타이밍과 무관하게 결정적이다.
#
#   nvim/.luarc.json은 편집기와 공유하는 설정이지만 workspace.library는 담지 않는다.
#   편집기에서는 lazydev.nvim이 열린 파일의 require()에 맞춰 동적으로 넣어 주는데,
#   CLI에는 lazydev가 없으므로 여기서 런타임에 계산해 주입한다.
#   (Neovim 버전 경로를 .luarc.json에 하드코딩하면 업그레이드마다 깨진다)
#
# 사용법:
#   script/nvim-luals-check.sh              # Warning 이상
#   script/nvim-luals-check.sh Information  # 더 엄격하게
set -euo pipefail

CHECK_LEVEL="${1:-Warning}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_DIR="$REPO_ROOT/nvim"

# Mason 설치본을 우선한다. 편집기(Neovim)는 Mason이 PATH를 prepend하므로 Mason 것을
# 쓰는데, 여기서 PATH를 먼저 보면 Homebrew 등 다른 설치본을 골라 편집기와 다른 서버로
# 검사하게 된다(실측: 두 바이너리의 SHA-256이 다름).
LUALS="$HOME/.local/share/nvim/mason/bin/lua-language-server"
[ -x "$LUALS" ] || LUALS="$(command -v lua-language-server || true)"
if [ ! -x "$LUALS" ]; then
  echo "lua-language-server를 찾을 수 없습니다. :MasonInstall lua-language-server 로 설치하세요." >&2
  exit 1
fi

# Neovim 런타임 lua 경로 (버전 하드코딩 회피)
VIMRUNTIME_LUA="$(nvim --headless -c 'lua io.write(vim.env.VIMRUNTIME)' -c qa 2>&1)/lua"
LAZY_DIR="$(nvim --headless -c 'lua io.write(vim.fn.stdpath("data"))' -c qa 2>&1)/lazy"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# .luarc.json + 동적 workspace.library 병합
python3 - "$NVIM_DIR/.luarc.json" "$VIMRUNTIME_LUA" "$LAZY_DIR" "$WORK/luarc.json" <<'PY'
import json, os, sys, re
src, runtime_lua, lazy_dir, dst = sys.argv[1:5]

# .luarc.json은 주석 없는 순수 JSON이지만 방어적으로 // 주석을 제거한다
raw = open(src).read()
raw = re.sub(r'^\s*//.*$', '', raw, flags=re.M)
cfg = json.loads(raw)

libs = [runtime_lua]
if os.path.isdir(lazy_dir):
    for name in sorted(os.listdir(lazy_dir)):
        p = os.path.join(lazy_dir, name, "lua")
        if os.path.isdir(p):
            libs.append(p)

cfg["workspace.library"] = libs
cfg.pop("$schema", None)  # CLI에서는 불필요
json.dump(cfg, open(dst, "w"), indent=2)
print(f"workspace.library: {len(libs)}개 경로", file=sys.stderr)
PY

echo "검사 대상: $NVIM_DIR  (checklevel=$CHECK_LEVEL)"
OUT="$WORK/check.json"
# 진행률 출력이 길어 보기 어려우므로 전문은 파일에 남기고 마지막 줄만 보여준다.
# 주의: 파이프로 넘기면 종료코드가 tail 것이 되므로 lua_ls 자체 실패를 놓친다.
# (잘못된 checklevel, crash, config 로드 실패 등은 check.json을 아예 만들지 않는다)
RAW="$WORK/luals.out"
set +e
"$LUALS" --check "$NVIM_DIR" \
  --configpath "$WORK/luarc.json" \
  --checklevel "$CHECK_LEVEL" \
  --logpath "$WORK/log" \
  --check_out_path "$OUT" > "$RAW" 2>&1
LUALS_RC=$?
set -e
tr '\r' '\n' < "$RAW" | tail -1

if [ "$LUALS_RC" -ne 0 ]; then
  echo "lua-language-server 실행 실패 (exit $LUALS_RC):" >&2
  tr '\r' '\n' < "$RAW" | tail -5 >&2
  exit 1
fi

if [ ! -f "$OUT" ]; then
  # 성공했는데 결과 파일이 없는 경우는 계약 위반이므로 실패로 본다
  echo "lua-language-server가 결과 파일을 만들지 않았습니다: $OUT" >&2
  tr '\r' '\n' < "$RAW" | tail -5 >&2
  exit 1
fi

python3 - "$OUT" "$NVIM_DIR" <<'PY'
import json, sys, urllib.parse
out, base = sys.argv[1], sys.argv[2]
data = json.load(open(out))
# 진단이 0건이면 lua_ls는 {} 가 아니라 [] 를 쓴다
if not isinstance(data, dict):
    print("진단 없음")
    raise SystemExit(0)
rows = []
for uri, items in data.items():
    f = urllib.parse.unquote(uri).replace("file://" + base + "/", "")
    for it in items:
        rows.append((f, it["range"]["start"]["line"] + 1,
                     it.get("code", "?"), it["message"].split("\n")[0]))
rows.sort()
if not rows:
    print("진단 없음")
    raise SystemExit(0)
print(f"\n진단 {len(rows)}건")
for f, ln, code, msg in rows:
    print(f"  {f}:{ln}  [{code}] {msg}")
raise SystemExit(1)
PY
