-- 주석 구분자 뒤에 자동으로 공백 추가
vim.g.NERDSpaceDelims = 1

-- 여러 줄 주석을 깔끔한 형태로 유지
vim.g.NERDCompactSexyComs = 1

-- 주석을 코드 들여쓰기와 무관하게 왼쪽 정렬
vim.g.NERDDefaultAlign = "left"

-- Java에서 기본적으로 대체 주석 구분자 사용
vim.g.NERDAltDelims_java = 1

-- 사용자 정의 주석 구분자 설정 (C 언어)
vim.g.NERDCustomDelimiters = {
	c = { left = "/**", right = "*/" },
}

-- 빈 줄도 주석 처리할 수 있도록 허용
vim.g.NERDCommentEmptyLines = 1

-- 주석 해제 시 자동으로 뒤쪽 공백 제거
vim.g.NERDTrimTrailingWhitespace = 1

-- NERDCommenterToggle 실행 시 모든 선택된 줄의 주석 상태를 확인
vim.g.NERDToggleCheckAllLines = 1
