:subroutine:
setlocal

  if not defined DISK_FORMAT_VOLUME_LABEL exit /b 0

  set VOLUME_LABEL_EXISTS=false
  for /F "tokens=1,2,3,4,5,6*" %%I in ('type %DISKPART_CMD_LOG_FILE% ^| findstr /R /C:"[ ][ ]*Volume[ ][0-9][0-9]*"') do call :LabelCheck  %%I %%J %%K %%L %%M VOLUME_LABEL_EXISTS || exit /b 1
  if "%VOLUME_LABEL_EXISTS%" == "false" (
    call :Abort "Specified DISK_FORMAT_VOLUME_LABEL '" %DISK_FORMAT_VOLUME_LABEL% "' not assigned to DISK_FORMAT_FILE '" %DISK_FORMAT_FILE% "'.  Unexpected result." 
    exit /b 1
  )
endlocal
exit /b 0


:LabelCheck:

  if not "%1" == "*" exit /b 0 
  
  if not "%2" == "Volume" (
    call :Abort "Expected keyword 'Volume' but encountered '" "%2" "'"
    exit /b 1
  )
  echo %3| findstr /R /C:"^[0-9][0-9]*$" >nul
  if %errorlevel% neq 0 (
    call :Abort "Expected numberic volume number but encountered '" "%3" "'"
    exit /b 1
  )
  ::-- since format doesn't assign a drive letter, there might not be one
  ::-- which changes the location of the disk label from 5th token to 4th.
  ::-- Hopefully, volume label isn't single alphabetic character. If it is,
  ::-- it may match the drive letter potentially assigned to the disk.
  if "%4"==%DISK_FORMAT_VOLUME_LABEL% (
    set VOLUME_LABEL_EXISTS=true
  )
  if "%5"==%DISK_FORMAT_VOLUME_LABEL% (
    set %6=true
  )
exit /b 0

  
:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1