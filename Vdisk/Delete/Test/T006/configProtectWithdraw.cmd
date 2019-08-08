::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- The absolute filepath, enclosed in double quotes, to a preexisting VHD.
::-- whose read only attribute will be enabled to prevent processes from writing
::-- to it.  Writes to this file will cause corruption to any child/derived images.
set PROTECT_WITHDRAW_FILE=%DELETE_VDISK_FILE%