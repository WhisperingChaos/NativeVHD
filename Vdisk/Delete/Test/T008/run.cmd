@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\..\Vdisk\
  )
  set DELETE_VDISK_FILE="%~dp0T008.VHD"
  set DELETE_VDISK_MOUNT_DRIVE=T

  call :cleanup
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configCreate.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%VDISK_METHOD_PATH%\DiskFormat.cmd" "%~dp0\configDiskFormat.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%VDISK_METHOD_PATH%\Mount.cmd" "%~dp0\configMount.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  set DELETE_LOCK_PAUSE="%DELETE_VDISK_MOUNT_DRIVE%:\pausetest.txt"
  echo paused till removed > %DELETE_LOCK_PAUSE%
  ::-- exclusively lock file on vdisk being deleted to test dismount  
  start "Lock Mounted Volume" %~dp0LockitWhilePaused.cmd "%DELETE_VDISK_MOUNT_DRIVE%:\" %DELETE_LOCK_PAUSE%
  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 (
    del %DELETE_LOCK_PAUSE% >nul 2>nul
    exit /b 1
  )
  if exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should have been deleted by test.>&2
    exit /b 1
  )
  call :cleanup

endlocal
exit /b %errorlevel%


:cleanup:

  if not exist %DELETE_VDISK_FILE% exit /b 0
  
  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should have been deleted.>&2
    exit /b 1
  )
exit /b 0