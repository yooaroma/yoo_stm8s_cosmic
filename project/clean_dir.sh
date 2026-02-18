#!/bin/bash

# 1. 삭제할 대상 폴더 목록 설정
TARGETS=("Debug" "Release")

echo "===================================================="
echo " [STM8 Project Cleanup] Starting..."
echo " Targets: ${TARGETS[*]}"
echo "===================================================="

# 2. find 명령어로 대상 폴더 탐색 및 삭제
# -type d: 디렉토리만 탐색
# \( ... \): 여러 이름을 OR(-o) 조건으로 묶음
# -exec rm -rf {} +: 찾은 폴더들을 재귀적으로 강제 삭제
find . -type d \( \
    -name "Debug" -o \
    -name "Release" \
\) -print -exec rm -rf {} +

echo "===================================================="
echo " ✅ Cleanup Complete!"
echo "===================================================="