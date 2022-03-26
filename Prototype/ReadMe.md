# rhyophyre prototype SBC overview

rhyophyre is a single board computer featuring a Z180 processor and NEC µPD7220 Graphics Display Controller

Important construction notes:
- the silkscreen for capacitor C46 value (0.1u) is missing.  C46 is just above U6 and this is pretty obviously a 0.1u bypass capacitor
- the footprints on the PCB for the diodes D1, D4, D5, D7, D8, D9, and D10-D15 are reversed due to an import error from an earlier version of KiCAD.  Be sure to install these diodes *in reverse* of what the PCB footprints indicate
- the BT478 are available on eBay as there are several vendors also probably UTSource
- the IS61C256 chips are standard 32Kx8 cache SRAMs from old 486 motherboards and most any kind should work
- the MC78T05CT are rather special though as they are 5V DC voltage regulators capable of 3A sustained operation while most 7805 style VR can do 1.5A or 2.2A max
- there are three ways to power the board and you only need to install parts for the kind you use.  There is a 9VDC unregulated center positive barrel jack connector (5.5x2.1mm), a PC power supply Molex drive connector, and a 2 wire input screw terminal for bench power supply.  Choose one to use and install its hardware
- note that the BT478 PLCC-44 socket is rotated 90 degrees to the left so that the label reads left to right consistent with the Z180.  You must install the PLCC-44 socket in the proper orientation for it to work.

Threshold Goals:
- implement Z180 SBC with uPD7220 GDC subsystem
- run RomWBW as supported platform
- use uPD7220 GDC as video console display (text mode)
- use PS/2 keyboard as console input
- 640x480 16 color VGA display using standard monitor
- default power consumption with 74LSxx & 74Fxx glue logic

Objectives:
- GSX-80 implementation
- uPD72020 support (CMOS version of uPD7220)
- implement DMA interface for uPD7220
- PS/2 mouse support
- 800x600 16 color VGA display using standard monitor
- reduced power consumption with 74HCTxx & 74ACTxx glue logic
