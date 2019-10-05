::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being mounted.
set MOUNT_VDISK_FILE=%DELETE_VDISK_FILE%
::
::-- Required: The drive letter (only - no colon ':') to assign the mounted VHD.
set MOUNT_VDISK_DRIVE_LETTER=%DELETE_VDISK_MOUNT_DRIVE%
::
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%~dp0\..\..\..\Mount\Subroutine\diskpartCmdGen.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%~dp0\..\..\..\Mount\Subroutine\diskpartverify.cmd