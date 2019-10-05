@echo off
setlocal

  call "%~dp0\config.cmd"
  if exist %DISK_FORMAT_FILE% (
    echo DISK_FORMAT_FILE should not exist, but it does: %DISK_FORMAT_FILE% >&2
	  exit /b 1
  )
  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0..\..\..\..\Vdisk\
  )
  call "%VDISK_METHOD_PATH%\DiskFormat.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*DISK_FORMAT_FILE must exist to be formatted"
  if %errorlevel% NEQ 0 (
    exit /b %errorlevel%
  )
endlocal
exit /b %errorlevel%