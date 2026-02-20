@echo off
setlocal enabledelayedexpansion

:: 1. Setting: MAP file path and Hardware Limits (STM8S103F3)
set "MAP_FILE=%~1"
if "%MAP_FILE%"=="" set "MAP_FILE=Debug\stm8s103_debug.map"

set /a MAX_FLASH=8192
set /a MAX_RAM=1024
set /a MAX_EEPROM=640

:: 2. Check if file exists
if not exist "%MAP_FILE%" (
    echo [ERROR] Map file not found: "%MAP_FILE%"
    exit /b 1
)

:: 3. Initialize variables
set /a FLASH_SIZE=0
set /a RAM_SIZE=0
set /a EEPROM_SIZE=0

:: 4. Analyze MAP file (Token 6: Length, Token 8: Segment Name)
for /f "tokens=6,8" %%a in ('findstr /C:"segment" "%MAP_FILE%"') do (
    set "LEN=%%a"
    set "SEG=%%b"
    
    :: Flash area
    if "!SEG!"==".text"  set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".const" set /a FLASH_SIZE+=!LEN!
    if "!SEG!"==".init"  set /a FLASH_SIZE+=!LEN!
    
    :: RAM area
    if "!SEG!"==".data"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bss"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".ubsct" set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bsct"  set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".bit"   set /a RAM_SIZE+=!LEN!
    if "!SEG!"==".share" set /a RAM_SIZE+=!LEN!
    
    :: EEPROM area
    if "!SEG!"==".eeprom" set /a EEPROM_SIZE+=!LEN!
)

:: 5. Calculate percentage (Integer arithmetic)
set /a FLASH_PCT=(FLASH_SIZE * 100) / MAX_FLASH
set /a RAM_PCT=(RAM_SIZE * 100) / MAX_RAM
set /a EEPROM_PCT=(EEPROM_SIZE * 100) / MAX_EEPROM

:: 6. Status Check
set "F_STAT=[ OK ]" & if !FLASH_SIZE! GTR !MAX_FLASH! set "F_STAT=[ OVER ]"
set "R_STAT=[ OK ]" & if !RAM_SIZE! GTR !MAX_RAM! set "R_STAT=[ OVER ]"
set "E_STAT=[ OK ]" & if !EEPROM_SIZE! GTR !MAX_EEPROM! set "E_STAT=[ OVER ]"

:: 7. Output Results
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