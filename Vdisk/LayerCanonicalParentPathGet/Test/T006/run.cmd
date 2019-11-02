@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%~dp0\config.cmd"
  echo > %LAYER_CANONICAL_LAYER_FILE%
  if not exist %LAYER_CANONICAL_LAYER_FILE% (
    echo LAYER_CANONICAL_LAYER_FILE should exist but it does not: '%LAYER_CANONICAL_LAYER_FILE%' >&2
	  exit /b 1
  )
  call "%VDISK_METHOD_PATH%\LayerCanonicalParentPathGet.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*DiskpartExecutor.cmd.*Diskpart failed.  See contents of:"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
endlocal
exit /b %errorlevel%