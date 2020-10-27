::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, enclosed in double quotes, to the differencing
::-- (a.k.a. - child/derived) VHD of the desired immediate parent.
set LAYER_CANONICAL_LAYER_FILE=%TEST_LAYER_VHD_FILE%
::
::-- Required: The name of an environment variable to hold the canonical path of
::-- the immediate base VHD for the layer specified by LAYER_CANONICAL_LAYER_FILE.
::-- If the layer has a base, the provided variable will reflect that value.
::-- Otherwise, the provided variable's value will remain untouched.
set LAYER_CANONICAL_OUTPUT_PARENT_FILE=CANONICAL_PARENT_NAME
::