@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*BASE_LAYER_FILE must exist to create"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%~dp0\config.cmd"
  if exist %DERIVED_LAYER_FILE% (
    echo DERIVED_LAYER_FILE should not exist, but it does: %DERIVED_LAYER_FILE% >&2
	  exit /b 1
  )
endlocal
exit /b %errorlevel%