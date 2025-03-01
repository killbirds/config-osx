# macOS 개발 환경 설정

이 저장소는 macOS에서 개발 환경을 빠르게 설정하기 위한 스크립트와 설정 파일을 제공합니다.

## 주요 기능

- Neovim 설정 (플러그인, 테마, 한글 입력 지원 등)
- tmux 설정
- 개발 도구 설정 (SBT, Scala, Java 등)
- 유용한 유틸리티 스크립트

## 설치 전 준비사항

### 필수 폰트 설치

```bash
# Nerd Font 설치 (https://www.nerdfonts.com)
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

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

# 터미널 멀티플렉서
brew install tmux

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

## Neovim 플러그인 관리

이 설정은 [lazy.nvim](https://github.com/folke/lazy.nvim)을 사용하여 Neovim 플러그인을 관리합니다.

### 플러그인 설치 및 업데이트

Neovim을 실행한 후 다음 명령어를 사용하여 플러그인을 관리할 수 있습니다:

```
:Lazy             # 플러그인 관리 UI 열기
:Lazy sync        # 플러그인 설치/업데이트
:Lazy update      # 플러그인 업데이트
:Lazy clean       # 사용하지 않는 플러그인 제거
:Lazy restore     # 이전 플러그인 상태로 복원
:Lazy profile     # 플러그인 로딩 성능 분석
```

### 플러그인 추가 방법

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

### 주요 플러그인 사용법

#### vim-visual-multi (멀티 커서 편집)

[vim-visual-multi](https://github.com/mg979/vim-visual-multi) 플러그인을 사용하면 여러 위치에서 동시에 텍스트를 편집할 수 있습니다.

주요 키 매핑:

- `<C-n>`: 커서 아래 단어 선택 및 다음 일치 항목 찾기
- `<C-j>/<C-k>`: 커서를 위/아래로 추가
- `<C-a>`: 모든 일치 항목 선택
- `<S-Left>/<S-Right>`: 선택 영역 확장/축소
- `<C-h>/<C-l>`: 모든 커서를 왼쪽/오른쪽으로 이동
- `<C-x>`: 현재 위치에 커서 추가

자세한 설정은 `nvim/lua/config/vim-visual-multi.lua` 파일을 참조하세요.

## 설정 커스터마이징

### Neovim 설정 수정

Neovim 설정은 다음 파일들에서 관리됩니다:

- `nvim/init.lua`: 메인 설정 파일
- `nvim/lua/init.lua`: 기본 설정
- `nvim/lua/keys.lua`: 키 매핑
- `nvim/lua/config/`: 각 플러그인 설정
- `nvim/lua/plugins/`: 플러그인 정의

### tmux 설정 수정

tmux 설정은 `settings/.tmux.conf` 파일에서 관리됩니다.

## 문제 해결

### 플러그인 설치 오류

플러그인 설치 중 오류가 발생하면 다음 명령어를 실행해보세요:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim --headless -c "Lazy sync" -c "qa"
```

### 한글 입력 문제

한글 입력 관련 문제가 있다면 다음 사항을 확인하세요:

1. `nvim/lua/config/korean.lua` 파일에서 한글 입력 설정을 확인하세요.
2. 자동 영문 전환 기능을 활성화하려면 해당 파일의 주석을 해제하고 [im-select](https://github.com/daipeihust/im-select) 도구를 설치하세요.

```bash
# im-select 설치
brew tap daipeihust/tap
brew install im-select
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
