# Cursor Vim 플러그인 설정

이 디렉토리는 Cursor 에디터에서 Vim 플러그인을 위한 최적화된 설정을 제공합니다. NeoVim의 키 바인딩과 유사한 환경을 구성하여 사용자의 워크플로우를 향상시킵니다.

## 설치 방법

1. Cursor 에디터에서 `Ctrl+Shift+P`를 눌러 명령 팔레트를 엽니다.
2. `Preferences: Open Settings (JSON)`을 검색하여 선택합니다.
3. `settings.json` 파일의 내용을 Cursor의 설정 파일에 복사합니다.
4. 파일을 저장하고 Cursor를 재시작합니다.

## 주요 기능

### 기본 설정

- 리더 키: Space
- 상대적 줄 번호 표시
- 검색 하이라이트 및 증분 검색 활성화
- EasyMotion, Sneak, Surround 플러그인 지원
- 모드별 커서 스타일 커스터마이징

### 모드별 키 바인딩

#### 일반 모드

- 저장 및 종료: `<leader>w`, `<leader>q`, `<leader>Q`, `<leader>wq`
- 검색 하이라이트 제거: `<leader><space>`
- LSP 관련 기능: `gd`, `gD`, `gi`, `gr`, `gy`, `K` 등
- 버퍼 관리: `<leader>bn`, `<leader>bp`, `<leader>bd`
- 파일 탐색: `<leader>ff`, `<leader>fg`, `<leader>fb`
- 창 분할 및 이동: 
  - 리더 키 사용: `<leader>v`, `<leader>s`, `<leader>h`, `<leader>j`, `<leader>k`, `<leader>l`
  - Ctrl 키 사용: `Ctrl+h`, `Ctrl+j`, `Ctrl+k`, `Ctrl+l`
- 스크롤: `Ctrl+d` (반 페이지 아래로), `Ctrl+u` (반 페이지 위로)

#### 삽입 모드

- Esc 대체: `jj`

#### 비주얼 모드

- 선택 영역 이동: `<A-j>`, `<A-k>`
- 시스템 클립보드 연동: `<leader>y`, `<leader>d`, `<leader>p`, `<leader>P`
- 스크롤: `Ctrl+d` (반 페이지 아래로), `Ctrl+u` (반 페이지 위로)

### 스크롤 기능

Vim의 전통적인 스크롤 기능을 지원합니다:

- `Ctrl+d`: 반 페이지 아래로 스크롤
- `Ctrl+u`: 반 페이지 위로 스크롤
- `Ctrl+f`: 한 페이지 아래로 스크롤
- `Ctrl+b`: 한 페이지 위로 스크롤

### 윈도우 이동

분할된 창 사이를 빠르게 이동할 수 있는 두 가지 방법을 제공합니다:

1. 리더 키 방식: `<leader>h`, `<leader>j`, `<leader>k`, `<leader>l`
2. Ctrl 키 방식: `Ctrl+h`, `Ctrl+j`, `Ctrl+k`, `Ctrl+l`

창 이동 방향:
- 왼쪽 창으로 이동: `Ctrl+h` 또는 `<leader>h`
- 아래쪽 창으로 이동: `Ctrl+j` 또는 `<leader>j`
- 위쪽 창으로 이동: `Ctrl+k` 또는 `<leader>k`
- 오른쪽 창으로 이동: `Ctrl+l` 또는 `<leader>l`

### 멀티 커서 기능

멀티 커서를 사용하면 여러 위치에서 동시에 텍스트를 편집할 수 있습니다.

#### 멀티 커서 단축키

- `Ctrl+n`: 현재 위치의 단어를 선택하고, 다음 일치 항목에 커서 추가 (일반/비주얼 모드)
- `Ctrl+p`: 이전 일치 항목에 커서 추가
- `gb`: 현재 단어와 일치하는 모든 항목 선택
- `Ctrl+a`: 모든 텍스트 선택

#### 멀티 커서 사용 방법

1. 일반 모드에서 단어 위에 커서를 놓습니다.
2. `Ctrl+n`을 눌러 해당 단어를 선택하고 첫 번째 커서를 활성화합니다.
3. 계속해서 `Ctrl+n`을 눌러 동일한 텍스트의 다음 일치 항목에 커서를 추가합니다.
4. `Ctrl+p`를 눌러 이전 일치 항목으로 커서를 이동할 수 있습니다.
5. 모든 일치 항목을 한 번에 선택하려면 `gb`를 사용합니다.
6. 편집을 마친 후 `Esc`를 눌러 멀티 커서 모드를 종료합니다.

## 추가 설정 방법

이 설정은 Cursor의 Vim 플러그인을 최대한 NeoVim과 유사하게 구성했지만, 개인의 선호도에 맞게 조정할 수 있습니다.

### 키 바인딩 추가

```jsonc
"vim.normalModeKeyBindingsNonRecursive": [
  // 기존 키 바인딩...
  
  // 커스텀 키 바인딩 추가
  {
    "before": ["키 조합"],
    "commands": ["실행할 명령어"]
  }
]
```

### 모드별 설정 추가

```jsonc
"vim.visualModeKeyBindingsNonRecursive": [
  // 새로운 비주얼 모드 키 바인딩
]
```

## 참고 사항

- Cursor는 JSONC 형식을 지원하므로 설정 파일에 주석을 사용할 수 있습니다.
- 일부 NeoVim 기능은 Cursor에서 정확하게 동작하지 않을 수 있습니다.

## 문제 해결

문제가 발생하면 다음 단계를 시도해보세요:

1. Cursor를 재시작합니다.
2. 충돌하는 다른 키 바인딩이 있는지 확인합니다.
3. Vim 플러그인을 비활성화했다가 다시 활성화합니다.
4. 설정을 기본값으로 되돌린 후 필요한 설정만 다시 적용합니다. 