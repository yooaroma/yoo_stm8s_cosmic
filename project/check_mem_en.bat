@echo off
setlocal enabledelayedexpansion

:: 1. Processing input arguments
set "INPUT_CHIP=%~1"
set "MAP_FILE=%~2"

:: Set default chip if no argument is provided
if "%INPUT_CHIP%"=="" (
    set "INPUT_CHIP=STM8S103"
)

:: 2. Setting hardware specifications
if /i "%INPUT_CHIP%"=="STM8S103" (
    set /a MAX_FLASH=8192
    set /a MAX_RAM=1024
    set /a MAX_EEPROM=640
    set "FULL_NAME=STM8S103"
) else if /i "%INPUT_CHIP%"=="STM8S105K4" (
    set /a MAX_FLASH=16384
    set /a MAX_RAM=2048
    set /a MAX_EEPROM=1024
    set "FULL_NAME=STM8S105K4"
) else if /i "%INPUT_CHIP%"=="STM8S105C6" (
    set /a MAX_FLASH=32768
    set /a MAX_RAM=2048
    set /a MAX_EEPROM=1024
    set "FULL_NAME=STM8S105C6"
) else (
    set /a MAX_FLASH=8192
    set /a MAX_RAM=1024
    set /a MAX_EEPROM=640
    set "FULL_NAME=STM8S103 (Default)"
)

:: 3. Searching for MAP file
if "%MAP_FILE%"=="" (
    for /r "obj" %%f in (*.map) do set "MAP_FILE=%%f"
    if "!MAP_FILE!"=="" for /r "Debug" %%f in (*.map) do set "MAP_FILE=%%f"
)

:: 4. Verifying file existence
if not exist "%MAP_FILE%" (
    echo [ERROR] Map file not found.
    echo Usage: %~nx0 [CHIP_NAME] [PATH_TO_MAP_FILE]
    pause
    exit /b 1
)

:: 5. Initializing variables
set /a FLASH_SIZE=0
set /a RAM_SIZE=0
set /a EEPROM_SIZE=0

:: 6. Analyzing MAP file (extracting segment data)
for /f "tokens=6,8" %%a in ('findstr /C:"segment" "%MAP_FILE%"') do (
    set "LEN=%%a"
    set "SEG=%%b"
    
    :: Flash Area
    if "!SEG!"==".text"  set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".const" set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".init"  set /a FLASH_SIZE+=!LEN!
    
    :: RAM Area
    if "!SEG!"==".data"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bss"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".ubsct" set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bsct"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bit"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".share" set /a RAM_SIZE+=!LEN!
    
    :: EEPROM Area
    if "!SEG!"==".eeprom" set /a EEPROM_SIZE+=!LEN!
)

:: 7. Calculating usage percentages
set /a FLASH_PCT=(FLASH_SIZE * 100) / MAX_FLASH
set /a RAM_PCT=(RAM_SIZE * 100) / MAX_RAM
set /a EEPROM_PCT=0
if %MAX_EEPROM% GTR 0 set /a EEPROM_PCT=(EEPROM_SIZE * 100) / MAX_EEPROM

:: 8. Checking status
set "F_STAT=[ OK ]" & if !FLASH_SIZE! GTR !MAX_FLASH! set "F_STAT=[ OVER ]"
set "R_STAT=[ OK ]" & if !RAM_SIZE! GTR !MAX_RAM! set "R_STAT=[ OVER ]"
set "E_STAT=[ OK ]" & if !EEPROM_SIZE! GTR !MAX_EEPROM! set "E_STAT=[ OVER ]"

:: 9. Finalizing results
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