###Image

An image is a composite set of VHDs.  It consists of a child (layer) VHD derived from a parent (Base) VHD.
A child VHD protects its parent by absorbing file write operations, thereby, rendering the
parent VHD immutable.  Note, the parent VHD may also be a layered composite - constructed from
more than one VHD.  Although Microsoft doesn't support booting from a composite VHD, my
experience on a small number of machines, has demonstrated the reliability of this configuration. 