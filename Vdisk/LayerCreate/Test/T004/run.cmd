@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*Following configuration variables must be defined.*BASE_LAYER_FILE.*DERIVED_LAYER_FILE.*DISKPART_EXECUTOR_CONFIG_FILE"
  
endlocal
exit /b %errorlevel%