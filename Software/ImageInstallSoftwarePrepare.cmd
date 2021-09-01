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
  echo ::--	   Prepare to "revert" the current OS image to its most recently
  echo ::--	   "merged" state.
  echo ::--
  echo ::--  Assumes:
  echo ::--    1.  Relies on Windows BCDedit feature of Windows 7 and above.
  echo ::--    2.  Executing script with Administrator privileges.
  echo ::--    3.  Chages are applied to the default boot manager instance.
  echo ::--    4.  Its companion "Image<VolumeLabelNameToClean>Revert.cmd" exists
  echo ::--        in the same directory as itself.
  echo ::--    5.  The OS is managed as a set of Virtual Hard Drives ^(VHDs^) where>&
  echo ::--        a bootable child VHD protects the state of its parent VHD.
  echo ::--
  echo ::--  Input:
  echo ::--	1.  %1: Either:
  echo ::--		 	The full path name to a configuration file conatining
  echo ::--		 	argument values.
  echo ::--			"/?" displays the "help".
  echo ::--
  echo ::--  Output:
  echo ::--	1.  A script that will discard changes made to the  .
  echo ::--	2.  A new boot manager instance that replaced the primary
  echo ::--	    boot manager instance, with one preconfigured with an entry
  echo ::--	    to boot into the PhysicalWin7 volume/image,
  echo ::--	    as the new default boot OS.
  echo ::--	3.  errorlevel:
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
  echo ::-- The absolute path, without double quotes, to the Argument methods.
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>
  echo ::
  echo ::-- The absolute path, without double quotes, to the Boot Manager methods.
  echo set BOOT_MANAGER_BIND=^<BootManagerMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>
  echo ::
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  echo set STARTUP_BIND=^<MachineStartupMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- logger
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>"
  echo ::
  echo ::-- The windows Volume ^(drive label name^) assigned to the VHD.  Should reflect the role name of the
  echo ::-- person using this image.  The label name must not contain spaces.
  echo set VOLUME_LABEL_TO_REVERT=^<VolumeLabelNameToClean^>
  echo ::
  echo ::-- Windows account names that will be notified when they log in to potentially continue
  echo ::-- the software install process.  Account names containing spaces must be encapsulated
  echo ::-- in double quotes. Use a space to seperate account names.
  echo set USER_ACCOUNT_NOTIFY_LIST=^<WindowsAccountName1^> ^<WindowsAccountName2>^....^<WindowsAccountName6^>
  echo ::>&2

  echo exit /b 0 >&2
)
exit /b


:Main:

  echo ???? - Check for unfinished effort
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
  call :Inform "Starting: Install Software %STEP_CURRENT%:'%VOLUME_LABEL_TO_REVERT%'"
  ::--  Potentially continue an ongoing 
  call :InstallStepOverview
  if errorlevel 1 exit /b 1

  call :InstallObtainPackages
  if errorlevel 1 exit /b 1

  call :InstallRevert
  if errorlevel 1 exit /b 1
 
  call :Inform "Ended: Starting: Install Software %STEP_CURRENT%:'%VOLUME_LABEL_TO_REVERT%'" Successful"

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Manage user interaction and install preperation till the image 
::--	revert process executes.
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
:InstallStepOverview:

  call :InstallSoftwareOverview %1
  if errorlevel 1 call :Abort "Software Install to:'%VOLUME_LABEL_TO_REVERT%' terminated by user request." & exit /b 1

  call :InstallObtainPackages %1
  if errorlevel 1 call :Abort "Software Install to:'%VOLUME_LABEL_TO_REVERT%' terminated by user request." & exit /b 1

  call :StartupContinue InstallSoftwareExecute %USER_ACCOUNT_NOTIFY_LIST%
  if errorlevel 1 ( call :Abort "Could not alter startup process for users to:'%VOLUME_LABEL_TO_REVERT%' missing:'%IMAGE_BASE_UPDATE_CMD%'."
    cls
    echo.
    echo.
    echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
    echo.
    echo.
    pause
    exit /b 1
  )
  set IMAGE_REVERT_VOL_CMD=%~dp0Image%VOLUME_LABEL_TO_REVERT%RevertPrepare.cmd
  if not exist "%IMAGE_REVERT_VOL_CMD%" ( call :Abort "Image Revert of:'%VOLUME_LABEL_TO_REVERT%' missing:'%IMAGE_REVERT_VOL_CMD%'."
    cls
    echo.
    echo.
    echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
    echo.
    echo.
    pause
    exit /b 1
  )
  ::-- Revert the current image
  call %IMAGE_REVERT_VOL_CMD%
  if errorlevel 1 call :StartupContinueRollback InstallSoftwareExecute Aman zServicePC & exit /b 1

exit /b 0
    
	
::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Provide user overview of software installation process.
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
;;--
::-----------------------------------------------------------------------------
:InstallSoftwareOverview:
  cls
  echo.
  echo.
  echo			Install Software Process
  echo				(%~1)
  echo.
  echo.
  echo	  The Software installation Process consists of a series of 
  echo	  steps to properly install and integrate the software into
  echo	  the computer's image.  The following outline summarizes
  echo    these steps:
  echo. 
  echo	  1.  Save the installation package(s) for the desired 
  echo	      application(s) to following directory.
  echo.
  echo    2.  Revert the computer's environment to its last "good"
  echo        state.  Reversion eliminates any changes applied to the
  echo        computer, except for files that that exist in the following
  echo        directories:  "Documents", "Desktop", "Downloads" "Music",
  echo        "Pictures", "Videos".
  echo.
  echo	  3.  Execute the installation package(s) for the desired
  echo	      application(s).
  echo.
  echo	  4.  Configure the application(s) for your use.
  echo.
  echo	  5.  Cleanup any artifacts produced by each application's
  echo	      install package.
  echo.
  echo	  6.  Integrate the newly installed application(s) into the last
  echo        "good" image creating a new "good" image.

  call :PromptContinue "Install Software for '%~1' volume"

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
;;--	if needed, to install either additional features not initially
::--	included or repair a "broken" application by removing and then
::--	reinstalling it.
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
;;--
::-----------------------------------------------------------------------------
:InstallObtainPackages:
  cls
  echo.
  echo.
  echo			Install Software - Obtain Packages
  echo				(%~1)
  echo.
  echo.
  echo. 
  echo	  Please obtain the installation package(s) for the desired
  echo    application(s).
  echo.
  echo    Save each installation package to its own subdirectory whose
  echo    parent is: "E:\Local\InstallPackage".  For example, for the
  echo    an install package named "skypeInstall.exe" create a subdirectory
  echo    called: "E:\Local\InstallPackage\skype" and save "skypeInstall.exe"
  echo    to it. 
  echo.
  echo	  Although not all install packages can be captured,
  echo    for example, some browser plugins install themselves,
  echo	  most install packages can be saved as a file.  Even those recorded
  echo    a CD/DVD. In this situation, an ISO image file can be generated from
  echo    a CD/DVD using the installed DVD/CD copying software.
  echo.  
  echo	  Finally, if the installation packaged must be activated via 
  echo	  a product key, create a simple "ProductKey.txt" file in the same
  echo	  directory containing the install package and record
  echo	  the key in it.

  call :PromptContinue "Install Software for '%~1' volume"

exit /b


:InstallRevert:




::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Guides the user through the process of installing and configuring
::--	software, cleaning up install artifacts, and updating the base image
::--	to persistently incorporate installed software into the image's
::--	execution environment.
::--
::--  Assumes:
::--    1.  The previous install steps have successfully completed.
::--	2.  The previous install step initiated this one via log on
::--	    startup scheduled task.
::--
::--  Input:
::--    1.  %1 - The volume label, potentially enclosed in double quotes,
::--		 to the OS volume targeted by the install process.
::--	2.  %2 - The administrator account name that's running the install
::--		 process to update the Volume identified by 1.
::--	2.  USER_ACCOUNT_NOTIFY_LIST - A environment variable whose contents
::-- 		 reflect a list of Windows' Account names that must be
::--		 notified when continuing this step across a reboot.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: User wishes to continue the software install process.
::--		1: User aborted software install or unexpected error.
::--	2.  User's Log on Startup Task: When successful, each user's log
::--		on startup task contains code to continue the task across
::--		this rebooted machine.  Otherwise, the startup task code for
::--		each user is altered to simply return return code 0.
::--
::--		
;;--
::-----------------------------------------------------------------------------
:InstallStepExecute:

  ::-- Direct user to now install and configure the software.
  call :PackagesInstall %1
  if errorlevel 1 call :InstallTerminatedUserRollback %1 "%~0 - Package Install" & exit /b 1

  ::-- Inform user that common install artifacts will be removed from the image.
  call :ArtifactCleanup %1
  if errorlevel 1 call :InstallTerminatedUserRollback %1 "%~0 - Artifact Cleanup" & exit /b 1

  ::-- Inform user that continuing the install process will update the base image with the installed packages.
  call :BaseImageUpdate %1
  if errorlevel 1 call :InstallTerminatedUserRollback %1 "%~0 - Base Image Update" & exit /b 1

  ::-- User no longer being guided through this step of the install process.
  ::-- Notify user of problem and cleanup startup changes iff an unexpected error occurs.

  ::-- Configure the log on script to inform users with limited access to log on as the appropriate
  ::-- administrator to continue the install process.
  call :StartupContinueUser InstallContinueAsAdmin %USER_ACCOUNT_NOTIFY_LIST%
  if errorlevel 1 ( 
    call :ErrorUnexpected "Could not alter startup process for volume: '%VOLUME_LABEL%' for one or more users:'" %USER_ACCOUNT_NOTIFY_LIST%
    exit /b 1
  )
  ::-- Configure the log on script for the administrator account to perform backup inform users with limited access to log on as the appropriate
  ::-- administrator to continue the install process.
  call :StartupContinueAdmin InstallImageBackup InstallImageRevertFailure  %2
  if errorlevel 1
    call :ErrorUnexpected "Could not alter startup process for volume:'%VOLUME_LABEL%' admin account:'" %ADMIN_ACCOUNT_NOTIFY "'."
    exit /b 1
  )
  ::-- Make sure the image update command exists
  if not exist "%IMAGE_BASE_UPDATE_CMD%" (
     call :ErrorUnexpected "Image Update of:'%VOLUME_LABEL' missing command:'%IMAGE_BASE_UPDATE_CMD%'."
     exit /b 1
  )
  ::-- Merge the current child VHD image back into its immediate parent.
  call %IMAGE_BASE_UPDATE_CMD%
  if errorlevel 1 ( 
    call :ErrorUnexpected "Image Update command:'" %IMAGE_BASE_UPDATE_CMD% "' failed.  Review previous log messages."
    exit /b 1
  )
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Inform user that reversion has been successful and he/she
::--	should now install the disired software packages.
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
;;--
::-----------------------------------------------------------------------------
:PackagesInstall:
  cls
  echo.
  echo.
  echo			Install Software Process
  echo				(%~1)
  echo.
  echo.
  echo	  The image has been successfully reverted.  It is now time
  echo	  to restart the install process.
  echo.
  echo    Unless necessary, avoid all activities that may infect
  echo	  this image with malware.  For example, abstain from all
  echo	  web surfing. However, if you must web surf, visit only
  echo	  trustworthy sites.
  echo.  
  echo	  3.  Execute the installation package(s) for the desired
  echo	      application(s).
  echo.
  echo	  4.  Configure the application(s) for your use.
  echo.
  echo	  5.  Cleanup any artifacts produced by each application's
  echo	      install package.
  echo.
  echo	  6.  Update the base image (parent VHD) with the 
  echo	      changes applied by the installation packages to
  echo	      the derived image (child VHD)
  echo.
  echo	  7.  Backup this new base image.
  echo.
  echo	  You will continue to receive this message after every log on
  echo	  until you either complete this process or abort it.  Therefore,
  echo	  if installing software requires the machine to restart,
  echo	  this message will reappear everytime you log onto this account.
  echo. 
  echo	  Once you've installed and configured the the desired packages,
  echo	  steps 3 & 4 above, answer the prompt below to indicate you
  echo	  wish to continue.
  echo.
  echo	  Note, if installation requires more than 45 minutes to complete,
  echo	  you will be prompted to confirm the update of the base image as
  echo	  the probability of infecting the image is proportional to the
  echo	  delay between an image's reversion and the completion of the
  echo	  image update process.

  call :PromptContinue "Install Software for '%~1 volume - Cleanup artifacts"

exit /b


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	The process of installing software 
::--	should now install the disired software packages.
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
;;--
::-----------------------------------------------------------------------------
:ArtifactCleanup
  cls
  echo.
  echo.
  echo		Install Software Process - Artifact Cleanup
  echo				(%~1)
  echo.
  echo.
  echo	  The process of installing software adds "artifacts" to the
  echo	  image, like important program files required to successfully
  echo	  execute the application.  However, some artifacts are 
  echo	  superfluous and should be culled once an install completes.
  echo	  For example, certain installs will create a temporary
  echo	  directory within the root of the install drive to unpack
  echo	  the program files before installing them in an appropriate
  echo	  directory.
  echo.
  echo    The steps outlined below will guide you through the process
  echo	  of removing superfluous artifacts 
  echo.  
  echo	  1.  Unwanted OS registry entries that automatically execute
  echo	      unneccessary application components.  For example, a 
  echo	      system tray application, that essentially continually
  echo	      "advertises" its application. 
  echo.
  echo	  2.  A "temporary" install directory that's not properly
  echo	      removed after the install finishes.
  echo.
  echo	  3.  Removal of other temporary files, such as downloaded
  echo	      web page resources created while websurfing and 

  call :PromptContinue "Install Software for '%~1' volume - Cleanup artifacts"

exit /b

:BaseImageUpdate:





Cleanup
schtasks /Query 
[/S system [/U username [/P [password]]]]
[/FO format | /XML] [/NH] [/V] [/TN taskname] [/?]



:InstallImageBackup:

  call :ImageBackup
  if errorlevel 1 call :Abort "Software Install to:'%~1' during step: '%~2-Image Backup' terminated by user request." & exit /b 1

  call :StartupContinue InstallComplete %USER_ACCOUNT_NOTIFY_LIST%
  if errorlevel 1 ( call :Abort "Could not alter startup process for users to:'%VOLUME_LABEL_TO_REVERT%' missing:'%IMAGE_BASE_UPDATE_CMD%'."

  call %IMAGE_BACKUP_CMD%
  if errorlevel 1 ( call :StartupContinueRollback InstallImageBackup %USER_ACCOUNT_NOTIFY_LIST%
    cls
    echo.
    echo.
    echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
    echo.
    echo.
    pause
    exit /b 1
  )

exit /b 0
   

:InstallImageBackupSuccess:
  ::-- Reset the scripts that are executed when the user logs on
  call :StartupContinueRollback %USER_ACCOUNT_NOTIFY_LIST%
  ::-- Inform the user that we're done with the entire install process
  cls
  echo.
  echo.
  echo			Install Software Process - Completed!
  echo				(%~1)
  echo.
  echo.
  echo	  The image has been successfully saved as a backup file! 
  echo	  All the installation steps have been successfully executed.
  echo.
  echo.

  pause

exit /b 0


:InstallImageBackupFailure:
  cls
  echo.
  echo.
  echo		Install Software Process - Backup Failure.
  echo				(%~1)
  echo.
  echo.
  echo	  Although the image has been updated, an attempt to create a backup
  echo	  of this image failed.  Review the log file found here: successfully Backed up!  All the 
  echo	  installation steps have been successfully executed.
  echo.
  echo.

  pause

  ::-- Reset the scripts that are executed when the user logs on
  call :StartupContinueRollback %USER_ACCOUNT_NOTIFY_LIST%
  if errorlevel 1 (
    call :ErrorUnexpected "Unexpected problem when attempting to rollback startup after a backup failure"
    exit /b 1
  )
exit /b


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	To notify accounts lacking administrator privileges that they should
::--	continued the software installation process using an account that
::--	has administrative privileges.
::--
::--  Assumes:
::--    1.  A file named: "OnUserLogon<StepToRestart><AccountName>.cmd"
::--	    exists in the directory of: %STARTUP_BIND%.
::--	2.  An automated task named "OnUserLogon<AccountName>" has been
::--	    created using the account's privledges and will execute the
::--	    file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd" when
::--	    the user first logs on.
::--    3.  That the account executing this script has the authority
::--	    to read the file: "%STARTUP_BIND%\OnUserLogon<StepToRestart><AccountName>.cmd"
::--    4.  That the account executing this script has the authority
::--	    to overwrite the file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd"
::--
::--  Input:
::--    1.  %1 - The volume name of the image that's the target of the install.
::--	2.  %2 - The administrator's account name.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Successfully displayed message.
;;--
::-----------------------------------------------------------------------------
:InstallContinueAsAdmin:
  cls
  echo.
  echo.
  echo		Install Software Process - Continue As Admin
  echo				(%~1)
  echo.
  echo.
  echo	  A software install was initiated but is not yet complete.
  echo	  Please log off this account and log in as '%~2' to continue
  echo	  this process.
  echo.
  echo.

  pause

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	To notify one or more users of an ongoing install that's being
::--	continued across reboots.  The notifications are issued when
::--	the user logs on to his account.
::--
::--  Assumes:
::--    1.  A file named: "OnUserLogon<StepToRestart><AccountName>.cmd"
::--	    exists in the directory of: %STARTUP_BIND%.
::--	2.  An automated task named "OnUserLogon<AccountName>" has been
::--	    created using the account's privledges and will execute the
::--	    file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd" when
::--	    the user first logs on.
::--    3.  That the account executing this script has the authority
::--	    to read the file: "%STARTUP_BIND%\OnUserLogon<StepToRestart><AccountName>.cmd"
::--    4.  That the account executing this script has the authority
::--	    to overwrite the file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd"
::--
::--  Input:
::--    1.  %1 - The name of a function internal to this one that 
::--		 resumes the install process at its next step - <StepToRestart> 
::--	2.  %2 - Volume name 
::--    3.  %3 - The first account name in a list of names that will receive 
::--	.	 a notification message on log on - <AccountName>.
::--	.
::--	.
::--	N
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Notifications have been successfully configured.
::--		1: Failure.
;;--
::-----------------------------------------------------------------------------
:StartupContinueAdmin:
  setlocal
  
  if "%~1"=="" call :Abort "Specify the script name that must be executed by the other managing volume to continue this process." & exit /b 1
  if "%2" =="" call :Abort "Specify the successful restarting step label defined in this batch file." & exit /b 1
  if "%3" =="" call :Abort "Specify the failure restarting step label defined in this batch file." & exit /b 1
  if "%~4"=="" call :Abort "Specify the volume name that initiated and will continue the process." & exit /b 1
  if "%~5"=="" call :Abort "Specify the administrative account name responsible for executing the install." & exit /b 1
  if "%~6"=="" call :Abort "Specify the Transaction identifier to help identify all the tasks that compose this aggregate one." & exit /b 1

  ::-- 
  if not exist "%STARTUP_BIND%\%~1" call :Abort "Continuation script:'%STARTUP_BIND%\%~1'does not exist." & exit /b 1
  ::--
  set PROCESS_CONFIG_FILE="%STARTUP_BIND%\%~n1.config.cmd"
  echo set NEXT_STEP_SUCCESS=%2>%PROCESS_CONFIG_FILE%
  echo set NEXT_STEP_FAILURE=%3>>%PROCESS_CONFIG_FILE%
  echo set NHN.TRANSACTION_ID=%NHN.TRANSACTION_ID%>>%PROCESS_CONFIG_FILE%
  echo exit /b 0>>%PROCESS_CONFIG_FILE%

  if not exist %PROCESS_CONFIG_FILE% call :Abort "Configuration script:'" %PROCESS_CONFIG_FILE% "' for script:'%STARTUP_BIND%\%~1' could not be created." & exit /b 1


    if "%~3"=="" exit /B %ERROR_LVL%
    ::-- determine if startup notify code was defined for specified account
    set STARTUP_NOTIFY=%STARTUP_BIND%\OnUserLogon%~1%~2%~3.cmd  
    if not exist "%STARTUP_NOTIFY%" ( call :Abort "File:'%STARTUP_NOTIFY%' missing. Create it and encode the appropriate notification behavior."
      set ERROR_LVL=1
    ) else type "%STARTUP_NOTIFY%">"%STARTUP_BIND%\OnUserLogon%~3.cmd" || call :Abort "Unable to overlay:"%STARTUP_BIND%\OnUserLogon%~3.cmd" with file:'%STARTUP_NOTIFY%'." & set ERROR_LVL=1
    ::-- obtain next account name.
    shift /2 1


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	To notify one or more users of an ongoing install that's being
::--	continued across reboots.  The notifications are issued when
::--	the user logs on to his account.
::--
::--  Assumes:
::--    1.  A file named: "OnUserLogon<StepToRestart><AccountName>.cmd"
::--	    exists in the directory of: %STARTUP_BIND%.
::--	2.  An automated task named "OnUserLogon<AccountName>" has been
::--	    created using the account's privledges and will execute the
::--	    file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd" when
::--	    the user first logs on.
::--    3.  That the account executing this script has the authority
::--	    to read the file: "%STARTUP_BIND%\OnUserLogon<StepToRestart><AccountName>.cmd"
::--    4.  That the account executing this script has the authority
::--	    to overwrite the file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd"
::--
::--  Input:
::--    1.  %1 - The name of a function internal to this one that 
::--		 resumes the install process at its next step - <StepToRestart> 
::--	2.  %2 - Volume name 
::--    3.  %3 - The first account name in a list of names that will receive 
::--	.	 a notification message on log on - <AccountName>.
::--	.
::--	.
::--	N
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Notifications have been successfully configured.
::--		1: Failure.
;;--
::-----------------------------------------------------------------------------
:StartupContinue:
  setlocal
  
  if "%~1"=="" call :Abort "Specify the restarting step label defined in this batch file" & exit /b 1
  if "%~2"=="" call :Abort "Specify the volume name that initiated and will continue the process" & exit /b 1
  if "%~3"=="" call :Abort "Specify at least one account name that will receive a continuation message." & exit /b 1

  set ERROR_LVL=0
  :StartupContinueNext:
    ::-- return overall error code
    if "%~3"=="" exit /B %ERROR_LVL%
    ::-- determine if startup notify code was defined for specified account
    set STARTUP_NOTIFY=%STARTUP_BIND%\OnUserLogon%~1%~2%~3.cmd  
    if not exist "%STARTUP_NOTIFY%" ( call :Abort "File:'%STARTUP_NOTIFY%' missing. Create it and encode the appropriate notification behavior."
      set ERROR_LVL=1
    ) else type "%STARTUP_NOTIFY%">"%STARTUP_BIND%\OnUserLogon%~3.cmd" || call :Abort "Unable to overlay:"%STARTUP_BIND%\OnUserLogon%~3.cmd" with file:'%STARTUP_NOTIFY%'." & set ERROR_LVL=1
    ::-- obtain next account name.
    shift /2 1

goto StartupContinueNext


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	To nullify the changes applied by the :StartupContinue: function.
::--	This routine resets a user's log on task to do nothing.
::--
::--  Assumes:
::--	1.  An automated task named "OnUserLogon<AccountName>" has been
::--	    created using the account's privledges and will execute the
::--	    file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd" when
::--	    the user first logs on.
::--    3.  That the account executing this script has the authority
::--	    to read the file: "%STARTUP_BIND%\OnUserLogon<StepToRestart><AccountName>.cmd"
::--    4.  That the account executing this script has the authority
::--	    to overwrite the file: "%STARTUP_BIND%\OnUserLogon<AccountName>.cmd"
::--
::--  Input:
::--    1.  %1 - The first account name in a list of names whose automated 
::--	.	 log on task will be nullified.
::--	.
::--	.
::--	N
::--
::--  Output:
::--    1.  errorlevel:
::--		0: Notifications have been successfully nullified.
::--		1: Failure.
;;--
::-----------------------------------------------------------------------------
:StartupContinueRollback:
  setlocal
  
  if "%~1"=="" call :Abort "Specify at least one account name that requires rolling back its continuation process." & exit /b 1

  set ERROR_LVL=0
  :StartupContinueRollbackNext:
    ::-- return overall error code
    if "%~1"=="" exit /B %ERROR_LVL%
    echo exit /b 0 >"%STARTUP_BIND%\OnUserLogon%~1.cmd" || call :Abort "Unable to reset:'%STARTUP_BIND%\OnUserLogon%~1.cmd' with exit /b 0." & set ERROR_LVL=1
    ::-- obtain next account name.
    shift /1 1

goto StartupContinueRollbackNext




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
;;--
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
    exit /b 1
  )
exit /b 0



:InstallTerminatedUserRollback:

  call Abort "Software Install to:'%~1' during step: '%~2' terminated by user request."

  call :StartupContinueRollback %USER_ACCOUNT_NOTIFY_LIST%

  call :StartupContinueRollback %3

exit /b 1



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
;;--
::-----------------------------------------------------------------------------
:ErrorUnexpected:
   
  call :StartupContinueRollback %USER_ACCOUNT_NOTIFY_LIST%
  call :Abort "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  cls
  echo.
  echo.
  echo  Unexpected error encountered - log file contains details:'" %LOGGER_CONFIG_FILE% "'"
  echo.
  echo.
  pause

exit /b 1


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0