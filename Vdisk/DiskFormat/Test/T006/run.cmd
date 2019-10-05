@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0..\..\..\..\Vdisk\
  )
  set TEST_VHD_FILE="%~dp0Test.vhd"
  if exist %TEST_VHD_FILE% (
    del %TEST_VHD_FILE% >nul
    if %errorlevel% NEQ 0 exit /b %errorlevel%
  )
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configCreate.cmd" >nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
 
  call "%VDISK_METHOD_PATH%\DiskFormat.cmd" "%~dp0\config.cmd" >nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  del %TEST_VHD_FILE% >nul
    
endlocal
exit /b %errorlevel%