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
- [문제 해결](#문제-해결)
- [디렉토리 구조](#디렉토리-구조)
- [라이선스](#라이선스)

## 주요 기능

- Neovim 설정 (플러그인, 테마, 한글 입력 지원 등)
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

# 코드 포맷팅 도구
brew install google-java-format
```

#### Scala 개발 도구

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
- SBT 설정을 ~/.sbt/0.13 및 ~/.sbt/1.0에 설치
- Git 글로벌 설정 적용
- Neovim 플러그인 설치

업데이트를 수행하려면 다음 명령어를 실행하세요:

```bash
./install --update
# 또는
./install -u
```

## Neovim 설정

### 플러그인 관리

이 설정은 [lazy.nvim](https://github.com/folke/lazy.nvim)을 사용하여 Neovim 플러그인을 관리합니다.

#### 플러그인 설치 및 업데이트

Neovim을 실행한 후 다음 명령어를 사용하여 플러그인을 관리할 수 있습니다:

```
:Lazy             # 플러그인 관리 UI 열기
:Lazy sync        # 플러그인 설치/업데이트
:Lazy update      # 플러그인 업데이트
:Lazy clean       # 사용하지 않는 플러그인 제거
:Lazy restore     # 이전 플러그인 상태로 복원
:Lazy profile     # 플러그인 로딩 성능 분석
```

#### 플러그인 추가 방법

새 플러그인을 추가하려면 `nvim/lua/plugins` 디렉토리에 Lua 파일을 생성하거나 수정하세요. 예시:

```lua
-- nvim/lua/plugins/example.lua
return {
  "username/plugin-name",
  config = function()
    -- 플러그인 설정
  end
}
```

### 주요 Neovim 최신 기능

#### 프로젝트별 설정 (exrc)

이 설정은 Neovim의 `exrc` 기능을 활용하여 프로젝트별 설정을 지원합니다. 프로젝트 디렉토리에 `.nvim.lua`, `.nvimrc`, `.exrc` 파일을 생성하면 해당 프로젝트에서 Neovim을 실행할 때 자동으로 로드됩니다.

예시 (`.nvim.lua`):

```lua
-- 프로젝트별 설정
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

-- 프로젝트별 키 매핑
vim.keymap.set("n", "<leader>pb", ":echo 'Project-specific command'<CR>", { buffer = true })

-- 프로젝트별 자동 명령
local group = vim.api.nvim_create_augroup("ProjectSettings", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.js",
  callback = function()
    -- 파일 저장 시 작업
  end,
})
```

**참고**: 보안상의 이유로 `secure` 옵션이 활성화되어 있어 일부 명령어는 제한됩니다.

#### Inlay Hints

타입스크립트, 러스트, 루아 등의 언어에서 코드 내에 타입 정보를 인라인으로 표시하는 기능을 지원합니다. 이 기능은 Neovim 0.10.0 이상에서 사용할 수 있습니다.

- `<leader>th`: Inlay Hints 토글
- 기본적으로 지원되는 언어:
  - TypeScript/JavaScript: 변수 타입, 함수 매개변수 및 반환 타입 표시
  - Rust: 변수 타입, 함수 매개변수 및 반환 타입, 라이프타임, 리바운드 힌트 표시
  - Lua: 배열 인덱스, 변수 타입, 매개변수 이름 및 타입 표시

주의: 이 기능은 해당 LSP 서버가 지원해야만 동작합니다.

## 주요 플러그인 사용법

### vim-visual-multi (멀티 커서 편집)

[vim-visual-multi](https://github.com/mg979/vim-visual-multi) 플러그인을 사용하면 여러 위치에서 동시에 텍스트를 편집할 수 있습니다.

주요 키 매핑:

- `<C-n>`: 커서 아래 단어 선택 및 다음 일치 항목 찾기
- `<C-j>/<C-k>`: 커서를 위/아래로 추가
- `<C-a>`: 모든 일치 항목 선택
- `<S-Left>/<S-Right>`: 선택 영역 확장/축소
- `<C-h>/<C-l>`: 모든 커서를 왼쪽/오른쪽으로 이동
- `<C-x>`: 현재 위치에 커서 추가

자세한 설정은 `nvim/lua/config/vim-visual-multi.lua` 파일을 참조하세요.

### trouble.nvim (진단 및 참조 뷰어)

[trouble.nvim](https://github.com/folke/trouble.nvim) 플러그인은 코드의 진단, 참조, 정의, 심볼 등을 보기 쉽게 표시해주는 도구입니다.

주요 키 매핑:

- `<leader>xx`: 진단 목록 표시
- `<leader>xX`: 현재 버퍼의 진단 목록 표시
- `<leader>xL`: 로케이션 리스트 표시
- `<leader>xQ`: 퀵픽스 리스트 표시
- `<leader>xl`: LSP 참조/정의/구현 결과 표시
- `<leader>xs`: 문서 심볼 표시

Telescope과의 연동:

- Telescope로 검색 후 `<C-t>` 키를 누르면 결과가 Trouble 뷰에 표시됩니다.

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
- `sbt/`: SBT(Scala Build Tool) 설정

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
