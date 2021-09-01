@echo off
setlocal

  if not defined METHOD_PATH (
    set METHOD_PATH=%~dp0\..\..\..\
  )
  set TEST_TEMP_FILEPATH=
  call "%METHOD_PATH%TempCreate.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if not exist "%TEST_TEMP_FILEPATH%" (
    echo Abort newly created temp file should exist: TEST_TEMP_FILEPATH:'%TEST_TEMP_FILEPATH%' >&2
	exit /b 1
  )
  del "%TEST_TEMP_FILEPATH%" >nul
  
endlocal
exit /b %errorlevel%