#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#define MAR1_LO   0x28
#define MAR1_MID  0x29
#define MAR1_HI   0x2A

#define IAR1_LO   0x2B
#define IAR1_HI   0x2C

#define BCR1_LO   0x2E
#define BCR1_HI   0x2F

#define DSTAT     0x30
#define DCNTRL    0x32

void setup_z180_dma(uint32_t source_mem_addr, uint16_t dest_io_addr, uint16_t buffer_size)
{
// Steps to program the Z180 DMA controller
//
//    * MAR1 = 20-bit address of buffer on Z180 side
//    * IAR1 = port address of the 7220 (either one)
//    * BCR1 = number of bytes to transfer
//    * DCNTL: 0b11110000 => 0xF0
//         MWI1, MWI0 (bits 7, 6) = 0b11, one memory wait state, but not applicable to IO
//         IWI1, IWI1 (bits 5, 4) = 0b11, one I/O wait state
//         DMS1, DMS0 (bit 3,2) = 0b00 -> level sensitive
//         DIM1, DIM0 (bits 1,0) -> 0b00 -> Memory to I/O, MAR1 +1 increment, fixed IAR1 address
//    * DSTAT: 0b10010001 => 0x91
//         DE1 (bit 7) => 1 (enable Channel 1)
//         DE0 (bit 6) => 0 (disable Channel 0)
//         DWE1 (bit 5) => 0 (required)
//         DEW1 (bit 4) => 1
//         DIE1, DIE0 (bits 3, 2) => 0b00 (no interrupts)
//         don't care (bit 1) => 0
//         DME (bit 0) => 1 (global DMA enable)

    printf("setup_z180_dma: source = 0x%08lx, dest = 0x%2x, size = %d\n", source_mem_addr, dest_io_addr, buffer_size);

    outp(MAR1_LO, (uint8_t)(source_mem_addr & 0xFF));
    outp(MAR1_MID, (uint8_t)((source_mem_addr >> 8) & 0xFF));
    outp(MAR1_HI, (uint8_t)((source_mem_addr >> 16) & 0xF));

    outp(IAR1_LO, dest_io_addr & 0xFF);
    outp(IAR1_HI, (dest_io_addr >> 8) & 0xFF);

    outp(BCR1_LO, buffer_size & 0xFF);
    outp(BCR1_HI, (buffer_size > 8) & 0xFF);

    outp(DCNTRL, 0xF0); // 0b11110000, see above

    outp(DSTAT, 0x91); // 0b10010001, see above

}


void test_dma(void)
{

}