::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, without double quotes, to the shared process directory.
::-- This should be identical to the path specified by a corresponding instance
::-- of the Task "Fetch" method.
set TASK_CREATE_SHARED_REQUEST_DIR=%~dp0\SharedRequestDir
::
::-- Required: A filename, whose type refers to an executable, that maps to a
::-- requested task performed by another process.  Although the file type suggests
::-- an executable, the contents of this file doesn't contain "executable" code.
::-- Instead, it defines a list of batch environment variable names paired with their::
::-- values that are made available to the process that actually performs the task.  ::-- Required: The absolute path, without double quotes, to the command implementation
set TASK_CREATE_NAME=TaskRequesTest.cmd
