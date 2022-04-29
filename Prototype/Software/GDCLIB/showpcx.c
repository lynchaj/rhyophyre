
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

#include "pcx.h"
#include "gdc7220.h"

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
        gdc_write_plane(0, plane_offset, plane0_buf, plane_index);
        gdc_write_plane(1, plane_offset, plane1_buf, plane_index);
        gdc_write_plane(2, plane_offset, plane2_buf, plane_index);
        gdc_write_plane(3, plane_offset, plane3_buf, plane_index);
        plane_offset += plane_index;
        printf("Processed %ld of 307200 pixels.\n", plane_offset << 4);
        plane_index = 0;
#if USE_PPM
        uint32_t num_pixels = PLANE_BUFFER_SIZE_IN_WORDS;
        num_pixels *= 16;
        write_ppm_pixels(num_pixels);
#endif
    }
}

int main(int argc, char **argv)
{
    // print out a DRI style welcome
    printf("---------------------------------------------------\r\n");
    printf("SHOWPCX    0.0.1  A                     08 Apr 2022\r\n");
    printf("Copyright (C) 2022                        Rob Gowin\r\n");
    printf("www.RetroBrewComputers.org                  GPL 2.0\r\n");
    printf("---------------------------------------------------\r\n");

    if (argc != 2) {
        fprintf(stderr, "Usage: %s file.pcx\n", argv[0]);
        return 1;
    }
    printf("Initializing video system...\n");
    if (!init_gdc_system(MODE_640X480)) {
        printf("Failed to initialize UPD7220 video.\n");
        return 1;
    }

    PCXHeader pcx_header;

    const char *path = argv[1];
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
    print_pcx_header(&pcx_header);


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
    gdc_display(0);
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
