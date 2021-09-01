::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::-- Required: Specifies either a environment variable to receive the newly created
::-- temporary file or "STDOUT".  "STDOUT" writes to standard console output.
::-- Returned absolute path file name is not encapsulated in quotes.  
set FILE_TEMP_CREATE_ABSOLUTE_FILEPATH_OUT=STDOUT
::
::-- Required: The absolute path, absent double quotes, to an existing directory that
::-- will contain the temporary file.  Default specified by Windows TEMP environment
::-- variable.  
set FILE_TEMP_CREATE_PATH=%TEMP%\ShouldNotExist\ShouldNotExist
::
