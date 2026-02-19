#!/bin/bash

# 복사할 원본 파일 이름
SOURCE_FILE="stm8_interrupt_vector.c"

# 파일이 현재 경로에 있는지 확인
if [ ! -f "$SOURCE_FILE" ]; then
    echo "에러: 현재 디렉토리에 $SOURCE_FILE 파일이 없습니다."
    exit 1
fi

# 대상 디렉토리 리스트 (01부터 25까지)
DIRS=(
    "01_stm8s103_void" "02_stm8s103_led_blink" "03_stm8s103_led_key"
    "04_stm8s103_led_key_irq" "05_stm8s103_led_tim4" "06_stm8s103_led_tim4_irq"
    "07_stm8s103_uart_polling" "08_stm8s103_uart_rx_irq" "09_stm8s103_uart_rtx_irq"
    "10_stm8s103_uart_rx_tim4_irq" "11_stm8s103_vsprintf" "12_stm8s103_remap_flash"
    "13_stm8s103_eeprom" "14_stm8s103_awu" "15_stm8s103_beep"
    "16_stm8s103_iwdg" "17_stm8s103_wwdg" "18_stm8s103_tim2_pwm"
    "19_stm8s103_adc_pwm" "20_stm8s103_i2c_pcf8591" "21_stm8s103_i2c_lcd1602"
    "22_stm8s103_i2c_adxl345" "23_stm8s103_i2c_gy30_bh1750" "24_stm8s103_ds18b20_dtemp"
    "25_stm8s103_debug"
)

echo "파일 복사를 시작합니다..."

for dir in "${DIRS[@]}"; do
    TARGET_DIR="$dir/src"
    
    # 상위 디렉토리가 존재하는지 확인
    if [ -d "$dir" ]; then
        # src 폴더가 없으면 생성 (필요한 경우)
        if [ ! -d "$TARGET_DIR" ]; then
            mkdir -p "$TARGET_DIR"
            echo "[$dir] src 폴더가 없어 생성했습니다."
        fi
        
        # 파일 복사
        cp "$SOURCE_FILE" "$TARGET_DIR/"
        echo "[$dir] 복사 완료: $TARGET_DIR/$SOURCE_FILE"
    else
        echo "[$dir] 경고: 디렉토리가 존재하지 않아 건너뜁니다."
    fi
done

echo "모든 작업이 완료되었습니다."