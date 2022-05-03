#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#define MAR1_LO   0x68
#define MAR1_MID  0x69
#define MAR1_HI   0x6A

#define IAR1_LO   0x6B
#define IAR1_HI   0x6C

#define BCR1_LO   0x6E
#define BCR1_HI   0x6F

#define DSTAT     0x70
#define DCNTRL    0x72

static void dump_dma(void)
{
    printf("MAR1: BK=%02x, HI=%02x, LO=%02x\n", inp(MAR1_HI), inp(MAR1_MID), inp(MAR1_LO));
    printf("IAR1:          HI=%02x, LO=%02x\n", inp(IAR1_HI), inp(IAR1_LO));
    printf("BCR1:          HI=%02x, LO=%02x\n", inp(BCR1_HI), inp(BCR1_LO));
 
    printf("DSTAT: %02x, DCNTRL: %02x\n", inp(DSTAT), inp(DCNTRL));
}
void setup_z180_dma(uint32_t source_mem_addr, uint16_t dest_io_addr, uint16_t num_bytes)
{
// Steps to program the Z180 DMA controller
//
//    * MAR1 = 20-bit address of buffer on Z180 side
//    * IAR1 = port address of the 7220 (either one)
//    * BCR1 = number of bytes to transfer
//    * DCNTL: 0b11100000 => 0xE0
//         MWI1, MWI0 (bits 7, 6) = 0b11, one memory wait state, but not applicable to IO
//         IWI1, IWI1 (bits 5, 4) = 0b10, three I/O wait states
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

//  printf("setup_z180_dma: source = 0x%08lx, dest = 0x%2x, num_bytes = %d\n", source_mem_addr, dest_io_addr, num_bytes);

    outp(MAR1_LO, (uint8_t)(source_mem_addr & 0xFF));
    outp(MAR1_MID, (uint8_t)((source_mem_addr >> 8) & 0xFF));
    outp(MAR1_HI, (uint8_t)((source_mem_addr >> 16) & 0xF));

    outp(IAR1_LO, dest_io_addr & 0xFF);
    outp(IAR1_HI, (dest_io_addr >> 8) & 0xFF);

    outp(BCR1_LO, num_bytes & 0xFF);
    outp(BCR1_HI, (num_bytes >> 8) & 0xFF);

    outp(DCNTRL, 0xE0); // 0b11100000, see above

    outp(DSTAT, 0x91); // 0b10010001, see above

//  dump_dma();

}
