# Mazak Fusion 360 Post Processor

This post processor has been adapted by Keycult for use with an HCN-5000 horizontal machining center. Features applicable to other machine architectures may be changed or removed, and in any event, we have no way of testing them.

## TODO

- [x] Tool identifiers
- [x] Non-number program names
- [x] Remove naive smoothing implementation
- [x] Geometry compensation (G61.1)
- [x] Re-implement G5P2 (high speed smoothing, high speed machining)
- [x] High pressure coolant control (M100 - M106 to set coolant pressure levels)
- [x] G117 simultaneous operation (spindle accel/decel, through-spindle coolant)
- [ ] Niagara coolant control (M130)
