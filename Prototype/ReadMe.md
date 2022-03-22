# rhyophyre prototype SBC overview

rhyophyre is a single board computer featuring a Z180 processor and NEC µPD7220 Graphics Display Controller

Important construction notes:
- the silkscreen for capacitor C46 value (0.1u) is missing.  C46 is just above U6 and this is pretty obviously a 0.1u bypass capacitor
- the footprints on the PCB for the diodes D1, D4, D5, D7, D8, D9, and D10-D15 are reversed due to a import error from an earlier version of KiCAD.  Be sure to install these diodes *in reverse* of what the PCB footprints indicate. 
