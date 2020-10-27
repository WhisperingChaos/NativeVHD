  ::-- Required: The absolute path, without double quotes, to the Argument methods.
  set BIND_ARGUMENT=%BIND_ARGUMENT%
  ::
  ::-- Required: The absolute path, without double quotes, to a command that generates a
  ::-- cohesive set of diskpart commands.  Generator takes no arguments and produces
  ::-- commands as strings to SYSOUT.
  set DISKPART_CMD_GENERATOR=%~dp0\diskpartCmdGen.cmd
  ::
  ::-- Required: The absolute path, without double quotes, to a command that verifies diskpart's
  ::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping
  ::-- environment variables that it sets before calling %~f0 to implement the Checker.
  ::-- A return value by the checker other than 0 signifies an error.
  set DISKPART_CONSTRAINT_CHECK=%~dp0\diskpartVerify.cmd
  ::
  ::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.
  set LOGGER_BIND=%LOGGER_BIND%
  ::
  ::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the
  ::-- logger.
  set LOGGER_CONFIG_FILE=%LOGGER_CONFIG_FILE%
  ::
  ::-- Optional: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  set GUID_BIND=%GUID_BIND%
  ::