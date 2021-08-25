@echo off
goto Main

:Help:
(
  echo ::-----------------------------------------------------------------------------
  echo ::--
  echo ::--  Module:	%~f0
  echo ::--  Version:	1.0
  echo ::--  Author:	Richard Moyse	
  echo ::--
  echo ::--  Purpose:
  echo ::--	   Provide an overview of software installation process.  Have user obtain
  echo ::--    install packages.  Prepare to "revert" the current OS image to its
  echo ::--    most recently "merged" state.
  echo ::--
  echo ::--  Assumes:
  echo ::--    1.  Relies on Windows BCDedit feature of Windows 7 and above.
  echo ::--    2.  The OS is managed as a set of Virtual Hard Drives ^(VHDs^) where
  echo ::--        a bootable child VHD protects the state of its parent VHD.
  echo ::--
  echo ::--  Input:
  echo ::--	1.  %1: Either:
  echo ::--		 	The full path name to a configuration file conatining
  echo ::--		 	argument values.
  echo ::--			"/?" displays the "help".
  echo ::--
  echo ::--  Output:
  echo ::--	1.  A request to revert the current installation that's processed by
  echo ::--     a "utility" bootable partition.
  echo ::--	2.  errorlevel:
  echo ::--		0: Either:
  echo ::--			Successful execution of "/?"
  echo ::--			Preparations to revert the desired volume was successful.
  echo ::--		1: Failure.
  echo ::--
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::
  echo ::-----------------------------------------------------------------------------
  echo ::-- Configuration file settings needed by the %~f0 script.
  echo ::-- This script is called from the same command processor as the %~f0 script
  echo ::-- Therefore, you can use other environment variables within this command process,
  echo ::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the 
  echo ::-- script.
  echo ::--
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
  echo ::-- as it will erase the values set by the script.
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::-- Required: The absolute path, without double quotes, to the Argument methods.
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, absent double quotes, to the directory that contains the logging methods.
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- logger
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>"
  echo ::
  echo ::-- Required: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, absent double quotes, to the directory that contains the Task methods.
  echo set TASK_BIND=^<TaskmethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- task create method
  echo set TASK_CREATE_CONFIG_FILE="<TaskCreateConfigurationAbsoluteFilePath>"
  echo ::
  echo ::
  echo ::-- Required: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- task create method
  echo set TASK_DELETE_CONFIG_FILE="<TaskCreateConfigurationAbsoluteFilePath>"
  echo ::
  echo ::-- Required: The name of the computer being reverted.  Assumes windows COMPUTERNAME if not specified
  echo set COMPUTER_NAME=^%COMPUTERNAME^%
  echo ::
  echo ::

  echo exit /b 0
)>&2
exit /b


:Main:
setlocal

  if "%~1"=="" ( 
    call :Abort "Please specify configuration file as first and only parameter.  Example follows:"
    call :Help
    exit /b 1
  )
  if "%~1"=="/?" (
    call :Help
	exit /b 0
  )
  if not exist "%~1" (
    call :Abort "Unable to locate provided configuration file: '%~1'.  Example follows:"
    call :Help
    exit /b 1
  )
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file:'%~1'." & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY GUID_BIND LOGGER_BIND LOGGER_CONFIG_FILE TASK_BIND TASK_CONFIG_FILE COMPUTER_NAME 
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
  call :Inform "Starting: Install Software Prep:'%INSTALL_PREP_IMAGE_TO_REVERT%'"

  call :StepOverview "%COMPUTER_NAME%"
  if errorlevel 1 exit /b 1

  call :ObtainPackages "%COMPUTER_NAME%"
  if errorlevel 1 exit /b 1

  call :Revert "%COMPUTER_NAME%"
  if errorlevel 1 exit /b 1
  
  call :TaskRevertCreate %TASK_CREATE_CONFIG_FILE%
  if errorlevel 1 exit /b 1

  call :BCDboot  %INSTALL_PREP_UILITY_BCD_ID%
  if errorlevel 1 (
    call :TaskRevertCancel %TASK_DELETE_CONFIG_FILE%
    exit /b 1
  )
  call :MachineReboot
  if errorlevel 1 exit /b 1
    call :TaskRevertCancel %TASK_DELETE_CONFIG_FILE%
    call :BCDboot "{current}"
    exit /b 1
  ) 
  call :Inform "Ended: Starting: Install Software Prep:'%INSTALL_PREP_IMAGE_TO_REVERT%'" Successful"

endlocal
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Provide user overview of software installation process.
::--
::--  Assumes:
::--    1.  Computer name is unique enough for user to
::--	    identify the computer being reverted.
::--
::--  Input:
::--    1.  %1 - The Computer name, potentially enclosed in double quotes,
::--		 that's targeted by the install process. 
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue the software install process.
::--		1: User aborted software install.
::--
::-----------------------------------------------------------------------------
:StepOverview:
  cls
  echo.
  echo.
  echo          Install Software Process 
  echo               Computer: "%~1"
  echo.
  echo.
  echo    The Software installation Process consists of a series of 
  echo    steps to properly install and integrate the software into
  echo    the computer's image.  The following outline summarizes
  echo    these steps:
  echo. 
  echo    1.  Obtain and save the installation package(s) for the 
  echo        desired application(s) to a persistent folder.
  echo.
  echo    2.  Revert the computer's "C:" drive to its last "good"
  echo        state.  
  echo.
  echo    3.  Execute the installation package(s).
  echo.
  echo    4.  Configure the application(s) for your use.
  echo.
  echo    5.  Cleanup any artifacts produced by each application's
  echo        install package.
  echo.
  echo    6.  Integrate the newly installed application(s) into the last
  echo        "good" state creating a new "good" state.
  echo.
  echo    Each of the steps above will be explained in greater detail
  echo    before they are performed.  
  
  call :PromptContinue "Install software for '%~1' computer"

exit /b


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Direct user to acquire software packages and then save them,
::--	as these packages will be installed after the current image
::--	has been reverted.  The installation packages are acquired before
::--	reverting the image to minimize any activity subsequent to reverting
::--	the immage that might introduce malware into the new image being
::--	created.  For example, any malware introduced by websurfing to
::--	find the installation package will be removed by the image revert 
::--	process before its permenetly saved to the new image.
::--
::--	Lastly, these preserved software packages are then available, 
::--	if needed, to install either additional features not initially
::--	included or repair a "broken" application by removing and then
::--	reinstalling it.
::--
::--  Assumes:
::--    1.  Computer name is unique enough for user to
::--	    identify the computer being reverted.
::--
::--  Input:
::--    1.  %1 - The Computer name, potentially enclosed in double quotes,
::--		 that's targeted by the install process. 
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue the software install process.
::--		1: User aborted software install.
::--
::-----------------------------------------------------------------------------
:ObtainPackages:
  cls
  echo.
  echo.
  echo			Install Software - Obtain Packages
  echo                   Computer: "%~1"
  echo.
  echo.
  echo. 
  echo    Please obtain the installation package(s) for the desired
  echo    application(s).
  echo.
  echo    Save each installation package to its own subdirectory whose
  echo    parent is: "E:\Local\InstallPackage".  For example, for the
  echo    an install package named "skypeInstall.exe" create a subdirectory
  echo    called: "E:\Local\InstallPackage\skype" and save "skypeInstall.exe"
  echo    to it. 
  echo.
  echo    Although not all install packages can be captured,
  echo    for example, some browser plugins install themselves,
  echo    most install packages can be saved as a file.  Even those recorded
  echo    a CD/DVD. In this situation, an ISO image file can be generated from
  echo    a CD/DVD using the installed DVD/CD copying software.
  echo.  
  echo    Finally, if the installation packaged must be activated via 
  echo    a product key, create a simple "ProductKey.txt" file in the same
  echo    directory containing the install package and record
  echo    the key in it.

  call :PromptContinue "Finished obtaining installation packages for '%~1' computer"

exit /b


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Offer user opportunity to start or terminate the reversion process.
::--
::--  Assumes:
::--    1.  Volume label (disk label) is unique enough for user to
::--	    identify the volume being reverted.
::--
::--  Input:
::--    1.  %1 - The volume label, potentially enclosed in double quotes,
::--		 to the OS volume targeted by the install process. 
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue the software install process.
::--		1: User aborted software install.
::--
::-----------------------------------------------------------------------------
:Revert:
  cls
  echo.
  echo.
  echo			Install Software - Revert
  echo                   Computer: "%~1"
  echo.
  echo.
  echo. 
  echo    Unless aborted, the computer's state will return to its last "good" one.
  echo.
  echo    Reversion eliminates any changes applied to the computer's "C:" drive,
  echo    except for files that that exist in the following folders:
  echo    "Documents", "Desktop", "Downloads" "Music", "Pictures", "Videos".
  echo.
  echo    Computer drives other then C: are unaffected.
  echo.
  echo    Once reversion starts it cannot be reversed.
  echo.
  echo    The computer will shutdown and then boot into its "Utility" partition
  echo    to affect changes.
  echo.
  echo    Please close any applications before proceeding.
  echo.
  echo    When Revert completes, it will return to this computer's log in screen.
  echo    Sign on with the current username: "%USERNAME%" to continue the install process.


  call :PromptContinue "Revert '%~1' state"

exit /b



::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Generic prompt to determine if user wishes to continue a given
::--	process.
::--
::--  Assumes:
::--    1.  Text block prior to prompt lacks white space. 
::--
::--  Input:
::--    1.  %1 - Process name to prompt.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue the named process.
::--		1: User wishes to abort the named process.
::--
::-----------------------------------------------------------------------------
:PromptContinue:
setlocal
  echo.
  echo.
  set /p CONTINUE_PROCESS="Continue %~1? (Y/N):"
  if /i not "%CONTINUE_PROCESS%"=="y" ( 
    echo.
    echo.
    echo %~1 aborted by user request.
    echo.
    echo.
    pause
	endlocal
    exit /b 1
  )
endlocal
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--    Generate the revert task as part of the install process.
::--
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Request successfully recorded.
::--		1: Failed to generate the request.
::--
::-----------------------------------------------------------------------------
:TaskRevertCreate:
setlocal

  call "%TASK_BIND%\Create" %TASK_CREATE_CONFIG_FILE%
  
  if errorlevel 1 (
    call :Abort "Failed to create task request needed to continue install request.  See: '" %TASK_CREATE_CONFIG_FILE% "'."
	exit /b 1
  )
endlocal
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--    Eliminate the revert task because install process has been
::--    aborted for some reason.
::--
::--  Input:
::--    1.  %1 - Requested task's file path name.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Request successfully recorded.
::--		1: Failed to generate the request.
::--
::-----------------------------------------------------------------------------
:TaskRevertCancel:
setlocal

  call "%TASK_BIND%\Delete" %TASK_DELETE_CONFIG_FILE%
  
  if errorlevel 1 (
    call :Abort "Failed to delete revert task request during cancel on install.  See: '" %TASK_DELETE_CONFIG_FILE% "'."
	exit /b 1
  )
endlocal
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--    Set default Boot to specified computer.
::--
::--  Input:
::--    1.  %1 - Desired Boot Configuration Data (BCD) Identifier.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Request successfully recorded.
::--		1: Failed to generate the request.
::--
::-----------------------------------------------------------------------------
:BCDboot:
setlocal
set COMPUTER_BCD_ID=%~1

  start /elevate /b /wait bcdedit /default %COMPUTER_BCD_ID%
  
  if errorlevel 1 (
	call :Abort "Failed to establish specified BCD Identifier:'%COMPUTER_BCD_ID%' as default boot entry."
	exit /b 1
  )
endlocal
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--    Asynchronously shutdown the current computer.
::--
::-----------------------------------------------------------------------------
:MachineReboot:
setlocal

  start "Shutdown to Revert" /elevate shutdown /r /f /t 10 /d p:02:02 /c "Request to revert this computer %COMPUTERNAME% computer."
  
  if errorlevel 1 (
	call :Abort "Failed to properly request shutdown"
	exit /b 1
  )
endlocal
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0