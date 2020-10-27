@echo off
setlocal

  set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  set TEST_LAYER_VHD_FILE="%~dp0Layer.vhd"
  set TEST_BASE_VHD_FILE="%~dp0Base.vhd"
  
  set DELETE_VHD_FILE=%TEST_LAYER_VHD_FILE%
  call :TestVHDdelete
  if %errorlevel% NEQ 0 exit /b 1

  set DELETE_VHD_FILE=%TEST_BASE_VHD_FILE%
  call :TestVHDdelete
  if %errorlevel% NEQ 0 exit /b 1

  set BASE_LAYER_FILE=%TEST_BASE_VHD_FILE%
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseCreate.cmd"
  if %errorlevel% NEQ 0 exit /b 1
  
  set BASE_LAYER_FILE=%TEST_BASE_VHD_FILE%
  set DERIVED_LAYER_FILE=%TEST_LAYER_VHD_FILE%
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\configLayerCreate.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  set LAYER_CANONICAL_LAYER_FILE=%TEST_LAYER_VHD_FILE%
  for /F "tokens=1* delims=" %%s in ( 'call "%VDISK_METHOD_PATH%\LayerCanonicalParentPathGet.cmd" "%~dp0\configLayerCanonicalParentPathGet.cmd" ^| findstr /R /C:"^set TEST_CANONICAL_PARENT_NAME=....*"') do %%s
  if %errorlevel% NEQ 0 exit /b 1

  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0\..\..\..\..\Image\
  )
  set REVERT_LAYER_FILE=%TEST_LAYER_VHD_FILE%
  set REVERT_CANONICAL_BASE_FILE=%TEST_CANONICAL_PARENT_NAME%
  call "%IMAGE_METHOD_PATH%\Revert.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  set DELETE_VHD_FILE=%TEST_LAYER_VHD_FILE%
  call :TestVHDdelete
  if %errorlevel% NEQ 0 exit /b 1

  set DELETE_VHD_FILE=%TEST_BASE_VHD_FILE%
  call :TestVHDdelete
  
endlocal
exit /b %errorlevel%


:TestVHDdelete:

  if exist %DELETE_VHD_FILE% (
    call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\configDelete.cmd"
  )
exit /b %errorlevel%