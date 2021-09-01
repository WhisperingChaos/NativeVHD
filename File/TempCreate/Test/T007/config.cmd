::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: Specifies either a environment variable to receive the newly created
::-- temporary file.
set FILE_TEMP_CREATE_ABSOLUTE_FILEPATH_OUT=TEST_TEMP_FILEPATH
::
::-- Required: The absolute path, absent double quotes, to an existing directory that
::-- will contain the temporary file.  Default specified by Windows TEMP environment
::-- variable.  
set FILE_TEMP_CREATE_PATH=%TEMP%
::
::-- Optional: An optional prefix applied to tempfile name.  
set FILE_TEMP_CREATE_PREFIX=Prefix
::
::-- Optional: An optional suffix applied to tempfile name.  A suffix may
::-- include a file extension.
set FILE_TEMP_CREATE_SUFFIX=Suffix
::
