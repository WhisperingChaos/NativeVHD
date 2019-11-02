@echo off
setlocal

  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if exist %LOG_FILE% del %LOG_FILE% > nul

  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0..\..\..\..\Image\
  )
  call "%IMAGE_METHOD_PATH%\Revert.cmd" "%~dp0\config.cmd"

  findstr /R /C:"Abort.*Revert.cmd.*Please correct errors in configuration file" %LOG_FILE% && del %LOG_FILE%

endlocal
exit /b  %errorlevel%