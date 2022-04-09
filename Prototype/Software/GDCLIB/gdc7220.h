#ifndef __GDC7220_H__
#define __GDC7220_H__

#include <stdint.h>

/* 4-plane Colors */
#define CLR_BLACK    0
#define CLR_BLUE     1
#define CLR_GREEN    2
#define CLR_CYAN     3
#define CLR_RED      4
#define CLR_MAGENTA  5
#define CLR_AMBER    6
#define CLR_WHITE    7
#define CLR_DARK_WHITE 8
#define CLR_BR_BLUE  9
#define CLR_BR_GREEN 10
#define CLR_BR_CYAN  11
#define CLR_BR_RED   12
#define CLR_BR_MAGENTA  13
#define CLR_BR_YELLOW   14
#define CLR_BR_WHITE 15

/* Drawing modes:  */
#define GDC_REPLACE     0
#define GDC_XOR         1
#define GDC_OR          3
#define GDC_CLEAR       2

/* Video modes */
#define MODE_640X480    1
#define MODE_800x600    2
#define MODE_1024x768   3

typedef struct PaletteEntry {
    uint8_t Red, Green, Blue;
} PaletteEntry;

#ifdef __cplusplus
extern "C" {
#endif
    void    color_line(int x1, int y1, int x2, int y2);
    uint8_t color_mode(uint8_t mode);
    uint8_t color_setup(uint8_t color);
    void    gchar_test(void);
    void    gdc_clear_screen(void);
    void    gdc_display(int enable);
    void    gdc_done(void);
    void    gdc_hline(int x1, int x2, int y, uint8_t mode);
    void    gdc_pattern(uint16_t pattern);
    void    gdc_write_plane(uint8_t plane_num, uint32_t offset, const uint16_t *buf, uint16_t num_words);
    int     init_gdc_system(uint8_t video_mode);
    void    ramdac_set_palette_color(uint8_t index, PaletteEntry color);

#ifdef __cplusplus
}
#endif

#endif
