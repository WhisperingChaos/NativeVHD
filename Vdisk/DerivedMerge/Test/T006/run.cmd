@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%~dp0\config.cmd"
  if exist %DERIVED_LAYER_FILE% del %DERIVED_LAYER_FILE% > nul
  if exist %BASE_LAYER_FILE%    del %BASE_LAYER_FILE%    > nul

  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseCreate.cmd"
  if %errorlevel% NEQ 0 (
    echo %VDISK_METHOD_PATH%\BaseCreate.cmd failed but should have successfully completed >&2
    exit /b %errorlevel%
  )
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\configLayerCreate.cmd" | findstr /R /C:"Inform.*Ended: Layer VHD:.*creation: Successful"
    if %errorlevel% NEQ 0 (
    echo %VDISK_METHOD_PATH%\LayerCreate.cmd failed but should have successfully completed >&2
    exit /b %errorlevel%
  )
  if not exist %DERIVED_LAYER_FILE% (
    echo DERIVED_LAYER_FILE should exist, but it does not: %DERIVED_LAYER_FILE% >&2
	  exit /b 1
  )
  call "%VDISK_METHOD_PATH%\DerivedMerge.cmd" "%~dp0\config.cmd"
::| findstr /R /C:"Inform.*Ended: Layer VHD:.*creation: Successful"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
 
  del %DERIVED_LAYER_FILE% > nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  del %BASE_LAYER_FILE% > nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
    
endlocal
exit /b %errorlevel%