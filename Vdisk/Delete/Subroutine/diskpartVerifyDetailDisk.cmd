::-- see readme.txt
:subroutine:
setlocal

  set DISK_NUMBER=undefined
  for /F "tokens=1,2,3,4*" %%l in ('type %DISKPART_CMD_LOG_FILE% ^| findstr /C:"Associated disk#:"') do call :DiskExtract %%l %%m %%n DISK_NUMBER
  if %errorlevel% neq 0 exit /b 1

  call %~dp0\..\..\DiskpartExecutor.cmd %~dp0\configDiskSelect.cmd
  if %errorlevel% neq 0 exit /b 1
    
endlocal
exit /b 0
  

:DiskExtract:

  if not "%1" == "Associated" (
    call :Abort "Expected keyword 'Associated' but encountered '" "%1" "'"
    exit /b 1
  )
  if not "%2" == "disk#:" (
    call :Abort "Expected keyword 'disk#:' but encountered '" "%2" "'"
    exit /b 1
  )
  ::-- never assigned to a disk :: can't have mounted volume
  if "%3" == "Not" exit /b 0
  
  echo %3| findstr /R /C:"^[0-9][0-9]*$" >nul
  if %errorlevel% neq 0 (
    call :Abort "Expected numberic disk number but encountered '" "%3" "'"
    exit /b 1
  )
  set %4=%3
  
exit /b 0
  
  
:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 
