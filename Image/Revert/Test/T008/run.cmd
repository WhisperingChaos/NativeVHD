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

  set DISK_FORMAT_FILE=%TEST_BASE_VHD_FILE%
  call "%VDISK_METHOD_PATH%\DiskFormat.cmd" "%~dp0\configDiskFormat.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  set MOUNT_VDISK_FILE=%TEST_BASE_VHD_FILE%
  set MOUNT_VDISK_DRIVE_LETTER=P
  call "%VDISK_METHOD_PATH%\Mount.cmd" "%~dp0\configMount.cmd"
  if %errorlevel% NEQ 0 exit /b 1
  
  set TEST_FILE_REVERT="%MOUNT_VDISK_DRIVE_LETTER%:\hello.txt"
  echo Hello>%TEST_FILE_REVERT%
  if not exist %TEST_FILE_REVERT% exit /b 1

  set MOUNT_REMOVE_VDISK_FILE=%TEST_BASE_VHD_FILE%
  call "%VDISK_METHOD_PATH%\MountRemove.cmd" "%~dp0\configMountRemove.cmd"
  if %errorlevel% NEQ 0 exit /b 1
  
  set BASE_LAYER_FILE=%TEST_BASE_VHD_FILE%
  set DERIVED_LAYER_FILE=%TEST_LAYER_VHD_FILE%
  call "%VDISK_METHOD_PATH%\LayerCreate.cmd" "%~dp0\configLayerCreate.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  set MOUNT_VDISK_FILE=%TEST_LAYER_VHD_FILE%
  set MOUNT_VDISK_DRIVE_LETTER=P
  call "%VDISK_METHOD_PATH%\Mount.cmd" "%~dp0\configMount.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  if not exist %TEST_FILE_REVERT% exit /b 1

  del %TEST_FILE_REVERT% >nul
  if %errorlevel% NEQ 0 exit /b 1
  
  if exist %TEST_FILE_REVERT% exit /b 1

  set MOUNT_REMOVE_VDISK_FILE=%TEST_LAYER_VHD_FILE%
  call "%VDISK_METHOD_PATH%\MountRemove.cmd" "%~dp0\configMountRemove.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  if not defined IMAGE_METHOD_PATH (
    set IMAGE_METHOD_PATH=%~dp0..\..\..\..\Image\
  )
  set REVERT_LAYER_FILE=%TEST_LAYER_VHD_FILE%
  set REVERT_CANONICAL_BASE_FILE=%TEST_BASE_VHD_FILE%
  call "%IMAGE_METHOD_PATH%\Revert.cmd" "%~dp0\config.cmd" 2>&1
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  set MOUNT_VDISK_FILE=%TEST_LAYER_VHD_FILE%
  set MOUNT_VDISK_DRIVE_LETTER=P
  call "%VDISK_METHOD_PATH%\Mount.cmd" "%~dp0\configMount.cmd"
  if %errorlevel% NEQ 0 exit /b 1

  if not exist %TEST_FILE_REVERT% exit /b 1

  set DELETE_VHD_FILE=%TEST_LAYER_VHD_FILE%
  call :TestVHDdelete
  if %errorlevel% NEQ 0 exit /b 1

  set DELETE_VHD_FILE=%TEST_BASE_VHD_FILE%
  call :TestVHDdelete
  if %errorlevel% NEQ 0 exit /b 1
  
endlocal
exit /b %errorlevel%


:TestVHDdelete:

  if exist %DELETE_VHD_FILE% (
    call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\configDelete.cmd"
  )
exit /b %errorlevel%
