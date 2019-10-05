:subroutine:
setlocal

call :QuoteRemove %MOUNT_VDISK_FILE% MOUNT_VDISK_NO_QUOTES
type %DISKPART_CMD_LOG_FILE% | findstr /C:"Filename: %MOUNT_VDISK_NO_QUOTES%" >nul 2>nul
if %errorlevel% NEQ 0 (
  call :Abort "Mount failed for '" %MOUNT_VDISK_FILE% "'" 
  exit /b 1
)
type %DISKPART_CMD_LOG_FILE% | findstr /R /C:"^\*.*Volume[ ][ ]*[0123456789]*[ ][ ]*%MOUNT_VDISK_DRIVE_LETTER%[ ]" >nul 2>nul
if %errorlevel% NEQ 0 (
  call :Abort "Mounted '" %MOUNT_VDISK_FILE% "' to incorrect drive letter"
  exit /b 1
)
endlocal  
exit /b 0


:QuoteRemove:
set local

endlocal && set $2=%~1
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 