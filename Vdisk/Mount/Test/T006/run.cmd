@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%~dp0\config.cmd"
  if not exist %MOUNT_VDISK_FILE% (
    echo "Simulated VHD" > %MOUNT_VDISK_FILE%
  )
  vol %MOUNT_VDISK_DRIVE_LETTER%: 2>&1 | findstr /C:"The system cannot find the path specified." >nul
  if %errorlevel% EQU 0 (
    subst %MOUNT_VDISK_DRIVE_LETTER%: "%TEMP%"
    if %errorlevel% NEQ 0 (
      echo Abort selected MOUNT_VDISK_DRIVE_LETTER "'%MOUNT_VDISK_DRIVE_LETTER%'" already mounted or unmountable. >&2
      exit /b 1
    )
    set DISMOUNT_DRIVE_LETTER=%MOUNT_VDISK_DRIVE_LETTER%
  )
  call "%VDISK_METHOD_PATH%\Mount.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*MOUNT_VDISK_DRIVE_LETTER.*unavailable to assign as mount point"
  set MOUNT_RETURN_CODE=%errorlevel%
  if defined DISMOUNT_DRIVE_LETTER (
    subst /D %DISMOUNT_DRIVE_LETTER%:
    if %errorlevel% NEQ 0 (
      echo Abort unable to unmount MOUNT_VDISK_DRIVE_LETTER "'%MOUNT_VDISK_DRIVE_LETTER%'.">&2
      exit /b 1
    )
  )
  del %MOUNT_VDISK_FILE% >nul 2>nul
  
endlocal & exit /b %MOUNT_RETURN_CODE%