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
::-- values that are made available to the process that actually performs the task.
set TASK_CREATE_NAME=TaskRequesTest.cmd
::
::-- Optional: An absolute file path name, without double quotes, to a file containing
::-- associated values.  An item in the list has the
::-- format: ^<EnvironmentVariableName^>=^<Value^> .  This list is appended to the
::-- contents of the newly created TASK_CREATE_NAME.  Use this method of providing
::-- dynamic context (passing dynamic arguments) to the process running the task.  For
::-- example, one can pass the dynamically assigned transaction GUID to the process that
::-- actually performs the task, as a means of maintaining continuity between the
::-- the currently process, that's making a request, to the one that performs it.
::-- Use the value of "STDIN" to "pipe" the list of environment variables to
::-- this create function.
set TASK_CREATE_BODY_FILE=STDIN
