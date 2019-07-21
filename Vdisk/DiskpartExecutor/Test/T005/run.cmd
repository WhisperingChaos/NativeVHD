@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\DiskpartExecutor.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*Diskpart failed.*See contents" > nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
 
endlocal
exit /b %errorlevel%