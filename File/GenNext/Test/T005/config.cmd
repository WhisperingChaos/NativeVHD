::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument

::-- Required: The absolute path, enclosed in double quotes, to the file whose
::-- name will include a  layer being reverted.>&2
set GENERATIONAL_FILE_NAME="%~dp0\original_file.txt"