::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, without double quotes, to the shared process directory
::-- that should be scanned for command names.
set TASK_FETCH_SHARED_SCAN_DIR=%~dp0\ScanDirExist
::
::-- Required: The absolute path, without double quotes, to the command implementation
::-- directory that's private to this process.
set TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR=%~dp0\FetchImplementationDirNotExist
::