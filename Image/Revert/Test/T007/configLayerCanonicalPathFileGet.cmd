::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, enclosed in double quotes, to the differencing
::-- (a.k.a. - child/derived) VHD of the desired immediate parent.
set LAYER_CANONICAL_LAYER_FILE=%TEST_LAYER_VHD_FILE%
::
::-- Required: The name of an environment variable to hold the canonical path of
::-- the immediate base VHD for the layer specified by LAYER_CANONICAL_LAYER_FILE.
::-- If the layer has a base, the provided variable will reflect that value.
::-- Otherwise, the provided variable's value will remain untouched.
set LAYER_CANONICAL_OUTPUT_PARENT_FILE=TEST_CANONICAL_PARENT_NAME
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- dispart executor.
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"
::
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%~dp0\..\..\..\Vdisk\Subroutine\diskpartCmdGen.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%~dp0\..\..\..\Vdisk\Subroutine\diskpartVerify.cmd