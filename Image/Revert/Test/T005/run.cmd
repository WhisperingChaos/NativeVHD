@echo off
setlocal

  call "%~dp0\config.cmd"
  if exist %REVERT_LAYER_FILE% (
    echo REVERT_LAYER_FILE should not exist, but it does: %REVERT_LAYER_FILE% >&2
	  exit /b 1
  )
  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0..\..\..\..\Image\
  )
  call "%IMAGE_METHOD_PATH%\Revert.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*REVERT_LAYER_FILE must exist to be reverted"
  if %errorlevel% NEQ 0 (
    exit /b %errorlevel%
  )
endlocal
exit /b %errorlevel%