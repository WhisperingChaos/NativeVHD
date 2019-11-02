@echo off
setlocal

  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0\..\..\..\..\Image\
  )
  set TEST_VHD_FILE="%~dp0test.vhd"
  
  call :DeleteTestFile %TEST_VHD_FILE%
  if %errorlevel% NEQ 0 exit /b 1

  call "%IMAGE_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseCreate.cmd"
  if %errorlevel% NEQ 0 (
    exit /b 1
  )
  call "%IMAGE_METHOD_PATH%\DiskFormat.cmd" "%~dp0\configDiskFormat.cmd"
  if %errorlevel% NEQ 0 (
    exit /b 1
  )
  call "%IMAGE_METHOD_PATH%\Mount.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 (
    exit /b 1
  )
::--  call :DeleteTestFile %TEST_VHD_FILE%
  
endlocal
exit /b %errorlevel%


:DeleteTestFile:

  if exist %TEST_VHD_FILE% (
    call "%IMAGE_METHOD_PATH%\Delete.cmd" "%~dp0\configDelete.cmd"
  )
exit /b %errorlevel%
