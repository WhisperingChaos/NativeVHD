@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=..\..\..\..\Vdisk\
  )
  set DELETE_VDISK_FILE="%~dp0T007.VHD"

  call :cleanup
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configCreate.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  attrib +h %DELETE_VDISK_FILE% >nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*DELETE_VHD_FILE .* is delete protected .hidden. use .attrib -h. to make file deletion possible."
  if %errorlevel% NEQ 0 (
    echo Abort Delete of %DELETE_VDISK_FILE% should have generated delete protect message.>&2
    exit /b 1
  )
  if not exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should remain because delete failed due to read only file attribute.>&2
    exit /b 1
  )
  call :cleanup

endlocal
exit /b %errorlevel%


:cleanup:

  if not exist %DELETE_VDISK_FILE% exit /b 0
  
  attrib -h %DELETE_VDISK_FILE%  >nul  2>nul

  call "%VDISK_METHOD_PATH%\Delete.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if exist %DELETE_VDISK_FILE% (
    echo Abort %DELETE_VDISK_FILE% should have been deleted.>&2
    exit /b 1
  )
exit /b 0