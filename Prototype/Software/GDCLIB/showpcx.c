
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "pcx.h"
#include "gdc7220.h"
#include "hbios.h"
#include "dma.h"
#if HAVE_STRERROR
#include <errno.h>
#include <string.h>
#endif

#define USE_PPM 0

#define PLANE_BUFFER_SIZE_IN_WORDS 2400

uint16_t plane0_buf[PLANE_BUFFER_SIZE_IN_WORDS], plane1_buf[PLANE_BUFFER_SIZE_IN_WORDS];
uint16_t plane2_buf[PLANE_BUFFER_SIZE_IN_WORDS], plane3_buf[PLANE_BUFFER_SIZE_IN_WORDS];
uint16_t plane_index = 0;
uint32_t plane_offset = 0;

PaletteEntry palette[16];

uint32_t bank_addr = 0;

int use_dma = 0;

#if USE_PPM
FILE *ppm_file = NULL;

void write_ppm_pixels(uint32_t num_pixels)
{
    for (int plane_offset = 0; plane_offset < num_pixels / 16; plane_offset++) {
        uint16_t plane3_value = plane3_buf[plane_offset];
        uint16_t plane2_value = plane2_buf[plane_offset];
        uint16_t plane1_value = plane1_buf[plane_offset];
        uint16_t plane0_value = plane0_buf[plane_offset];

        for (int i = 15; i >= 0; i--) {
            uint16_t plane3_bit = (plane3_value >> i) & 1;
            uint16_t plane2_bit = (plane2_value >> i) & 1;
            uint16_t plane1_bit = (plane1_value >> i) & 1;
            uint16_t plane0_bit = (plane0_value >> i) & 1;
            uint16_t index_value = plane3_bit << 3 | (plane2_bit << 2) | (plane1_bit << 1) | plane0_bit;
            fprintf(ppm_file, "%d %d %d ", palette[index_value].Red, palette[index_value].Green, palette[index_value].Blue);
        }
    }
}

#endif

void write_planes(uint16_t plane0, uint16_t plane1, uint16_t plane2, uint16_t plane3)
{
    plane0_buf[plane_index] = plane0;
    plane1_buf[plane_index] = plane1;
    plane2_buf[plane_index] = plane2;
    plane3_buf[plane_index] = plane3;
    plane_index++;
    if (plane_index == PLANE_BUFFER_SIZE_IN_WORDS) {
        if (use_dma) {
            uint16_t plane0_addr = (uint16_t) plane0_buf;
            uint32_t source_addr0 = bank_addr + plane0_addr;
            setup_z180_dma(source_addr0, 0x90, plane_index * 2);
            gdc_write_plane_dma(0, plane_offset, plane_index * 2);

            uint16_t plane1_addr = (uint16_t) plane1_buf;
            uint32_t source_addr1 = bank_addr + plane1_addr;
            setup_z180_dma(source_addr1, 0x90, plane_index * 2);
            gdc_write_plane_dma(1, plane_offset, plane_index * 2);

            uint16_t plane2_addr = (uint16_t) plane2_buf;
            uint32_t source_addr2 = bank_addr + plane2_addr;
            setup_z180_dma(source_addr2, 0x90, plane_index * 2);
            gdc_write_plane_dma(2, plane_offset, plane_index * 2);

            uint16_t plane3_addr = (uint16_t) plane3_buf;
            uint32_t source_addr3 = bank_addr + plane3_addr;
            setup_z180_dma(source_addr3, 0x90, plane_index * 2);
            gdc_write_plane_dma(3, plane_offset, plane_index * 2);

        } else {
            gdc_write_plane(0, plane_offset, plane0_buf, plane_index);
            gdc_write_plane(1, plane_offset, plane1_buf, plane_index);
            gdc_write_plane(2, plane_offset, plane2_buf, plane_index);
            gdc_write_plane(3, plane_offset, plane3_buf, plane_index);
        }
        plane_offset += plane_index;
        //uint32_t timer_tick = hbios_get_timer_tick();
        printf("Processed %ld of 307200 pixels via %s.\n", plane_offset << 4, use_dma ? "DMA" : "WDAT");

        plane_index = 0;
#if USE_PPM
        uint32_t num_pixels = PLANE_BUFFER_SIZE_IN_WORDS;
        num_pixels *= 16;
        write_ppm_pixels(num_pixels);
#endif
    }
}

void usage(const char *progname)
{
    fprintf(stderr, "Usage: %s [-d] file.pcx\n", progname);
    fprintf(stderr, "    -d    Use DMA for pixel writing. Default is to use WDAT.\n");
    exit(1);
}

int main(int argc, char **argv)
{
    // print out a DRI style welcome
    printf("---------------------------------------------------\r\n");
    printf("SHOWPCX    0.0.5                        03 May 2022\r\n");
    printf("Copyright (C) 2022                        Rob Gowin\r\n");
    printf("www.RetroBrewComputers.org                  GPL 2.0\r\n");
    printf("---------------------------------------------------\r\n");

    const char *optstring = "D";

    int ch = 0, have_error = 0;
    while ((ch = getopt(argc, argv, optstring)) != -1) {
        switch (ch) {
            case 'D':
            case 'd':
                use_dma = 1;
                break;
            case '?':
            default:
                have_error = 1;
                break;
        }
        if (have_error) break;
    }

    if (have_error) usage("SHOWPCX");

    argc -= optind;
    argv += optind;

    if (argc != 1) usage(argv[0]);

    printf("Initializing video system...\n");
    if (!init_gdc_system(MODE_640X480)) {
        printf("Failed to initialize UPD7220 video.\n");
        return 1;
    }

    PCXHeader pcx_header;

    const char *path = argv[0];
    int fd = open(path, O_RDONLY, 0);
    if (fd < 0) {
#if HAVE_STRERROR
        fprintf(stderr, "Can't open file '%s' for reading: %s\n", path, strerror(errno));
#else
        fprintf(stderr, "Can't open file '%s' for reading\n", path);
#endif
        return 1;
    }

    parse_pcx_header(fd, &pcx_header, path);
//    print_pcx_header(&pcx_header);
    bank_addr = hbios_get_bank() & 0x7F;
    bank_addr <<= 15;
    printf("Bank address = 0x%08lx\n", bank_addr);

    uint16_t height = pcx_header.YEnd - pcx_header.YStart + 1;
    uint16_t width  = pcx_header.XEnd - pcx_header.XStart + 1;
#if USE_PPM
    for (int i = 0; i < 16; i++) {
        palette[i].Red = pcx_header.Palette[i].Red;
        palette[i].Green = pcx_header.Palette[i].Green;
        palette[i].Blue = pcx_header.Palette[i].Blue;
    }

    // open the output ppm file
    ppm_file = fopen("test2.ppm", "w");
    fprintf(ppm_file, "P3\n");
    fprintf(ppm_file, "%d %d\n", width, height);
    fprintf(ppm_file, "255\n");
#endif
    gdc_display(1);
    for (int i = 0; i < 16; i++) {
        ramdac_set_palette_color(i, &pcx_header.Palette[i]);
    }

    create_planes(fd, height, width, path);
    gdc_display(1);
#if USE_PPM
    fclose(ppm_file);
#endif
    close(fd);

    return 0;
}
