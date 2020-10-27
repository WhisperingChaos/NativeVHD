@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\LayerMerge.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*LAYER_MERGE_FILE must exist to create new derived/child"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%~dp0\config.cmd"
  if exist %LAYER_MERGE_FILE% (
    echo LAYER_MERGE_FILE should not exist, but it does: %LAYER_MERGE_FILE% >&2
	  exit /b 1
  )
endlocal
exit /b %errorlevel%