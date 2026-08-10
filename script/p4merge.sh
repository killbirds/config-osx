#!/bin/sh
#
# p4merge를 git mergetool로 쓰기 위한 래퍼.
#
# "$@"를 쓴다. $*는 인자를 다시 word splitting / glob 확장 대상으로 만들어
# 공백이 든 경로를 여러 인자로 쪼갠다.
#
# 주의: 이 래퍼만 고쳐도 git 쪽 설정이 인용하지 않으면 여기 도달하기 전에 쪼개진다.
# 전역 설정도 각 변수를 인용해야 한다:
#   git config --global mergetool.p4merge.cmd \
#     'p4merge.sh "$BASE" "$LOCAL" "$REMOTE" "$MERGED"'

/Applications/p4merge.app/Contents/Resources/launchp4merge "$@"

