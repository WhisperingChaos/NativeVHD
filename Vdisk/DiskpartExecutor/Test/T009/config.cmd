::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- The absolute path, without double quotes, to a command that generates a
::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
::-- commands as strings to SYSOUT.
set DISKPART_CMD_GENERATOR=%~dp0\GoodCommand.cmd
::
::-- The absolute path, without double quotes, to a command that verifies diskpart's
::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
::-- environment variables that it sets before calling %~f0 to implement the Checker.
::-- A return value by the checker other than 0 signifies an error.
set DISKPART_CONSTRAINT_CHECK=%~dp0\GoodCheck.cmd
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=%~dp0\..\..\..\..\Logger
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger.
set LOGGER_CONFIG_FILE="%~f0"
::
::-- The absolute path, enclosed in double quotes, to a file designated
::-- as a log.
set LOG_FILE="%~dp0\log.txt"