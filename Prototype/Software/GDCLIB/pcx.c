//

#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "pcx.h"

#if HAVE_STRERROR
#include <errno.h>
#endif

const int NUM_PALETTE_ENTRIES = 16;

void write_planes(uint16_t plane0, uint16_t plane1, uint16_t plane2, uint16_t plane3);

uint16_t get_uint16(const uint8_t p[2])
{
    return p[1] << 8 | p[0];
}

#if 0
int16_t get_int16(const uint8_t p[2])
{
    return p[1] << 8 | p[0];
}



uint32_t get_uint32(const uint8_t p[4])
{
    return p[3] << 24 | p[2] << 16 | p[1] << 8 | p[0];

}
#endif

uint8_t read_byte(int fd, const char *inpath)
{
    static uint8_t read_buf[1];
    ssize_t n = read(fd, read_buf, 1);
    if (n != 1) {
#if HAVE_STRERROR
        fprintf(stderr, "Short read from file '%s': %s\n", inpath, strerror(errno));
#else
        fprintf(stderr, "Short read from file '%s'\n", inpath);
#endif
    }
    return read_buf[0];
}

void create_planes(int fd, uint16_t height, uint16_t width, const char *inpath) {
    static uint8_t raster_buf[1024];
    for (int y = 0; y < height; y++) {

        /* Decode a scan line's worth of data */
        int decoded_count = 0;
        uint8_t *p = raster_buf;
        while (decoded_count < width) {
            uint8_t run_value = read_byte(fd, inpath);
            uint8_t run_count = 1;
            if ((run_value & 0xC0) == 0xC0) {
                run_count = run_value & 0x3f;
                run_value = read_byte(fd, inpath);
            }
            for (int i = 0; i < run_count; i++) {
                *p++ = run_value;
            }
            decoded_count += run_count;
        }


        // RAMDAC mapping:
        // P0 -> COLOR 0  (LSB)
        // P1 -> COLOR 1
        // P2 -> COLOR 2
        // P3 -> COLOR 3 (MSB)

        for (int x = 0; x < width; x += 16) {
            uint16_t plane3 = 0, plane2 = 0, plane1 = 0, plane0 = 0;

            for (int z = 15; z >=0 ; z--) {
                plane3 <<= 1;
                plane2 <<= 1;
                plane1 <<= 1;
                plane0 <<= 1;
                uint8_t value = raster_buf[x + z];
                if (value & 0x8) plane3 |= 1;
                if (value & 0x4) plane2 |= 1;
                if (value & 0x2) plane1 |= 1;
                if (value & 0x1) plane0 |= 1;
            }
            write_planes(plane0, plane1, plane2, plane3);
        }
    }
}


void print_pcx_header(const PCXHeader *pcx_header)
{
    printf("Identifier: %d\n", pcx_header->Identifier);
    printf("Version: %d\n", pcx_header->Version);
    printf("Encoding: %d\n", pcx_header->Encoding);
    printf("BitsPerPixel: %d\n",pcx_header->BitsPerPixel);
    printf("Start: (%d, %d)  End: (%d, %d)\n", pcx_header->XStart, pcx_header->YStart, pcx_header->XEnd, pcx_header->YEnd);
    printf("NumBitPlanes: %d\n", pcx_header->NumBitPlanes);
    printf("BytesPerLine: %d\n", pcx_header->BytesPerLine);

    for (int i = 0; i < NUM_PALETTE_ENTRIES; i++) {
        printf("Palette Entry[%2d]: Red = %3d, Green = %3d, Blue = %3d\n", i, pcx_header->Palette[i].Red,
               pcx_header->Palette[i].Green, pcx_header->Palette[i].Blue);
    }

#if 0
    pcx_header->HorzRes = get_uint16(&buffer[12]);
    pcx_header->VertRes = get_uint16(&buffer[14]);
    pcx_header->BytesPerLine = get_uint16(&buffer[66]);
    pcx_header->PaletteType = buffer[68];
#endif
}

void parse_pcx_header(int fd, PCXHeader *pcx_header, const char *path)
{
    uint8_t buffer[128];

    ssize_t n = read(fd, buffer, 128);

    if (n < 128) {
#if HAVE_STRERROR
        fprintf(stderr, "Short read on file '%s': %s\n", path, strerror(errno));
#else
        fprintf(stderr, "Short read on file '%s'\n", path);
#endif
    }
    pcx_header->Identifier = buffer[0];
    pcx_header->Version = buffer[1];
    pcx_header->Encoding = buffer[2];
    pcx_header->BitsPerPixel = buffer[3];
    pcx_header->XStart = get_uint16(&buffer[4]);
    pcx_header->YStart = get_uint16(&buffer[6]);
    pcx_header->XEnd = get_uint16(&buffer[8]);
    pcx_header->YEnd = get_uint16(&buffer[10]);
    pcx_header->HorzRes = get_uint16(&buffer[12]);
    pcx_header->VertRes = get_uint16(&buffer[14]);
    pcx_header->NumBitPlanes = buffer[65];
    pcx_header->BytesPerLine = get_uint16(&buffer[66]);
    pcx_header->PaletteType = get_uint16(&buffer[68]);
    pcx_header->HorzScreenSize = get_uint16(&buffer[70]);
    pcx_header->VertScreenSize = get_uint16(&buffer[72]);

    for (int i = 0; i < NUM_PALETTE_ENTRIES; i++) {
        pcx_header->Palette[i].Red = buffer[16 + 3*i];
        pcx_header->Palette[i].Green = buffer[16 + 3*i + 1];
        pcx_header->Palette[i].Blue = buffer[16 + 3*i + 2];
    }

}

