#!/bin/bash

# 1. 원본 설정 (Template)
SRC_DIR="25_stm8s103_debug"
OLD_NAME="${SRC_DIR#*_}"

# 2. 목적지 디렉토리 리스트 (DST_DIR 배열)
DST_DIRS=(
    "06_stm8s103_led_tim4_irq"
    "07_stm8s103_uart_polling"
    "08_stm8s103_uart_rx_irq"
    "09_stm8s103_uart_rtx_irq"
    "10_stm8s103_uart_rx_tim4_irq"
    "11_stm8s103_vsprintf"
    "12_stm8s103_remap_flash"
    "13_stm8s103_eeprom"
    "14_stm8s103_awu"
    "15_stm8s103_beep"
    "16_stm8s103_iwdg"
    "17_stm8s103_wwdg"
    "18_stm8s103_tim2_pwm"
    "19_stm8s103_adc_pwm"
    "20_stm8s103_i2c_pcf8591"
    "21_stm8s103_i2c_lcd1602"
    "22_stm8s103_i2c_adxl345"
    "23_stm8s103_i2c_gy30_bh1750"
    "24_stm8s103_ds18b20_dtemp"
)

echo "===================================================="
echo " [Batch Processing] Cloning 19 Projects"
echo " Source: $SRC_DIR ($OLD_NAME)"
echo "===================================================="

# 3. 일괄 처리 루프 시작
for DST_DIR in "${DST_DIRS[@]}"; do
    # 프로젝트 이름 추출 (앞의 숫자_ 제거)
    NEW_NAME="${DST_DIR#*_}"
    
    echo ">>> Processing: $DST_DIR (Project: $NEW_NAME)"

    # A. 디렉토리 및 src 폴더 생성
    mkdir -p "$DST_DIR/src"

    # B. 프로젝트 설정 파일 처리 (.dep, .stp, .stw, .wed)
    EXTS=("dep" "stp" "stw" "wed")
    for EXT in "${EXTS[@]}"; do
        SRC_FILE="$SRC_DIR/$OLD_NAME.$EXT"
        DST_FILE="$DST_DIR/$NEW_NAME.$EXT"

        if [ -f "$SRC_FILE" ]; then
            # 내부 텍스트 치환 및 새 이름으로 저장
            sed "s|$OLD_NAME|$NEW_NAME|g" "$SRC_FILE" > "$DST_FILE"
        fi
    done

    # C. 인터럽트 벡터 파일 처리 (단순 카피)
    SRC_C_FILE="$SRC_DIR/src/stm8_interrupt_vector.c"
    DST_C_FILE="$DST_DIR/src/stm8_interrupt_vector.c"

    if [ -f "$SRC_C_FILE" ]; then
        cp "$SRC_C_FILE" "$DST_C_FILE"
    fi

    echo "   Done!"
done

echo "===================================================="
echo " ✅ 모든 19개 프로젝트 복제 작업이 완료되었습니다!"
echo "===================================================="