@echo off
goto Main

:Help:
  echo ::----------------------------------------------------------------------------->&2
  echo ::-->&2
  echo ::--  Module:	%~f0>&2
  echo ::--  Version:	1.0>&2
  echo ::--  Author:	Richard Moyse>&2	
  echo ::-->&2
  echo ::--  Purpose:>&2
  echo ::--	Prepare to "revert" the current OS image to its most recently>&2
  echo ::--	"merged" state.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--	1.  Relies on Windows BCDedit feature of Windows 7 and above.>&2
  echo ::--	2.  Executing script with Administrator privileges.>&2
  echo ::--	3.  Chages are applied to the default boot manager instance.>&2
  echo ::--	4.  Its companion "Image<VolumeLabelNameToClean>Revert.cmd" exists>&2
  echo ::--	    in the same directory as itself.>&2
  echo ::--	5.  The OS is managed as a set of Virtual Hard Drives (VHDs) where>&
  echo ::--	    a bootable child VHD protects the state of its parent VHD.
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  %1: Either:>&2
  echo ::--		 	The full path name to a configuration file conatining>&2
  echo ::--		 	argument values.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  A script that will discard changes made to the  .>&2
  echo ::--	2.  A new boot manager instance that replaced the primary>&2
  echo ::--	    boot manager instance, with one preconfigured with an entry>&2
  echo ::--	    to boot into the PhysicalWin7 volume/image,>&2
  echo ::--	    as the new default boot OS.>&2
  echo ::--	3.  errorlevel:>&2
  echo ::--		0: Either:>&2
  echo ::--			Successful execution of "/?">&2
  echo ::--			Preparations to revert the desired volume was successful.>&2
  echo ::--		1: Failure.>&2
  echo ::-->&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::-- Configuration file settings needed by the %~f0 script.>&2
  echo ::-- This script is called from the same command processor as the %~f0 script>&2
  echo ::-- Therefore, you can use other environment variables within this command process,>&2
  echo ::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the >&2
  echo ::-- script.>&2
  echo ::-->&2
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this top most level,>&2
  echo ::-- as it will erase the values set by the script.>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::-- The absolute path, without double quotes, to the Argument methods.>&2
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, without double quotes, to the Boot Manager methods.>&2
  echo set BOOT_MANAGER_BIND=^<BootManagerMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set STARTUP_BIND=^<MachineStartupMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The windows Volume (drive label name) assigned to the VHD.  Should reflect the role name of the>&2
  echo ::-- person using this image.  The label name must not contain spaces.>&2
  echo set VOLUME_LABEL_TO_REVERT=^<VolumeLabelNameToClean^>>&2
  echo ::>&2
  echo exit /b 0 >&2
exit /b


:Main:
  setlocal

  if "%~1"==""       call :Abort "Please specify configuration file as first and only parameter.  Example follows:" & call :Help & exit /b 1
  if "%~1"=="/?"     call :Help & exit /b 0
  if not exist "%~1" call :Abort "Unable to locate provided configuration file: '%~1'.  Example follows:" & call :Help & exit /b 1
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file:'%~1'." & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY BOOT_MANAGER_BIND STARTUP_BIND LOGGER_BIND LOGGER_CONFIG_FILE VOLUME_LABEL_TO_REVERT
  if errorlevel 1 (
     call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'."
     call :Abort "Please correct errors in configuration file '%~1'."
     exit /b 1
  )
  ::-- Determine if the transaction identifier has been defined before the configuration of this module.
  ::-- If it has, this module is a more primative element of an aggregate transaction.  Therefore, its
  ::-- logged error messages will reflect the aggregate transaction id.  This allows the "tracing" of
  ::-- an aggregate transaction through all its primative modules as they generate messages during their
  ::-- execution with the shared transaction identifier.  Otherwise, this module is being executed
  ::-- as a stand alone transaction, therefore, generate its own unique transaction id.
  if "%NHN.TRANSACTION_ID%"=="" (
     call "%GUID_BIND%\gen" NHN.TRANSACTION_ID
     if errorlevel 1 call :Abort "Generation of unique Transaction Id failed." & exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Starting: Image Revert:'%VOLUME_LABEL_TO_REVERT%'"

  call :ImageRevertUserMessage %VOLUME_LABEL_TO_REVERT%
  if errorlevel 1 call :Abort "Image Revert of '%VOLUME_LABEL_TO_REVERT%' terminated by user request." & exit /b 1

  set IMAGE_REVERT_VOL_CMD=%~dp0Image%VOLUME_LABEL_TO_REVERT%Revert.cmd
  if not exist "%IMAGE_REVERT_VOL_CMD%" ( call :Abort "Image Revert of:'%VOLUME_LABEL_TO_REVERT%' missing:'%IMAGE_REVERT_VOL_CMD%'."
    pause
    exit /b 1
  )
  ::--  Copy the Image Revert process to a command file that executes once the task scheduler, in Physical7Win runs during the machine's startup
  xcopy "%IMAGE_REVERT_VOL_CMD%" "%STARTUP_BIND%\OnMachineStartup.cmd" /Y
  if errorlevel 1 (
    cls
    echo.
    echo.
    echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
    echo.
    echo.
    pause
    call :Abort "Failed to overlay:'%STARTUP_BIND%\OnMachineStartup.cmd' with Image Revert instruction file:'%IMAGE_REVERT_VOL_CMD%'."
    exit /b 1
  )
  call "%BOOT_MANAGER_BIND%\PhysicalWin7.cmd"
  if errorlevel 1 (     
    ::--  undo the startup command above that completed successfully to preserve "atomic" aspect of this process.
    echo exit /b 0 > "%STARTUP_BIND%\OnMachineStartup.cmd"
    cls
    echo.
    echo.
    echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
    echo.
    echo.
    pause
    call :Abort "Unable to establish boot manager instance to 'PhysicalWin7' volume. Failing module:'%BOOT_MANAGER_BIND%\PhysicalWin7.cmd'."
    exit /b 1
  )
  call :ImageRevertMessageReboot %VOLUME_LABEL_TO_REVERT%

  ::-- Restart the machine! 
  start Shutdown /r /f /d p:2:2 /t 10 /c "Rebooting to 'PhysicalWin7' to continue the Image Revert process."

  ::-- successful so far!
  call :Inform "Ended: Image Revert:'%VOLUME_LABEL_TO_REVERT%' Successful"

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Warn user of impending Image Revert and permit him/her to
::--	discontinue the process
::--
::--  Assumes:
::--    1.  Volume label (disk label) is unique enough for user to
::--	    identify the volume being reverted.
::--
::--  Input:
::--    1.  %1 - The volume label, potentially enclosed in double quotes,
::--		 to the derived file that must be removed.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue image reverting process.
::--		1: User aborted image reverting process.
;;--
::-----------------------------------------------------------------------------
:ImageRevertUserMessage:
  setlocal
  cls
  echo.
  echo.
  echo				Image Revert Process
  echo.
  echo.
  echo	  Please save any files, exit all applications, and log out
  echo	  from all other accounts before continuing the Image
  echo	  Revert Process, as it will ultimately execute a forced reboot.
  echo	  A forced remoot will likely result in lost changes or
  echo	  file corruption in those files, like Word Documents, that
  echo	  remain open/editable in applications not properly terminated.
  echo.
  echo	  This process will revert this Windows 7 Ultimate volume:'%~1'
  echo	  to its last saved state.  All files on this system except
  echo	  those saved to specific directories associated to the "AMAN"
  echo	  and "zServicePC accounts will be reverted or destroyed.
  echo.
  echo.
  echo	  The following AMAN account directories and their contents
  echo	  will be preserved (untouched) by image reversion:
  echo		1.  Desktop
  echo		2.  My Documents
  echo		3.  My Music 
  echo		4.  My Video
  echo		5.  My Pictures
  echo		6.  Favorites
  echo		7.  Links 
  echo.
  echo.
  echo	  The following zServicePC account directory and its contents
  echo	  will be preserved (untouched) by image reversion:
  echo		1.  Desktop\PC Config Student
  echo.
  echo.

  set /p CONTINUE_IMAGE_REVERT="Continue Image Revert? (Y/N):"
  if /i not "%CONTINUE_IMAGE_REVERT%"=="y" ( 
    echo.
    echo.
    echo Image Revert aborted by user request.
    echo.
    echo.
    pause
    exit /b 1
  )
  echo.
  echo.
  set /p CONTINUE_IMAGE_REVERT="Are you sure? (Y/N):"
  if /i not "%CONTINUE_IMAGE_REVERT%"=="y" (
    echo.
    echo.
    echo Image Revert aborted by user request.
    echo.
    echo.
    pause
    exit /b 1
  )
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Warn user of impending reboot to the utility partition that will
::--	run the remainder of the Image Revert process.
::--
::--  Assumes:
::--    1.  Volume label (disk label) is unique enough for user to
::--	    identify the volume being reverted.
::--
::--  Input:
::--    1.  %1 - The volume label, potentially enclosed in double quotes,
::--		 to the derived file that must be removed.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Always.
;;--
::-----------------------------------------------------------------------------
:ImageRevertMessageReboot:
  cls
  echo.
  echo.
  echo				Image Revert Process
  echo.
  echo	  The machine will now reboot itself to the "PhysicalWin7"
  echo	  volume to continue the Image Revert Process.  Once 
  echo	  this process process completes, it will reboot back to
  echo	  this '%~1' volume.
  echo.
  echo.
  echo	  Press any key to initiate 10sec countdown to reboot.
  echo.
  echo.

  pause

exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0