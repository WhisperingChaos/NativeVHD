@echo off
setlocal

  if not defined BASE_CREATE_PATH (
    set BASE_CREATE_PATH=..\..\..\..\Vdisk\
  )
  call "%BASE_CREATE_PATH%\BaseCreate.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%~dp0\config.cmd"   
  del %BASE_LAYER_FILE% > nul

endlocal
exit /b %errorlevel%