::-- Required: The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument\
::
::-- Required: The absolute path, without double quotes, to the Vdisk methods.
set BIND_VDISK=%VDISK_METHOD_PATH%
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD layer.
set REVERT_LAYER_FILE=%REVERT_LAYER_FILE%
::
::-- Required: The absolute path, enclosed in double quotes, to the immediate parent of the VHD layer being deleted.
set REVERT_CANONICAL_BASE_FILE=%REVERT_CANONICAL_BASE_FILE%
::