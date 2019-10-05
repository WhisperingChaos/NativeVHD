@echo off
setlocal

 if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  set TEST_VHD_FILE="%~dp0test.vhd"

  call :DeleteTestFile %TEST_VHD_FILE%
  if %errorlevel% NEQ 0 exit /b 1

  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseCreate.cmd"
  if %errorlevel% NEQ 0 (
    exit /b 1
  )
  call "%VDISK_METHOD_PATH%\MountRemove.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 (
    exit /b 1
  )
  call :DeleteTestFile %TEST_VHD_FILE%
  
endlocal
exit /b %errorlevel%


:DeleteTestFile:

  if exist %TEST_VHD_FILE% (
    call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\configDelete.cmd"
  )
exit /b %errorlevel%