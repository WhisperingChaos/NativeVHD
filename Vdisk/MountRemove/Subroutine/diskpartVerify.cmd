:subroutine:
::-- if already detached it's already dismounted.
type %DISKPART_CMD_LOG_FILE% | findstr /C:"The virtual disk is already detached." >nul
if %errorlevel% equ 0 exit /b 0

type %DISKPART_CMD_LOG_FILE% | findstr /C:"DiskPart successfully detached the virtual disk file." >nul
if %errorlevel% equ 0 exit /b 0

exit /b 1