@echo off
setlocal enabledelayedexpansion

:: 1. 설정: MAP 파일 경로 및 하드웨어 제한량 (STM8S103F3)
set "MAP_FILE=%~1"
if "%MAP_FILE%"=="" set "MAP_FILE=Debug\stm8s103_debug.map"

set /a MAX_FLASH=8192
set /a MAX_RAM=1024
set /a MAX_EEPROM=640

:: 2. 파일 존재 여부 확인
if not exist "%MAP_FILE%" (
    echo [ERROR] Map file not found: "%MAP_FILE%"
    exit /b 1
)

:: 3. 변수 초기화
set /a FLASH_SIZE=0
set /a RAM_SIZE=0
set /a EEPROM_SIZE=0

:: 4. MAP 파일 분석 (토큰 6: 길이, 토큰 8: 세그먼트명)
:: findstr로 'segment'가 포함된 행만 추출하여 루프를 돕니다.
for /f "tokens=6,8" %%a in ('findstr /C:"segment" "%MAP_FILE%"') do (
    set "LEN=%%a"
    set "SEG=%%b"
    
    :: Flash 영역 (.text, .const, .init)
    if "!SEG!"==".text"  set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".const" set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".init"  set /a FLASH_SIZE+=!LEN!
    
    :: RAM 영역 (.data, .bss, .ubsct, .bsct, .bit, .share)
    if "!SEG!"==".data"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bss"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".ubsct" set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bsct"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bit"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".share" set /a RAM_SIZE+=!LEN!
    
    :: EEPROM 영역
    if "!SEG!"==".eeprom" set /a EEPROM_SIZE+=!LEN!
)

:: 5. 백분율 계산 (정수 연산)
set /a FLASH_PCT=(FLASH_SIZE * 100) / MAX_FLASH
set /a RAM_PCT=(RAM_SIZE * 100) / MAX_RAM
set /a EEPROM_PCT=(EEPROM_SIZE * 100) / MAX_EEPROM

:: 6. 상태 체크 (OK / OVER)
set "F_STAT=[ OK ]" & if !FLASH_SIZE! GTR !MAX_FLASH! set "F_STAT=[ OVER ]"
set "R_STAT=[ OK ]" & if !RAM_SIZE! GTR !MAX_RAM! set "R_STAT=[ OVER ]"
set "E_STAT=[ OK ]" & if !EEPROM_SIZE! GTR !MAX_EEPROM! set "E_STAT=[ OVER ]"

:: 7. 결과 출력
for %%F in ("%MAP_FILE%") do set "FILENAME=%%~nxF"

echo ========================================================
echo  STM8S103F3 Memory Usage Analysis
echo ========================================================
echo  File: !FILENAME!
echo --------------------------------------------------------
echo  FLASH  : !FLASH_SIZE! / !MAX_FLASH! bytes (!FLASH_PCT!%%) !F_STAT!
echo  RAM    : !RAM_SIZE! / !MAX_RAM! bytes (!RAM_PCT!%%) !R_STAT!
echo  EEPROM : !EEPROM_SIZE! / !MAX_EEPROM! bytes (!EEPROM_PCT!%%) !E_STAT!
echo ========================================================

endlocal