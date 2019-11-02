@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%~dp0\config.cmd"
  if exist %LAYER_CANONICAL_LAYER_FILE% (
    echo "LAYER_CANONICAL_LAYER_FILE should not exist, but it does: '" %LAYER_CANONICAL_LAYER_FILE% "'" >&2
	  exit /b 1
  )
  call "%VDISK_METHOD_PATH%\LayerCanonicalParentPathGet.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*LAYER_CANONICAL_LAYER_FILE must exist to obtain its base VHD"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
endlocal
exit /b %errorlevel%