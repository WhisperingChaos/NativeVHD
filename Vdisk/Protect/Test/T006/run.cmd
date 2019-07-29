@echo off
setlocal

  if not defined VDISK_METHOD_PATH (
    set VDISK_METHOD_PATH=%~dp0\..\..\..\..\Vdisk\
  )
  call "%~dp0\configBaseLayer.cmd"
  if exist %BASE_LAYER_FILE% (
    attrib -r %BASE_LAYER_FILE% > nul
    del %BASE_LAYER_FILE% > nul
  )
  call "%VDISK_METHOD_PATH%\BaseCreate.cmd" "%~dp0\configBaseLayer.cmd"
  if %errorlevel% NEQ 0 (
    echo %VDISK_METHOD_PATH%\BaseCreate.cmd failed but should have successfully completed >&2
    exit /b %errorlevel%
  )
  call "%VDISK_METHOD_PATH%\Protect.cmd" "%~dp0\config.cmd" | findstr /R /C:"Inform.*Ended: VHD:.*protect: Successful"
    if %errorlevel% NEQ 0 (
    echo %VDISK_METHOD_PATH%\Protect.cmd failed but should have successfully completed >&2
    exit /b %errorlevel%
  )
  call "%~dp0\config.cmd"
  if not %PROTECT_FILE% == %BASE_LAYER_FILE% (
    echo PROTECT_FILE should reflect value of BASE_LAYER_FILE but it doesn't: %PROTECT_FILE% %BASE_LAYER_FILE% >&2
	  exit /b 1
  )
  attrib %PROTECT_FILE% | findstr /R /C:"A....R.*vhd"
  if %errorlevel% neq 0 (
    echo PROTECT_FILE not protected by readonly attribute: %PROTECT_FILE% >&2
	  exit /b 1
  )
  attrib -r %BASE_LAYER_FILE% > nul && del %BASE_LAYER_FILE% > nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%
    
endlocal
exit /b %errorlevel%