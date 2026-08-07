# macOS 개발 환경 설정

이 저장소는 macOS에서 개발 환경을 빠르게 설정하기 위한 스크립트와 설정 파일을 제공합니다.

## 목차
- [주요 기능](#주요-기능)
- [설치 전 준비사항](#설치-전-준비사항)
- [설치 방법](#설치-방법)
- [Neovim 설정](#neovim-설정)
- [주요 플러그인 사용법](#주요-플러그인-사용법)
- [설정 커스터마이징](#설정-커스터마이징)
- [iTerm2 설정](#iterm2-설정)
- [herdr 설정](#herdr-설정)
- [문제 해결](#문제-해결)
- [디렉토리 구조](#디렉토리-구조)
- [라이선스](#라이선스)

## 주요 기능

- Neovim 설정 (플러그인, 테마, 한글 입력 지원 등)
- herdr 설정 (터미널 워크스페이스 키바인딩)
- 개발 도구 설정 (SBT, Scala, Java 등)
- 유용한 유틸리티 스크립트

## 설치 전 준비사항

### 필수 폰트 설치

```bash
# Nerd Font 설치 (https://www.nerdfonts.com)
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

### 한글 입력 지원 도구 설치

```bash
# macism 설치 (한글 입력 전환 도구)
brew tap laishulu/homebrew
brew install macism
```

macism은 Neovim에서 한글 입력 시 모드 전환을 자동으로 관리해주는 도구입니다.
이 도구를 설치하면 노멀 모드로 전환 시 자동으로 영문 입력으로 전환됩니다.

#### macism 권한 설정

macism을 처음 사용할 때 macOS에서 접근성 권한이 필요합니다:

1. macism을 한 번 실행해봅니다: `macism com.apple.keylayout.ABC`
2. 시스템 환경설정 > 개인 정보 보호 및 보안 > 개인 정보 보호 > 손쉬운 사용에서 터미널(또는 사용 중인 앱)에 권한을 부여합니다.
3. 키보드 단축키 설정에서 "이전 입력 소스 선택" 단축키가 활성화되어 있는지 확인합니다.
   - 시스템 환경설정 > 키보드 > 단축키 > 입력 소스

### 기본 도구 설치

#### Zsh 프레임워크 설치

```bash
# zprezto 설치 (https://github.com/sorin-ionescu/prezto)
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```

#### 패키지 관리자 및 개발 도구

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# SDKMAN 설치
curl -s "https://get.sdkman.io" | bash

# Node.js 관련 도구
brew install node
brew install nvm
brew install yarn

# 텍스트 에디터
brew install vim
brew install neovim

# 검색 도구
brew install ag  # The Silver Searcher
brew install ripgrep  # rg

# Java / JVM 도구
brew install --cask temurin@17
brew install google-java-format
brew install checkstyle

# Scala 도구
brew install coursier/formulas/coursier
coursier install scalafix
```

#### Java 개발 도구

이 저장소의 Neovim 설정은 Java 파일에서 Metals를 LSP로 사용하며, Java 포매팅은 `google-java-format`으로 표준화되어 있습니다.
Java 들여쓰기는 2칸(`shiftwidth=2`, `softtabstop=2`, `tabstop=2`, `expandtab=true`)으로 맞추고, Java 린트는 `./install` 시 홈 디렉토리에 설치되는 `~/.custom_java_checks.xml`을 사용하는 `checkstyle` 기준으로 실행합니다.
Java 포매팅은 `google-java-format` 경로가 준비되지 않으면 즉시 실패하도록 두고, Java에서 Metals 포매팅으로 자동 fallback 하지는 않습니다.

```bash
# 기본 JDK 선택 (셸 설정에 추가 권장)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"

# 확인
java -version
echo $JAVA_HOME
```

`SDKMAN`으로 JDK를 관리하더라도 최종적으로 `JAVA_HOME`이 올바른 JDK를 가리켜야 Metals가 정상 동작합니다.
`zprezto.patch`를 별도로 적용해 사용하는 경우에는 `java_ls`, `java_use 17` 헬퍼도 함께 사용할 수 있습니다.

#### Scala 개발 도구

Scala 린트는 `scalafix`로 실행합니다. Neovim 설정은 `scalafix`를 먼저 찾고, 없으면 `coursier launch scalafix`로 대신 실행합니다(`nvim/lua/config/nvim-lint.lua`).
**둘 다 없으면 Scala 린터 목록이 빈 테이블이 되어 아무 알림 없이 비활성화**되므로, Scala를 다룬다면 위 도구 설치 단계의 `coursier` / `scalafix` 두 명령을 반드시 실행하세요.
Scala/sbt 포매팅은 conform이 아니라 nvim-metals의 저장 시 포맷이 담당합니다(이중 포맷 방지).

```bash
# Metals (Scala 언어 서버) 설정
# 자세한 정보: https://scalameta.org/metals/
# Neovim 설정: https://scalameta.org/metals/docs/editors/vim.html
```

## 설치 방법

모든 설정을 한 번에 적용하려면 다음 명령어를 실행하세요:

```bash
./install
```

이 스크립트는 다음 작업을 수행합니다:

- 스크립트를 ~/bin에 설치
- 설정 파일을 홈 디렉토리에 설치
- Neovim 설정을 ~/.config/nvim에 설치
- herdr 설정(`config.toml`)을 ~/.config/herdr에 설치
- SBT 설정을 ~/.sbt/1.0에 설치
- Git 글로벌 설정 적용
- Neovim 플러그인 설치

업데이트를 수행하려면 다음 명령어를 실행하세요:

```bash
./install --update
# 또는
./install -u
```

## Neovim 설정 (0.11 기반)

### 주요 특징

- **Neovim 0.11 기반**: 모든 최신 기능과 성능 개선을 표준으로 활용
- **비동기 처리 최적화**: Treesitter, LSP, 진단 등 모든 주요 기능이 비동기로 처리
- **향상된 LSP 통합**: 0.11의 새로운 LSP 기능과 기본 매핑 활용
- **지능형 캐시 관리**: 대용량 파일과 프로젝트에 최적화된 메모리 관리
- **성능 모니터링**: 선택적 성능 추적 및 최적화

### 0.11 핵심 기능 활용

#### LSP 향상
- 기본 LSP 매핑: `grn` (rename), `grr` (references), `gri` (implementation), `gO` (symbols), `gra` (code action)
- 내장 자동완성 지원 (`vim.lsp.completion.enable()`)
- 개선된 hover 문서화 (마크다운 하이라이팅 포함)
- 새로운 LSP 구성 방식 (`vim.lsp.config()`, `vim.lsp.enable()`)

#### 진단 개선 (중앙화된 설정)
- **중앙화된 진단 설정**: `config/diagnostics.lua`에서 모든 진단 관련 설정을 통합 관리
- **3가지 진단 모드**: 
  - `default`: Signs + lualine (중복 방지, 깔끔한 표시)
  - `performance`: ERROR만 표시 (최소한의 정보)
  - `development`: 모든 표시 방식 활성화 (상세한 정보)
- **구분되는 진단 아이콘**: ✘ (오류), ▲ (경고), ● (정보), ◆ (힌트)
- **중복 방지**: lualine과 virtual text/lines 간 중복 표시 제거
- 개선된 진단 정렬 및 필터링
- 대용량 파일 자동 감지 및 진단 최적화
- 통합된 키맵: `<leader>dt` (virtual text 토글), `<leader>dm` (모드 전환)

#### UI/UX 개선
- 새로운 기본 매핑들: quickfix (`[q`, `]q`), buffer (`[b`, `]b`), 빈 줄 추가 (`[<Space>`, `]<Space>`)
- fuzzy 완성 지원
- 개선된 터미널 기능 (reflow, OSC 52 클립보드, 커서 제어)
- 향상된 윈도우 테두리 처리

#### 성능 최적화
- Treesitter 비동기 하이라이팅 및 접기
- 강화된 쿼리 캐싱
- 개선된 autocommand 처리 (flat vector 저장)
- 메모리 효율적인 대용량 파일 처리

### 설정 구조

```
nvim/
├── init.lua                 # 0.11 최적화된 메인 설정
├── lua/
│   ├── init.lua            # 핵심 설정 (0.11 기능 활용)
│   ├── keys.lua            # 키매핑 (0.11 기본 매핑과 호환)
│   ├── plugin.lua          # lazy.nvim 플러그인 관리자
│   ├── utils.lua           # 유틸리티 함수
│   ├── cache_manager.lua   # 0.11 최적화된 캐시 관리
│   ├── config/             # 플러그인별 설정
│   ├── diagnostics.lua # 중앙화된 진단 설정
│   └── plugins/            # 플러그인 정의
```

### 설치 및 사용

1. **Neovim 0.11 이상 설치 확인**
   ```bash
   nvim --version  # v0.11.0 이상이어야 함
   ```

2. **기존 설정 백업 (선택사항)**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

3. **설정 파일 복사**
   ```bash
   cp -r nvim ~/.config/
   ```

4. **Neovim 실행 및 플러그인 설치**
   ```bash
   nvim
   # lazy.nvim이 자동으로 플러그인을 설치합니다
   ```

5. **린터·포매터 설치 (수동, 필수)**
   ```vim
   :MasonToolsInstall
   ```
   LSP 서버(`lua_ls`, `ts_ls`, `eslint`, `oxlint`, `pyright`, `marksman`)는 mason-lspconfig가
   파일을 열 때 자동으로 설치합니다. 반면 린터·포매터(`luacheck`, `ruff`, `stylua`, `prettier`)는
   **이 명령을 직접 실행해야 설치됩니다.** mason-tool-installer를 의도적으로 수동 전용으로
   두었기 때문입니다(`nvim/lua/config/mason-tool-installer.lua` 주석 참고).
   실행하지 않으면 포맷과 린트가 아무 오류 없이 조용히 동작하지 않습니다.

   진행 상황은 `:Mason`으로 확인할 수 있습니다.

### 환경 변수 옵션

성능 최적화 및 디버깅을 위한 환경 변수:

```bash
# 성능 모니터링 활성화
export NVIM_PERF_MONITOR=1

# 캐시 디버그 정보 표시
export NVIM_CACHE_DEBUG=1

# Treesitter 디버그 정보
export NVIM_TS_DEBUG=1

# 프로파일링 활성화
export NVIM_PROFILE=1
```

### 주요 키매핑

#### 0.11 기본 매핑 (자동 제공)
- `grn`: LSP 이름 변경
- `grr`: LSP 참조 찾기
- `gri`: LSP 구현 찾기
- `gO`: 문서 심볼
- `gra`: 코드 액션
- `<C-S>` (삽입 모드): 시그니처 도움말

#### 추가 최적화 매핑
- `<Leader>dl`: Virtual lines 진단 토글
- `<Leader>lc`: LSP 자동완성 토글
- `<Leader>df`: 진단 플로팅 창 표시
- `jj`: 삽입 모드 빠져나오기

### 성능 특징

- **시작 시간**: lazy loading과 비동기 처리로 빠른 시작
- **메모리 사용량**: 지능형 버퍼 관리로 메모리 효율성
- **응답성**: 모든 주요 작업이 비동기로 처리되어 UI 차단 최소화
- **대용량 파일 지원**: 5MB 이상 파일에 대한 특별 최적화

### 호환성

- **최소 버전**: Neovim 0.11.0
- **권장 버전**: 최신 stable 버전

---

이 설정은 Neovim 0.11의 모든 최신 기능을 표준으로 활용하여 개발 생산성을 극대화하도록 최적화되었습니다.

## 주요 플러그인 사용법

### multicursor.nvim (멀티 커서 편집)

[multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) 플러그인을 사용하면 여러 위치에서 동시에 텍스트를 편집할 수 있습니다.
(이전에는 vim-visual-multi를 썼으나 upstream이 2024-09에 멈춰 이전했습니다.)

주요 키 매핑:

- `<C-n>`: 커서 아래 단어의 다음 일치에 커서 추가 (단어 경계 기준)
- `<C-Down>`/`<C-Up>`: 아래/위 줄에 커서 추가
- `<C-a>` (visual): 선택 영역의 모든 일치에 커서 추가
- `<C-q>`: 커서 일시 비활성/재활성
- `<C-LeftMouse>`: 클릭 위치에 커서 추가
- `<leader>ma`: 모든 일치에 커서 추가 (normal)
- `<leader>mp`: 현재 위치에 커서 추가
- `<leader>mn`/`<leader>mN`: 다음 일치 건너뛰기 / 이전 일치에 커서 추가
- `<leader>m/`: 검색 결과 전체에 커서 (`smartcase` 반영)

커서가 여러 개일 때만 동작하는 키:

- `<leader>m[`/`<leader>m]`: 이전/다음 커서로 전환
- `<leader>mx`: 주 커서 삭제
- `<Esc>`: 커서 정리 (비활성 상태면 재활성)

일반 모션(`h`/`l`/`w` 등)과 `u`/`<C-r>`는 모든 커서에 그대로 적용되므로 별도 키가 없습니다.

vim-visual-multi와 달리 `<C-n>`은 단어를 시각적으로 선택하지 않고 커서만 놓습니다.
단어를 바꾸려면 `ciw`를 쓰거나, 커서를 다 모은 뒤 `viw`를 한 번 눌러(모든 커서에 적용됩니다)
선택한 다음 `c`를 누르세요.

주의: `<C-n>` 계열은 항상 대소문자를 구분합니다(플러그인이 검색식에 `\C`를 강제).
대소문자를 무시하려면 `/패턴`으로 검색한 뒤 `<leader>m/`를 쓰세요.

자세한 설정은 `nvim/lua/config/multicursor.lua` 파일을 참조하세요.

### trouble.nvim (진단 및 참조 뷰어)

[trouble.nvim](https://github.com/folke/trouble.nvim) 플러그인은 코드의 진단, 참조, 정의, 심볼 등을 보기 쉽게 표시해주는 도구입니다.

주요 키 매핑:

- `<leader>xx`: 진단 목록 표시
- `<leader>xX`: 현재 버퍼의 진단 목록 표시
- `<leader>xL`: 로케이션 리스트 표시
- `<leader>xQ`: 퀵픽스 리스트 표시
- `<leader>xl`: LSP 참조/정의/구현 결과 표시
- `<leader>xs`: 문서 심볼 표시

fzf-lua와의 연동:

- fzf-lua로 검색 후 `<C-t>` 키를 누르면 결과가 Trouble 뷰에 표시됩니다.

Trouble 뷰 내부 키 바인딩:

- `o` 또는 `<CR>`: 항목 열기
- `<C-x>`: 가로 분할로 항목 열기
- `<C-v>`: 세로 분할로 항목 열기
- `<tab>/<S-tab>`: 다음/이전 항목으로 이동
- `q`: Trouble 뷰 닫기
- `r`: 목록 새로고침
- `p`: 미리보기 토글
- `m`: 필터/검색 토글

명령어 예제:

- `:Trouble diagnostics`: 모든 파일의 진단 목록 표시
- `:Trouble lsp_references`: 현재 심볼의 참조 표시
- `:Trouble symbols`: 문서 심볼 목록 표시

자세한 설정은 `nvim/lua/config/trouble.lua` 파일을 참조하세요.

## 설정 커스터마이징

### Neovim 설정 수정

Neovim 설정은 다음 파일들에서 관리됩니다:

- `nvim/init.lua`: 메인 설정 파일
- `nvim/lua/init.lua`: 기본 설정
- `nvim/lua/keys.lua`: 키 매핑
- `nvim/lua/config/`: 각 플러그인 설정
- `nvim/lua/plugins/`: 플러그인 정의

## iTerm2 설정

### vim 스타일 복사 모드 활성화

iTerm2에서는 키보드만으로 텍스트를 선택하고 복사할 수 있는 vim 스타일의 복사 모드를 제공합니다.

#### 설정 방법

1. 다음 명령어를 실행하여 vim 스타일 복사 모드를 활성화합니다:
   ```bash
   defaults write com.googlecode.iterm2 DeprecatedCopyMode -bool true
   ```

2. iTerm2를 완전히 종료하고 다시 실행합니다 (Command+Q로 종료 후 재실행).

#### 사용 방법

1. 복사 모드 진입:
   - `Cmd+Shift+C` 단축키 사용
   - 또는 메뉴에서 Edit > Copy Mode 선택

2. vim 스타일 키 바인딩:
   - 기본 이동: `h`, `j`, `k`, `l`
   - 선택 모드: `v`(문자 단위), `V`(라인 단위), `Ctrl+v`(사각형 선택)
   - 이동 명령어: `w`, `b`, `0`, `$`, `G` 등
   - 복사: `y` 또는 `Ctrl+k`
   - 종료: `Esc`, `q`, `Ctrl+c`, `Ctrl+g`

3. 추가 명령어:
   - `Ctrl+space`: 선택 중지
   - `o`: 커서와 선택 끝점 위치 교환
   - 단어 이동: `w`(다음 단어), `b`(이전 단어)
   - 화면 이동: `H`(화면 상단), `M`(화면 중앙), `L`(화면 하단)
   - 페이지 이동: `Ctrl+f`(페이지 다운), `Ctrl+b`(페이지 업)

복사 모드 중에는 터미널 내용이 업데이트되지 않으며, 키보드만으로 효율적으로 텍스트를 선택하고 복사할 수 있습니다.

## herdr 설정

[herdr](https://herdr.dev)는 코딩 에이전트용 터미널 워크스페이스 매니저입니다.
이 저장소는 `herdr/config.toml` 하나만 관리하며, `./install`이 이를 `~/.config/herdr/config.toml`로 심링크합니다.

```bash
brew install herdr   # homebrew/core
```

### 디렉토리 전체가 아니라 파일 하나만 링크하는 이유

`~/.config/herdr`에는 설정 외에 herdr이 직접 만드는 런타임 파일이 함께 들어갑니다.

```
~/.config/herdr/
├── config.toml        # ← 저장소가 관리 (심링크)
├── session.json       # 런타임 상태 (레이아웃/탭/패인)
├── herdr-server.log   # 로그
├── herdr.sock         # 유닉스 소켓
└── release-notes.json
```

디렉토리를 통째로 링크하면 이 상태 파일들이 저장소로 흘러들어오므로, `config.toml`만 개별 심링크합니다.

### 설정 변경 방법

심링크이므로 어느 쪽을 고쳐도 같은 파일입니다. 저장소에서 고치는 쪽을 권장합니다.

```bash
$EDITOR herdr/config.toml
herdr config check          # 문법·키바인딩 검증
herdr server reload-config  # 실행 중인 서버에 재시작 없이 반영
git diff herdr/config.toml
```

기본값 전체를 확인하려면 `herdr --default-config`를 실행하세요(324줄). 저장소에는 기본값과 다른 항목만 둡니다.

### 현재 커스터마이징 요약

- **prefix-free 키바인딩**: 각 액션에 `prefix+키`(herdr 기본값)와 `ctrl+alt+키`(prefix 없이 바로) 두 가지를 등록
- **pane**: `ctrl+alt+h/j/k/l` 이동, `ctrl+alt+v` 세로 분할, `ctrl+alt+shift+v` 가로 분할, `ctrl+alt+x` 닫기
- **tab(가로축)**: `ctrl+alt+;` / `ctrl+alt+'` 로 이전/다음 — HHKB의 `Fn+[;'/` 방향키 위치를 Fn 없이 그대로 사용
- **workspace(세로축)**: `ctrl+alt+[` / `ctrl+alt+/` 로 이전/다음
- `switch_ascii_input_source_in_prefix = true`: prefix 진입 시 영문 입력으로 자동 전환 (한글 입력 중 단축키 오작동 방지)
- 사운드 비활성화, 패인 테두리의 에이전트 라벨 숨김

`ctrl+alt` 계열을 쓰는 이유는 iTerm2 / Neovim / macOS 기본 단축키와 충돌하지 않기 때문입니다
([공식 문서](https://herdr.dev/docs/keyboard/#going-prefix-free)).

`ctrl+alt+minus`는 터미널에 따라 전달이 불안정해서 가로 분할만 `ctrl+alt+shift+v`로 두었습니다.

### iTerm2 키 설정 (필수)

**iTerm2 설정을 맞추지 않으면 이 저장소의 prefix-free 단축키 상당수가 조용히 동작하지 않습니다.**
바인딩이 잘못된 게 아니라 iTerm2가 키를 herdr에 전달하지 못하는 것이므로, 오류 메시지도 나오지 않습니다.

#### 왜 필요한가

herdr은 실행될 때 바깥 터미널에 **keyboard enhancement(kitty keyboard protocol)** 를 요청하고,
지원되지 않으면 legacy 인코딩으로 떨어집니다(`src/pane/kitty_keyboard.rs`, `TerminalKey` 인코딩의 `Legacy`/`Kitty` 구분).
legacy 인코딩에서는 아래 키들이 **바이트 수준에서 표현 자체가 불가능**합니다.

| 바인딩 | legacy에서 안 되는 이유 |
| --- | --- |
| `ctrl+alt+;` `ctrl+alt+'` | `Ctrl`+구두점에 대응하는 제어문자가 없음 |
| `ctrl+alt+1..9` | `Ctrl`+숫자에 대응하는 제어문자가 없음 |
| `ctrl+alt+shift+v` `…+shift+x/c/d` | `Ctrl+Shift+V`와 `Ctrl+V`가 둘 다 `0x16` — 구분 불가 |

즉 **탭 전환(`ctrl+alt+;` `ctrl+alt+'`), 탭 번호 점프, shift 계열(가로 분할·탭 닫기·워크스페이스 생성/닫기)이 통째로 죽습니다.**
`ctrl+alt+h/j/k/l`이나 화살표 계열만 되고 나머지가 안 된다면 거의 확실히 이 문제입니다.

#### 설정 방법

iTerm2 **3.5 이상**이 필요합니다(`iTerm2 → About iTerm2`). 아래는 **Settings → Profiles → Keys → General**입니다.

| 항목 | 값 | 이유 |
| --- | --- | --- |
| Left Option Key | `Esc+` | `Normal`이면 Option이 문자 조합(´, ¨)으로 소비되어 alt 계열이 전달되지 않음 |
| Right Option Key | `Esc+` | 위와 동일 |
| Apps can change how keys are reported | **켬** (기본값) | 꺼져 있으면 herdr이 kitty 프로토콜을 켤 수 없어 legacy로 떨어짐 |
| Report modifiers using CSI u | **끔** (기본값) | iTerm2 공식 문서가 구식이라 권장하지 않는 옵션. 켜면 `\|`, `>` 입력이 Esc처럼 동작하는 부작용이 있음 |

`Meta`는 상위 비트를 세우는 옛 방식이라 쓰지 마세요. `Esc+`가 표준입니다.

> **주의: 이 설정은 프로파일별입니다.** 프로파일을 여러 개 쓴다면 **herdr을 띄우는 프로파일**에 적용해야 합니다.
> 기본 프로파일이 무엇인지는 Settings → Profiles 목록에서 확인하거나 아래로 GUID를 대조하세요.
>
> ```bash
> /usr/libexec/PlistBuddy -c "Print :'Default Bookmark Guid'" ~/Library/Preferences/com.googlecode.iterm2.plist
> ```

#### 화살표 키 매핑 (Key Bindings)

`Option Key Sends = Esc+`만 설정하면 `ctrl+alt+↑`가 `ESC` + `ESC [1;5A`(esc 접두 + ctrl+↑)로 전달되어
herdr이 이를 `ctrl+alt+up`으로 보지 못합니다. **Settings → Profiles → Keys → Key Bindings**에 아래 4개를 추가하세요.

| 조합 | Action | Esc+ 뒤에 넣을 값 | 최종 전송 바이트 |
| --- | --- | --- | --- |
| `^⌥↑` | Send Escape Sequence | `[1;7A` | `ESC [1;7A` |
| `^⌥↓` | Send Escape Sequence | `[1;7B` | `ESC [1;7B` |
| `^⌥←` | Send Escape Sequence | `[1;7D` | `ESC [1;7D` |
| `^⌥→` | Send Escape Sequence | `[1;7C` | `ESC [1;7C` |

수식자 파라미터 `7`은 `1 + alt(2) + ctrl(4)`로, ctrl+alt+화살표의 표준 인코딩입니다.
kitty 프로토콜이 켜져 있으면 iTerm2가 알아서 같은 시퀀스를 보내므로 이 매핑은 중복이지만,
**프로토콜이 꺼진 상황(tmux 경유, 원격 접속, 위 옵션이 꺼진 프로파일)에서도 화살표 계열이 살아 있게 해주는 안전망**이라 남겨 둡니다.

> **Key Bindings는 kitty 프로토콜보다 우선합니다.** 여기에 등록한 조합은 프로토콜이 켜져 있어도
> 등록한 바이트가 그대로 나갑니다. 그래서 `ctrl+alt+;`처럼 legacy 표현이 없는 키는 여기에 넣지 마세요
> (넣으려면 CSI u 시퀀스를 직접 작성해야 하고, 그 순간 프로토콜의 이점이 사라집니다).

현재 등록 상태는 아래로 확인할 수 있습니다.

```bash
python3 - <<'PY'
import plistlib, pathlib, os
p = plistlib.loads(pathlib.Path(os.path.expanduser(
    "~/Library/Preferences/com.googlecode.iterm2.plist")).read_bytes())
for b in p.get("New Bookmarks", []):
    if b.get("Guid") != p.get("Default Bookmark Guid"):
        continue
    print("profile:", b.get("Name"), "| Option Key Sends:", b.get("Option Key Sends"), "(2=Esc+)")
    for combo, act in sorted(b.get("Keyboard Map", {}).items()):
        print(f"  {combo}: action={act.get('Action')} text={act.get('Text')!r}")
PY
```

이 매핑은 iTerm2 plist에 저장되므로 **이 저장소가 공유하지 않습니다.** 새 장비에서는 위 표대로 직접 등록해야 합니다.

#### 실제로 전달되는지 확인

kitty 프로토콜을 수동으로 켠 상태에서 키를 눌러 봅니다.

```bash
printf '\033[>1u'   # kitty keyboard protocol 켜기 (스택에 push)
cat -v              # 키를 눌러 확인, Ctrl-C로 종료
printf '\033[<u'    # 반드시 원복 (스택에서 pop)
```

- `ctrl+alt+;` → `^[[59;7u` 같은 **CSI u 시퀀스**가 보이면 정상 (`59`=`;`의 코드포인트, `7`=ctrl+alt)
- 아무것도 안 나오거나 `^[;`만 나오면 프로토콜이 켜지지 않은 것 → 위 표의 "Apps can change how keys are reported" 확인
- `´`, `¨` 같은 문자가 나오면 Option Key가 `Normal`인 것 → `Esc+`로 변경

마지막 `printf '\033[<u'`를 빼먹으면 해당 셸이 kitty 모드에 남아 다른 프로그램의 키 입력이 이상해질 수 있습니다.

#### 단축키가 여전히 안 먹을 때 — 어느 계층이 가로챘는지

herdr 공식 문서의 표현대로, 직접 chord가 아무것도 하지 않으면 herdr이 보기 전에 누군가 이미 삼킨 것입니다.
바깥쪽부터 순서대로 확인하세요.

1. **macOS** — 시스템 설정 → 키보드 → 키보드 단축키
   (Mission Control이 쓰는 `ctrl+←/→/↑`는 Option이 없어서 `ctrl+alt+화살표`와 충돌하지 않지만, 직접 커스텀했다면 확인)
2. **iTerm2** — Settings → Keys → Key Bindings(전역), Settings → Profiles → Keys → Key Mappings(프로파일별)
3. **herdr** — `herdr config check`
4. **패인 안에서 도는 프로그램** — 반대 방향 충돌입니다. herdr이 먼저 잡으므로, Neovim 등에 걸어둔 같은 `ctrl+alt+*` 매핑이 죽습니다

어느 계층이든 한쪽을 비워야 합니다. herdr 쪽을 바꾸겠다면 `herdr/config.toml`에서 해당 chord를 다른 것으로 교체하세요.

#### 한글 입력과 함께 쓸 때

`switch_ascii_input_source_in_prefix = true`가 켜져 있어 **prefix(`ctrl+b`) 진입 시** 자동으로 영문 입력으로 전환됩니다.
direct chord(`ctrl+alt+*`)는 문자 입력이 아니라 이 전환이 적용되지 않지만, 한글 입력 중에도 그대로 전달됩니다.
Neovim 쪽 한글 처리는 [한글 입력 지원 도구 설치](#한글-입력-지원-도구-설치)의 macism 설정을 참고하세요.

### 주의: herdr이 심링크를 덮어쓸 수 있음

herdr은 온보딩 완료 여부 등 일부 상태를 `config.toml`에 직접 기록하고, `herdr config reset-keys`는 이 파일을 다시 씁니다.
기록 방식에 따라 심링크가 일반 파일로 바뀔 수 있으니, 설정이 저장소에 반영되지 않는다면 확인하세요.

```bash
ls -l ~/.config/herdr/config.toml   # '-> .../config-osx/herdr/config.toml' 이어야 정상
```

일반 파일로 바뀌었다면 그 내용을 `herdr/config.toml`에 반영한 뒤 `./install`을 다시 실행하면 됩니다
(`./install`은 덮어쓰기 전에 `~/.config/backup_<타임스탬프>/herdr/`로 백업합니다).

## 문제 해결

### 플러그인 설치 오류

플러그인 설치 중 오류가 발생하면 다음 명령어를 실행해보세요:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim --headless -c "Lazy sync" -c "qa"
```

### 한글 입력 문제

한글 입력 관련 문제가 있다면 다음 사항을 확인하세요:

1. macism 또는 im-select.nvim 플러그인이 올바르게 설정되었는지 확인하세요:
   - `nvim/lua/config/im-select.lua` 파일에서 설정 확인
   - 터미널에서 `macism` 명령어가 정상적으로 실행되는지 확인
   - 시스템 환경설정에서 macism에 대한 접근성 권한이 부여되었는지 확인
   - 시스템 환경설정에서 "이전 입력 소스 선택" 단축키가 활성화되어 있는지 확인

```bash
# macism 상태 확인
macism  # 현재 입력 방식 확인
macism com.apple.keylayout.ABC  # 영문 입력으로 전환
```

### 폰트 문제

아이콘이 제대로 표시되지 않는 경우 Nerd Font가 올바르게 설치되었는지 확인하고 터미널 에뮬레이터에서 해당 폰트를 선택했는지 확인하세요.

## 디렉토리 구조

- `script/`: 유틸리티 스크립트
- `settings/`: 다양한 도구의 설정 파일
- `nvim/`: Neovim 설정 파일
- `herdr/`: herdr 설정 파일 (`config.toml`)
- `sbt/`: SBT(Scala Build Tool) 설정

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 기타 설정

### SBT 설정
Scala 빌드 도구 설정

### VSCode 설정
Visual Studio Code 사용자 설정

### zprezto.patch
Zsh 프레임워크 패치

### 설치 스크립트
macOS 개발 환경 자동 설정을 위한 스크립트들
