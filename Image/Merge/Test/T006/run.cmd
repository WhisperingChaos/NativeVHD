@echo off
setlocal

  call "%~dp0\config.cmd"
  
  echo Create Layer Simulate > %MERGE_LAYER_FILE%
  
  if exist %MERGE_CANONICAL_BASE_FILE% (
    echo MERGE_CANONICAL_BASE_FILE should not exist, but it does: %MERGE_CANONICAL_BASE_FILE% >&2
	  exit /b 1
  )
  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0..\..\..\..\Image\
  )
  call "%IMAGE_METHOD_PATH%\Merge.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*MERGE_CANONICAL_BASE_FILE must exist to be reverted"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  del %MERGE_LAYER_FILE% > nul
  
endlocal
exit /b %errorlevel%