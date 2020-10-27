::-- see readme.txt
:subroutine:
setlocal

  if "%DISK_NUMBER%"=="undefined" exit /b 0
  
  set VOLUME_DISMOUNT_FAILED=false
  for /F "tokens=1,2,3*" %%l in ('type %DISKPART_CMD_LOG_FILE% ^| findstr /R /C:"[ ][ ]*Volume[ ][0-9][0-9]*"') do call :DisMountVolume %%l %%m VOLUME_DISMOUNT_FAILED
  if "%VOLUME_DISMOUNT_FAILED%" == "true" echo /b 1

endlocal
exit /b 0


:DisMountVolume:
  
  if "%VOLUME_DISMOUNT_FAILED%" == "true" exit /b 1
  
  if not "%1" == "Volume" (
    call :Abort "Expected keyword 'Volume' but encountered '" "%1" "'"
    exit /b 1
  )
  echo %2| findstr /R /C:"^[0-9][0-9]*$" >nul
  if %errorlevel% neq 0 (
    call :Abort "Expected numberic volume number but encountered '" "%2" "'"
    exit /b 1
  )
  set DISMOUNT_VOLUME_NUMBER=%2
  call %~dp0\..\..\DiskpartExecutor.cmd %~dp0\configDisMount.cmd
  if %errorlevel% neq 0 (
    set VOLUME_DISMOUNT_FAILED=true
    exit /b 1
  )
exit /b 0

  
:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1