::-- Required: The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%BIND_ARGUMENT%
::
::-- Required: The absolute path, enclosed in double quotes, to the differencing
::-- (a.k.a. - child/derived) VHD of the desired immediate parent.
set LAYER_CANONICAL_LAYER_FILE=%LAYER_CANONICAL_LAYER_FILE%
::
::-- Required: The name of an environment variable to hold the canonical path of
::-- the immediate base VHD for the layer specified by LAYER_CANONICAL_LAYER_FILE.
::-- If the layer has a base, the provided variable will reflect that value.
set LAYER_CANONICAL_OUTPUT_PARENT_FILE=%LAYER_CANONICAL_OUTPUT_PARENT_FILE%
::
