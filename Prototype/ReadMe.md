# rhyophyre prototype SBC overview

rhyophyre is a single board computer featuring a Z180 processor and NEC µPD7220 Graphics Display Controller

Important construction notes:
- the silkscreen for capacitor C46 value (0.1u) is missing.  C46 is just above U6 and this is pretty obviously a 0.1u bypass capacitor
- PS/2 keyboard and mouse protection diodes D4, D5, D7, & D8 are not necessary and interfere with proper operation.  Remove and replace with shunt wires for direction connection to VT82C42 controller from keyboard and mouse
- the footprints on the PCB for the diodes D1, D9, and D10-D15 are reversed due to an import error from an earlier version of KiCAD.  Be sure to install these diodes *in reverse* of what the PCB footprints indicate
- the BT478 are available on eBay as there are several vendors also probably UTSource
- the IS61C256 chips are standard 32Kx8 cache SRAMs from old 486 motherboards and almost any kind should work
- the MC78T05CT are rather special though as they are 5V DC voltage regulators capable of 3A sustained operation while most 7805 style VR can do 1.5A or 2.2A max
- there are three ways to power the board and you only need to install parts for the kind you use.  There is a 9VDC unregulated center positive barrel jack connector (5.5x2.1mm), a PC power supply Molex drive connector, and a 2 wire input screw terminal for bench power supply.  Choose one to use and install its hardware
- note that the BT478 PLCC-44 socket is rotated 90 degrees to the left so that the label reads left to right consistent with the Z180.  You must install the PLCC-44 socket in the proper orientation (pin 1 facing left) for it to work
- CPU needs 4.7K pull ups installed on WAIT#, BUSRQ#, INT2#, DREQ0#, and DREQ1# pins.  Add 4.7K SIP in patch area and run jumper wires as needed
- install RUN/HALT LED reverse against silkscreen to get green for RUN and red for HALT (note: it depends on what sort of bi-color LED you have.  Some are red-green and others are green-red.  My suggestion is to try it out before soldering it in.  Even loosely placing the LED in the PCB while the board is running will give you an idea of orientation)
- lift pins 10 and 12 on U20 (74LS06 next to VT82C42) so they're not generating spurious interrupts.  They'll share INT1# with option jumpers on V2
- U6 should be 74F32 not 74LS32, otherwise affects color palette
- if you are seeing flicker in resulting image running test programs (D7220 or T7220) try substituting a 74LS04 for 74F04 in U47.  This eliminated flicker on my Z180GDC V1 and dramatically improved picture quality & stability



Threshold Goals:
- implement Z180 SBC with uPD7220 GDC subsystem (met)
- run RomWBW as supported platform (met)
- 640x480 16 color VGA display using standard monitor (met)
- default power consumption with 74LSxx & 74Fxx glue logic (met)
- use uPD7220 GDC as video console display in text mode
- use PS/2 keyboard as console input


Objectives:
- GSX-80 implementation
- uPD72020 support (CMOS version of uPD7220)
- implement DMA interface for uPD7220
- PS/2 mouse support
- 800x600 16 color VGA display using standard monitor
- reduced power consumption with 74HCTxx & 74ACTxx glue logic
