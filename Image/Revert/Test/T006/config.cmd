::-- Required: The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0..\..\..\..\Argument\
::
::-- Required: The absolute path, without double quotes, to the Vdisk methods.
set BIND_VDISK=%~dp0..\..\..\..\Vdisk\
::
::-- Required: The absolute path, enclosed in double quotes, to the Vdisk config file needed by Delete.cmd.
set REVERT_VDISK_DELETE_CONFIG="%~dp0"
::
::-- Required: The absolute path, enclosed in double quotes, to the config file required by LayerCreate.cmd.
set REVERT_VDISK_LAYERCREATE_CONFIG="%~dp0"
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD layer being deleted.
set REVERT_LAYER_FILE="%~dp0\ShouldExistLayer.vhd"
::
::-- Required: The absolute path, enclosed in double quotes, to the immediate parent of the VHD layer being deleted.
set REVERT_CANONICAL_BASE_FILE="%~dp0\ShouldNotExistBase.vhd"
::
