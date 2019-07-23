@echo off
setlocal

  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  del %LOG_FILE% > nul 2> nul
  
  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\DiskpartExecutor.cmd" "%~dp0\config.cmd"
  if %errorlevel% neq 0 exit /b 1
 
  findstr /R /C:"Inform.*Ended: dispart command.*Successful" %LOG_FILE% &&  del %LOG_FILE% > nul 2> nul
  
endlocal
exit /b %errorlevel%