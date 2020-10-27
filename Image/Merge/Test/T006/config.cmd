::-- Required: The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0..\..\..\..\Argument\
::
::-- Required: The absolute path, without double quotes, to the Vdisk methods.
set BIND_VDISK=%~dp0..\..\..\..\Vdisk\
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD layer whose state will be merged with its parent.
set MERGE_LAYER_FILE="%~dp0\ShouldExistLayer.vhd"
::
::-- Required: The absolute path, enclosed in double quotes, to the immediate parent of the VHD given layer.
set MERGE_CANONICAL_BASE_FILE="%~dp0\ShouldNotExistBase.vhd"
::
