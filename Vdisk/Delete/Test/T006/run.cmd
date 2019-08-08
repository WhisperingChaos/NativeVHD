@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\..\Vdisk\
  )
  set DELETE_VDISK_FILE="%~dp0T006.VHD"
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configCreate.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%VDISK_METHOD_PATH%\Protect.cmd" "%~dp0\configProtect.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 1 (
    echo Abort Delete of %DELETE_VDISK_FILE% should have returned a code of '1' to indicate failure.>&2
    exit /b 1
  )
  if not exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should remain because delete failed due to read only file attribute.>&2
    exit /b 1
  )
  call "%VDISK_METHOD_PATH%\ProtectWithdraw.cmd" "%~dp0\configProtectWithdraw.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should have been deleted.>&2
    exit /b 1
  )
endlocal
exit /b %errorlevel%