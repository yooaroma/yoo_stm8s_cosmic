#!/bin/bash

# 1. 사용자 입력 (디렉토리명 설정)
SRC_DIR="25_stm8s103_debug"
DST_DIR="05_stm8s103_led_tim4"

# 2. 프로젝트 이름 자동 추출 (앞의 '숫자_' 제거)
OLD_NAME="${SRC_DIR#*_}"
NEW_NAME="${DST_DIR#*_}"

echo "===================================================="
echo " [Project Clone & Rename]"
echo " - Source: $SRC_DIR ($OLD_NAME)"
echo " - Target: $DST_DIR ($NEW_NAME)"
echo "===================================================="

# 3. 대상 디렉토리 및 src 폴더 생성
mkdir -p "$DST_DIR/src"

# 4. 프로젝트 설정 파일 처리 (이름 변경 + 텍스트 치환)
EXTS=("dep" "stp" "stw" "wed")
for EXT in "${EXTS[@]}"; do
    SRC_FILE="$SRC_DIR/$OLD_NAME.$EXT"
    DST_FILE="$DST_DIR/$NEW_NAME.$EXT"

    if [ -f "$SRC_FILE" ]; then
        echo "[FILE] Processing Project File: $OLD_NAME.$EXT"
        sed "s|$OLD_NAME|$NEW_NAME|g" "$SRC_FILE" > "$DST_FILE"
    fi
done

# 5. 인터럽트 벡터 파일 처리 (단순 카피)
SRC_C_FILE="$SRC_DIR/src/stm8_interrupt_vector.c"
DST_C_FILE="$DST_DIR/src/stm8_interrupt_vector.c"

if [ -f "$SRC_C_FILE" ]; then
    echo "[SRC ] Simple Copying: stm8_interrupt_vector.c"
    # 치환 없이 원본 파일 그대로 복사합니다.
    cp "$SRC_C_FILE" "$DST_C_FILE"
else
    echo "⚠️  Warning: $SRC_C_FILE 파일을 찾을 수 없습니다."
fi

echo "===================================================="
echo " ✅ 작업 완료! ./$DST_DIR 폴더를 확인해 보세요."
echo "===================================================="