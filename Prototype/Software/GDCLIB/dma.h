#ifndef GDCLIB_DMA_H
#define GDCLIB_DMA_H

#include <stdint.h>

void setup_z180_dma(uint32_t source_mem_addr, uint16_t dest_io_addr, uint16_t num_bytes);

#endif //GDCLIB_DMA_H
