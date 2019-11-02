@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  set TEST_LAYER_VHD_FILE="%~dp0Layer.vhd"
  set TEST_BASE_VHD_FILE="%~dp0Base.vhd"
  
  set TEST_VHD_FILE=%TEST_LAYER_VHD_FILE%
  call :DeleteTestFile
  if %errorlevel% NEQ 0 exit /b 1

  set TEST_VHD_FILE=%TEST_BASE_VHD_FILE%
  call :DeleteTestFile
  if %errorlevel% NEQ 0 exit /b 1

  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseCreate.cmd"
  if %errorlevel% NEQ 0 exit /b 1
  
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\configLayerCreate.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  call "%VDISK_METHOD_PATH%\LayerCanonicalParentPathGet.cmd" "%~dp0\config.cmd" | findstr /R /V /C:"^set CANONICAL_PARENT_NAME=....*"
  if %errorlevel% NEQ 0 exit /b 1

  set TEST_VHD_FILE=%TEST_LAYER_VHD_FILE%
  call :DeleteTestFile
  if %errorlevel% NEQ 0 exit /b 1

  set TEST_VHD_FILE=%TEST_BASE_VHD_FILE%
  call :DeleteTestFile
  
endlocal
exit /b %errorlevel%


:DeleteTestFile:

  if exist %TEST_VHD_FILE% (
    call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\configDelete.cmd"
  )
exit /b %errorlevel%
