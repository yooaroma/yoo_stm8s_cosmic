#!/bin/bash

# 1. 삭제할 파일명 목록 설정 (필요한 파일명을 공백으로 구분하여 추가하세요)
TARGET_FILES=("makefile" "readme.txt" "description.txt")

echo "===================================================="
echo " [File Cleanup] Starting recursive deletion..."
echo " Targets: ${TARGET_FILES[*]}"
echo "===================================================="

# 2. find 명령어를 사용하여 파일 탐색 및 삭제
# -type f: 파일만 탐색
# \( ... \): 여러 이름을 OR 조건으로 결합
# -print: 삭제되는 파일 경로 표시
# -delete: 찾은 파일을 즉시 삭제 (안전하게 처리하려면 -exec rm -f {} + 사용 가능)

# find 실행을 위한 이름 조건 동적 생성
NAME_OPTS=()
for i in "${!TARGET_FILES[@]}"; do
    if [ $i -eq 0 ]; then
        NAME_OPTS+=("-name" "${TARGET_FILES[$i]}")
    else
        NAME_OPTS+=("-o" "-name" "${TARGET_FILES[$i]}")
    fi
done

# 실제 삭제 실행
find . -type f \( "${NAME_OPTS[@]}" \) -print -delete

echo "===================================================="
echo " ✅ 작업 완료! 지정된 파일들이 삭제되었습니다."
echo "===================================================="