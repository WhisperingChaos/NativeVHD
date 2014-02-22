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
  echo ::--	Given a child/derived differencing VHD related to a bootable parent VHD,>&2
  echo ::--	delete this child VHD, intentionally destroying its contents, then create>&2
  echo ::--	a new child VHD for this parent.  This new child removes any unintentional>&2
  echo ::--	changes and will protect the parent from tampering.  After>&2
  echo ::--	succesful generation of the new child VHD, a boot manager entry is generated>&2
  echo ::--	for it by adding this entry to a boot manager template (see configuration>&2
  echo ::--	file settings below).  This new entry becomes the default boot OS.  Therefore,>&2
  echo ::--	the next boot cycle will cause the machine to start up the OS image inherited>&2
  echo ::--	by the new child VHD.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--	1.  Relies on Windows BCDedit, DiskPart and Native Boot features of Windows 7 and above.>&2
  echo ::--	2.  Executing script with Administrator privileges.>&2
  echo ::--	3.  Child VHD's parent is a viable Windows 7 or Windows 8 OS.>&2
  echo ::--	4.  The OS has been installed to the "\Windows" directory of the parent VHD.>&2
  echo ::--	5.  Chages are applied to the default boot manager instance.>&2
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  ^%1: Either:>&2
  echo ::--		 	The full path name to a configuration file conatining>&2
  echo ::--		 	argument values.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  A new child VHD.>&2
  echo ::--	2.  A new boot manager instance that replaced the default boot manager instance,>&2
  echo ::--	    with a new entry to boot the child VHD's image, as the new default boot OS.>&2
  echo ::--	3.  errorlevel:>&2
  echo ::--		0: Either:>&2
  echo ::--			Successful execution of "/?">&2
  echo ::--			Reset was successful>&2
  echo ::--		1: Failure>&2
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
  echo ::-- The absolute path, enclosed in double quotes, to the differencing (a.k.a. - child/derived) VHD >&2
  echo ::-- To be deleted and then recreated to revert the image back to its>&2
  echo ::-- last known state and then protect it moving forward from>&2
  echo ::-- changes either unintentional or malicious.>&2
  echo set NATIVE_BOOT_DERIVED_FILE="<DerivedVHDAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the base (a.k.a. - parent) VHD. >&2
  echo ::-- This VHD contains the application and OS programs that are essential >&2
  echo ::-- to delivering the services required by role assumed by a person using this image.>&2
  echo ::-- For example, a BU student needs MS Office and Google docs to function at BU.>&2
  echo ::-- Therefore, you would not see games or other exotic software included in the perminant image.>&2
  echo set NATIVE_BOOT_BASE_FILE="<DerivedVHDAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The windows Volume (drive label name) assigned to the VHD.  Should reflect the role name of the>&2
  echo ::-- person using this image.  The label name must not contain spaces.>&2
  echo set NATIVE_BOOT_VOL_NAME=^<VolumeLabelOfVHD^>>&2
  echo ::>&2
  echo ::-- The boot entry description name that will be assigned to the newly created derived VHD.>&2
  echo ::-- This name appears on the boot menu, and will become the default volume selected to boot,>&2
  echo ::-- if not manually changed during the boot process.>&2
  echo set NATIVE_BOOT_LOADER_NAME=^<BCDbootEntryDescription^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to a previously saved boot manager instance ^(a.k.a. template^)>&2
  echo ::-- containing the boot entries you wish to also potentially access when booting using this boot choice.>&2
  echo ::-- Use "BCDedit /export" to create this template>&2
  echo set NATIVE_BOOT_BOOT_MANAGER_TEMPLATE="<BCDbootManagerTemplateAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo exit /b 0 >&2
exit /b


:Main:
  setlocal

  if "%~1"==""       call :Abort "Please specify configuration file as first and only parameter.  Example follows:" & call :Help & exit /b 1
  if "%~1"=="/?"     call :Help & exit /b 0
  if not exist "%~1" call :Abort "Unable to locate provided configuration file: '%~1'.  Example follows:" & call :Help & exit /b 1
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file '%~1'" & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY NATIVE_BOOT_DERIVED_FILE NATIVE_BOOT_BASE_FILE NATIVE_BOOT_VOL_NAME NATIVE_BOOT_LOADER_NAME NATIVE_BOOT_BOOT_MANAGER_TEMPLATE LOGGER_BIND LOGGER_CONFIG_FILE GUID_BIND
  if errorlevel 1 (
     call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
     call :Abort "Please correct errors in configuration file '%~1'"
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
     if errorlevel 1 call :Abort "Generation of unique Transaction Id failed" & exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Starting: Derived VHD:'" %NATIVE_BOOT_DERIVED_FILE% "' Reset"

  ::-- Delete the current derived VHD differencing disk
  call :VHDdelete %NATIVE_BOOT_DERIVED_FILE%
  if errorlevel 1 call :Abort "Could not delete derived child VHD: '" %NATIVE_BOOT_DERIVED_FILE% "'"  & exit /b 1

  ::-- Create derived file and associate it to base one
  call :VHDchildCreate %NATIVE_BOOT_DERIVED_FILE% %NATIVE_BOOT_BASE_FILE%
  if errorlevel 1 call :Abort "Create of child VHD:'" %NATIVE_BOOT_DERIVED_FILE% "' failed." & exit /b 1

  ::-- Determine the drive letter assigned to the child VHD
  call :VolumeDriveGet %NATIVE_BOOT_VOL_NAME% DISKPART_RESET_CHILD_DRIVE
  if errorlevel 1 call :Abort "Could not identify or assign volume drive letter for child VHD:'" %NATIVE_BOOT_DERIVED_FILE% "'" & exit /b 1

  ::-- Repair the boot manager so it correctly references new child VHD
  call :BootRepair %DISKPART_RESET_CHILD_DRIVE% %NATIVE_BOOT_LOADER_NAME% %NATIVE_BOOT_BOOT_MANAGER_TEMPLATE%
  if errorlevel 1 call :Abort "Failed to create a boot entry for: '%DISKPART_RESET_CHILD_DRIVE%:\windows'" & exit /b 1

  ::-- reset success!
  call :Inform "Ended: Derived VHD:'" %NATIVE_BOOT_DERIVED_FILE% "' Reset: Successful"

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Delete the specified VHD volume.
::--
::--  Assumes:
::--    1.  No linkages maintained by parent that refer to the child.
::--    2.  The failure of a simple "del" suggest that the derived file
::--	    might be mounted.
::--
::--  Input:
::--    1.  %1 - The fullpathname, potentially enclosed in double quotes,
::--		 to the derived file that must be removed.
::--
::--  Output:
::--    1.  errorlevel:
::--		0: successfully deleted the derived VHD
::--		1: failed 
;;--
::-----------------------------------------------------------------------------
:VHDdelete:
  setlocal
  ::-- attempt just a simple delete
  del %1 >nul
  if not exist %1 exit /b 0

  ::-- simple delete failed try to unmount
  set DISKPART_CMD_FILE="%TEMP%\%~nx0.%RANDOM%.txt"
  echo select vdisk file="%~1" > %DISKPART_CMD_FILE%
  echo detach vdisk >> %DISKPART_CMD_FILE%
  if not exist %DISKPART_CMD_FILE% call :Abort "Could not create required Diskpart Command file named: '" %DISKPART_CMD_FILE% "'" & exit /b 1
  ::-- call diskpart to detach (unmount) derived volume
  diskpart /s %DISKPART_CMD_FILE% >nul
  if not errorlevel 0 call :Abort "Diskpart failed attempting to detach: '%~1' using command file named: '" %DISKPART_CMD_FILE% "'" & exit /b 1

  ::-- second attempt to delete the VHD.
  del %1 >nul
  if exist %1 call :Abort "Unable to remove derived volume: '%~1' even after successful detach. Check permissions." & exit /b 1

  ::-- cleanup temporary command file
  del %DISKPART_CMD_FILE% >nul

  ::-- successful in removing derived volume.
exit /b 0

 
::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Create a new child VHD differencing disk for the provided parent VHD.
::--
::--  Assumes:
::--	1.  Administrator privileges, required by diskpart
::--
::--  Input:
::--    1.  %1 - The fullpathname of the child VHD to be created.
::--    2.  %2 - The fullpathname of the parent VHD for the provided child.
::--
::--  Output:
::--    1.  When successful, a child VHD that fully reflects its parent's
::--	    content.
::--    2.  errorlevel:
::--		0: successfully created the child (derived) VHD
::--		1: failed 
;;--
::-----------------------------------------------------------------------------
:VHDchildCreate
  setlocal
  ::-- create temporary diskpart script to add the child differencing disk
  set DISKPART_CMD_FILE="%TEMP%\%~nx0.%RANDOM%.txt"
  echo CREATE VDISK FILE="%~1" PARENT="%~2" > %DISKPART_CMD_FILE%
  echo select vdisk file="%~1" >> %DISKPART_CMD_FILE%
  echo attach vdisk >> %DISKPART_CMD_FILE%
  ::-- Ensure command file exists  
  if not exist %DISKPART_CMD_FILE% call :Abort "Could not create required Diskpart Command file named:'" %DISKPART_CMD_FILE% "'" & exit /b

  ::-- call diskpart to create the new derived image for the given parent.
  diskpart /s %DISKPART_CMD_FILE% >nul
  if not errorlevel 0 exit /b 1

  ::-- cleanup temporary command file
  del %DISKPART_CMD_FILE%>nul

  ::-- successful in creating child VHD and associating it to its parent.
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Returns the drive letter that has been assigned to a mounted volume
::--	given the name of the volume.
::--
::--
::--  Assumes:
::--	1.  Administrator privileges, required by diskpart
::--	2.  The VHD has already been been attached (mounted)
::--	3.  The volume name uniquely identifies the desired volume in the current list.
::--	4.  The volume name must not contain whitespace characters, like a space.  
::--
::--  Input:
::--    1.  %1 - The volume name assigned to the desired volume.
::--    2.  %2 - The name of an environment variable to contain the found drive letter.
::--
::--  Output:
::--    1.  When successful, the provided environment variable will reflect the 
::--	    drive letter value assigned to the desired volume :: the volume will
::--	    be or continue to be mounted/attached.
::--    2.  errorlevel:
::--		0: successfully retrieved drive letter.
::--		1: failed 
;;--
::-----------------------------------------------------------------------------
:VolumeDriveGet
  setlocal
  set /a DISKPART_TRY_CNT=0
  ::-- create temporary diskpart script to list volumes and their properties.
  set DISKPART_CMD_FILE="%TEMP%\%~nx0.%RANDOM%.txt"

  :VolumeDriveGetTryAgain:
  ::-- pause/delay the script for 2 seconds in order for volume list to contain a potentially
  ::-- newly attached volume.
  ping 192.0.2.2 -n 1 -w 2000 > nul
  ::-- generate current volume list
  echo list volume > %DISKPART_CMD_FILE%
  ::-- search volume list for desired volume name 
  set VOLUME_DRIVE=
  ::-- for parsing assumes that the volume name does not include spaces
  for /F "tokens=1,2,3,4" %%i in ('diskpart /s %DISKPART_CMD_FILE%') do call :DriveLetterSearch %1 VOLUME_DRIVE %%i %%j "%%k" "%%l" || goto VolumeDriveCase
  ::-- case statement for return code of :DriveLetterGet routine
  :VolumeDriveCase:
  goto VolumeDrive%errorlevel% || call :Abort "Unexpected return value:'%errorlevel%'" & exit /b 1

    :VolumeDrive0:
      call :Abort "Diskpart could not find volume named:'%~1'"
      exit /b 1

    :VolumeDrive1: -- volume not assigned a drive letter do so manually.
      echo select volume=%VOLUME_DRIVE% > %DISKPART_CMD_FILE%
      echo assign >> %DISKPART_CMD_FILE%
      diskpart /s %DISKPART_CMD_FILE% >nul
      if not errorlevel 0 call :Abort "Diskpart failed to assign drive letter to volume:'%~1' number:'%VOLUME_DRIVE%'"  & exit /b 1
      if "%DISKPART_TRY_CNT%"=="0" set /a DISKPART_TRY_CNT+=1 & goto VolumeDriveGetTryAgain
      call :Abort "Diskpart failed to assign drive letter to volume:'%~1' number:'%VOLUME_DRIVE%' Perhaps exhausted drive letters."
      exit /b 1

    :VolumeDrive2: -- drive letter found
      ::-- cleanup temporary command file
      del %DISKPART_CMD_FILE%>nul
      endlocal & set %2=%VOLUME_DRIVE%

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Identify the drive letter assigned to the desired volume.  If volume hasn't
::--	been assigned a drive letter, then return the volume number.
::--
::--  Input:
::--	1.  %1 - Desired Volume name to find, potentially enclosed in double quotes.
::--	2.  %2 - Name of an environment variable to receive either the drive letter
::--		 or the drive number.
::--	3.  %3 - Search for keyword "Volume"
::--	4.  %4 - Volume number
::--    5.  %5 - Drive letter or volume name
::--    6.  %6 - Volume name or garbage
::--
::--  Output:
::--	1.  DISKPART_RESET_CHILD_DRIVE:
::--		When errorlevel 1, contains drive letter
::--		when errorlevel 2, contains volume number
::--		otherwise, anything or nothing
::--    2.  errorlevel:
::--		0 - continue searching
::--		1 - volume number found
::--		2 - volume drive found
;;--
::-----------------------------------------------------------------------------
:DriveLetterSearch:
  ::--  Bypass and parse only the volume info
  if /i not "%3"=="Volume" exit /b 0
  ::--  Is only the drive number available?
  if /i "%~5"=="%~1" set %2=%4 & exit /b 1
  ::--  Is the drive letter available?
  if /i "%~6"=="%~1" set %2=%5 & exit /b2
  ::--  didn't find the name volume - keep searching
exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Repair the boot menu by addng a boot entry for the Bootable
::--    windows volume identified by the provided drive.  "Adding" in this 
::--    case overlays the boot manager file with a saved version
::--    (called a template) and then adding an entry to it.  The new entry
::--    will become the new default boot volume.
::--
::--  Assumes:
::--    1.  A saved boot manager file (template) that contains any other
::--	    desired boot entry besides the one being added.
::--    2.  The template file is stored in a directory subordinate to the
::--	    one containing the executing script.
::--    3.  The Windows boot files are to be found/created in "\Windows"
::--	    directory of the privided drive letter.
::--    4.  Successful completion will establish the new boot entry as the
::--	    the "{default}" one. So when the machine is rebooted, this entry
::--	    will automatically be selected as the volume to boot, unless 
::--	    manually circumvented. 
::--    5.  Failure will result in restore of boot manager to it's state
::--	    immediately before the execution of this function.
::--
::--  Input:
::--	1.  %1 - The drive letter of the volume being added to the boot menu.
::--             Only the letter - ex: "C"
::--    2.  %2 - Boot description - used to uniquely identify boot entry.
::--             Enclosed in double quotes when containing spaces.
::--    3.  %3 - Absolute boot directory path & file name to template file.
::--
::--  Output:
::--	1.  An updated BCD boot manager file located in primary boot parition
::--	    containing the templated entries and the newly added one. 
::--    2.  errorlevel -
::--		0 - successfully created boot entry.
::--		1 - failed 
;;--
::-----------------------------------------------------------------------------
:BootRepair:
  setlocal

  if "%~1" == ""               call :Abort "Specify volume drive as first argument" & exit /b
  if not exist "%~1:\Windows\" call :Abort "Windows System directory does not exist at this location:'%~1:\Windows'" & exit /b
  if "%~2"==""                 call :Abort "Required boot description text was not specified" & exit /b
  if not exist "%~3"           call :Abort "Could not find boot manager template file:'%~3'" & exit /b

  set BOOT.REPAIR.BACKUP.FILE=%TEMP%\BootManagerBackup.%RANDOM%
  set BOOT.REPAIR.BACKUP.TEMPLATE=%~3

  ::-- Create backup of current boot manager state in order to rollback during an abort
  bcdedit /export "%BOOT.REPAIR.BACKUP.FILE%" >nul
  if errorlevel 1 call :Abort "Boot manager backup to file:'%BOOT.REPAIR.BACKUP.FILE%' failed" & exit /b

  ::-- Import the apppropriate template file.
  bcdedit /import "%BOOT.REPAIR.BACKUP.TEMPLATE%" >nul
  if errorlevel 1 call :BootRepairRollback "BCDedit import of template file failed. File:'%BOOT.REPAIR.BACKUP.TEMPLATE%'" & exit /b

  ::--  Establish boot manager entry for specified volume.
  bcdboot "%~1:\Windows" >nul
  if errorlevel 1 call :BootRepairRollback "BCDboot failed to generate boot entry for volume: '%~1:\Windows'" & exit /b

  ::--  BCDboot establishes the new entry as the {default} boot entry.  {default} uniquely identifies this boot entry.
  ::--  Now update the boot entry's description.
  bcdedit /set {default} description "%~2" >nul
  if errorlevel 1 call :BootRepairRollback "BCDedit failed to update {default} entry's description field to: '%~2'" & exit /b

  ::-- successfully updated boot manager with customized template.  Remove the backup.
  del "%BOOT.REPAIR.BACKUP.FILE%" >nul
  ::-- Specify '*' in file name to remove all the hidden backup files, as more than one can be created.
  del /Q /F /AH "%BOOT.REPAIR.BACKUP.FILE%*" >nul


exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Restore backup copy of boot manager, that was created immediately before
::--	the attempt to add an entry to the boot manager template file,
::--	due to some problem encountered by the attempted add. 
::--
::--  Input:
::--	1.  %1 - An error message detailing the reason for the rollaback.
::--    2.  BOOT.REPAIR.BACKUP.FILE - An environment variable containing an
::--	    absolute filename to a boot manager backup created by a BCDedit
::--	    /export executed immediately before an attempt to change it.
::--	    The value of this environment variable is not enclosed in double quotes.
::--
::--  Output:
::--	1.  When successful BCDedit import, a reverted boot manager file
::--	    located in primary boot parition.
::--    2.  errorlevel:
::--		1 - Continue signaling error 
;;--
::-----------------------------------------------------------------------------
:BootRepairRollback:

  call :Abort %1
  bcdedit /import "%BOOT.REPAIR.BACKUP.FILE%" >nul
  if errorlevel 1 call :Abort "Attempted restore of boot manager failed.  Boot manager maybe corrupted and require Windows Repair process.  Boot Manager backup file name: '%BOOT.REPAIR.BACKUP.FILE%'"
  
exit /b 1


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0