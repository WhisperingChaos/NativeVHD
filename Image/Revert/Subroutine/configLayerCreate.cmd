::-- The absolute path, enclosed in double quotes, to the pre-existing base/parent VHD.
set BASE_LAYER_FILE=%BASE_LAYER_FILE%
::
::-- The absolute path, enclosed in double quotes, to the Layered VHD being created.
set DERIVED_LAYER_FILE=%DERIVED_LAYER_FILE%
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- dispart executor.
::
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%VDISK_METHOD_BIND%\LayerCreate\subroutine\diskpartCmdGen.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%VDISK_METHOD_BIND%\LayerCreate\subroutine\diskpartVerify.cmd