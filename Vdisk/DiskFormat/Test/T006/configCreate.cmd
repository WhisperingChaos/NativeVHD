::
::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the Q:\Vdisk\BaseCreate.cmd script.
::-- This script is called from the same command processor as the Q:\Vdisk\BaseCreate.cmd script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %TEMP% variable, and it will refer to the same one visible to the 
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::
::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0..\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the VHD being created.
set BASE_LAYER_FILE=%TEST_VHD_FILE%
::
::-- The layer's size in MegaBytes (MB).
set BASE_LAYER_SIZE=10
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- dispart executor.
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"
::
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%~dp0..\..\..\..\Vdisk\BaseCreate\Subroutine\diskpartCmdGen.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%~dp0..\..\..\..\Vdisk\BaseCreate\Subroutine\diskpartVerify.cmd
::
exit /b 0 
