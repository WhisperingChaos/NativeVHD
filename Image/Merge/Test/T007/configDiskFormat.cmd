::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%BIND_ARGUMENT%
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being formatted.
set DISK_FORMAT_FILE=%TEST_VHD_FILE%
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- dispart executor.
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"
::
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%VDISK_METHOD_PATH%\DiskFormat\Subroutine\diskpartCmdGen.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%VDISK_METHOD_PATH%\DiskFormat\Subroutine\diskpartVerify.cmd
