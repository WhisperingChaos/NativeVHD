@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\..\Vdisk\
  )
  set DELETE_VDISK_FILE="%~dp0T005.VHD"
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configCreate.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  if exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should have been deleted.>&2
    exit /b 1
  )  

endlocal
exit /b %errorlevel%