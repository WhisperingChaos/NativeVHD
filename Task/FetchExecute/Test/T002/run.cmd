@echo off
setlocal

  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  del %LOG_FILE% > nul 2> nul

  if not defined TASK_FETCH_PATH (
    set TASK_FETCH_PATH=..\..\..\..\Task\
  )
  call "%TASK_FETCH_PATH%\FetchExecute.cmd" "%~dp0\config.cmd"

  findstr /R /C:"Abort.*Please correct errors in configuration file" %LOG_FILE% && del %LOG_FILE%

endlocal
exit /b  %errorlevel%