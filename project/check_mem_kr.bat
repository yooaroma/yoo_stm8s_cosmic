@echo off
setlocal enabledelayedexpansion

:: 1. 입력 인자 처리 (첫 번째: 칩 이름, 두 번째: MAP 파일 경로)
set "INPUT_CHIP=%~1"
set "MAP_FILE=%~2"

:: 칩 이름이 입력되지 않았을 경우 기본값 설정
if "%INPUT_CHIP%"=="" set "INPUT_CHIP=STM8S103"

:: 2. 칩셋별 하드웨어 사양 설정
:: STM8S103 (F3 기준): Flash 8KB, RAM 1KB, EEPROM 640B
if /i "%INPUT_CHIP%"=="STM8S103" (
    set /a MAX_FLASH=8192
    set /a MAX_RAM=1024
    set /a MAX_EEPROM=640
    set "FULL_NAME=STM8S103"
) ^
:: STM8S105K4: Flash 16KB, RAM 2KB, EEPROM 1KB
else if /i "%INPUT_CHIP%"=="STM8S105K4" (
    set /a MAX_FLASH=16384
    set /a MAX_RAM=2048
    set /a MAX_EEPROM=1024
    set "FULL_NAME=STM8S105K4"
) ^
:: STM8S105C6: Flash 32KB, RAM 2KB, EEPROM 1KB
else if /i "%INPUT_CHIP%"=="STM8S105C6" (
    set /a MAX_FLASH=32768
    set /a MAX_RAM=2048
    set /a MAX_EEPROM=1024
    set "FULL_NAME=STM8S105C6"
) ^
:: 정의되지 않은 이름이 들어온 경우 기본값(103)으로 처리
else (
    echo [INFO] Unknown chip '%INPUT_CHIP%'. Defaulting to STM8S103.
    set /a MAX_FLASH=8192
    set /a MAX_RAM=1024
    set /a MAX_EEPROM=640
    set "FULL_NAME=STM8S103 (Default)"
)

:: 3. MAP 파일 자동 검색 (obj 또는 Debug 디렉토리)
if "%MAP_FILE%"=="" (
    for /r "obj" %%f in (*.map) do set "MAP_FILE=%%f"
    if "!MAP_FILE!"=="" for /r "Debug" %%f in (*.map) do set "MAP_FILE=%%f"
)

:: 4. 파일 존재 여부 확인
if not exist "%MAP_FILE%" (
    echo [ERROR] Map file not found.
    echo Usage: %~nx0 [STM8S103|STM8S105K4|STM8S105C6] [path_to_map_file]
    exit /b 1
)

:: 5. 변수 초기화
set /a FLASH_SIZE=0
set /a RAM_SIZE=0
set /a EEPROM_SIZE=0

:: 6. MAP 파일 분석 (segment 키워드 라인 추출)
for /f "tokens=6,8" %%a in ('findstr /C:"segment" "%MAP_FILE%"') do (
    set "LEN=%%a"
    set "SEG=%%b"
    
    :: Flash 영역
    if "!SEG!"==".text"  set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".const" set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".init"  set /a FLASH_SIZE+=!LEN!
    
    :: RAM 영역
    if "!SEG!"==".data"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bss"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".ubsct" set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bsct"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bit"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".share" set /a RAM_SIZE+=!LEN!
    
    :: EEPROM 영역
    if "!SEG!"==".eeprom" set /a EEPROM_SIZE+=!LEN!
)

:: 7. 퍼센트 계산
set /a FLASH_PCT=(FLASH_SIZE * 100) / MAX_FLASH
set /a RAM_PCT=(RAM_SIZE * 100) / MAX_RAM
set /a EEPROM_PCT=0
if %MAX_EEPROM% GTR 0 set /a EEPROM_PCT=(EEPROM_SIZE * 100) / MAX_EEPROM

:: 8. 상태 체크
set "F_STAT=[ OK ]" & if !FLASH_SIZE! GTR !MAX_FLASH! set "F_STAT=[ OVER ]"
set "R_STAT=[ OK ]" & if !RAM_SIZE! GTR !MAX_RAM! set "R_STAT=[ OVER ]"
set "E_STAT=[ OK ]" & if !EEPROM_SIZE! GTR !MAX_EEPROM! set "E_STAT=[ OVER ]"

:: 9. 결과 출력
for %%F in ("%MAP_FILE%") do set "FILENAME=%%~nxF"

echo ========================================================
echo  %FULL_NAME% Memory Usage Analysis
echo ========================================================
echo  File   : !FILENAME!
echo --------------------------------------------------------
echo  FLASH  : !FLASH_SIZE! / !MAX_FLASH! bytes (!FLASH_PCT!%%) !F_STAT!
echo  RAM    : !RAM_SIZE! / !MAX_RAM! bytes (!RAM_PCT!%%) !R_STAT!
echo  EEPROM : !EEPROM_SIZE! / !MAX_EEPROM! bytes (!EEPROM_PCT!%%) !E_STAT!
echo ========================================================

endlocal