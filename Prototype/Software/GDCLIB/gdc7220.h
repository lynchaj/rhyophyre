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

/* the GDC 7220 status bits:   */
typedef enum GDC_Status {
//  GDC_DATA_READY		= 0x01,
    GDC_FIFO_FULL		= 0x02,
    GDC_FIFO_EMPTY		= 0x04,
    GDC_DRAWING		    = 0x08,
    GDC_DMA_EXEC		= 0x10,
//  GDC_VERT_SYNC		= 0x20,
//  GDC_HORIZ_SYNC		= 0x40,
//  GDC_LIGHT_PEN		= 0x80,
} GDC_Status;


#ifdef __cplusplus
extern "C" {
#endif

    extern uint16_t Xmax, Ymax, Ybuf;
    extern const uint8_t  Xchar, Ychar;

    uint32_t get_ticks(void) __naked;
    void    color_line(int x1, int y1, int x2, int y2);
    uint8_t color_mode(uint8_t mode);
    uint8_t color_setup(uint8_t color);
    void    gchar_test(void);
    void    gdc_clear_screen(int full);
    void    gdc_clear_lines(uint16_t start_line, uint16_t line_count);
    void    gdc_display(int enable);
    void    gdc_done(void);
    void    gdc_hline(int x1, int x2, int y, uint8_t mode);
    void    gdc_pattern(uint16_t pattern);
    void    gdc_write_plane(uint8_t plane_num, uint32_t offset, const uint16_t *buf, uint16_t num_words);
    void    gdc_write_plane_dma(uint8_t plane_num, uint32_t offset, uint16_t num_words);
    void    gdc_scroll(int16_t lines);
    void    text_write_char(uint8_t c);
    void    text_set_cursor(uint8_t y, uint8_t x);
    void    text_show_cursor(void);
    void    text_hide_cursor(void);
    void    text_scroll(int16_t lines);
    void    text_clear_screen(void);
    void    text_clear_lines(uint16_t start_line, uint16_t line_count);
    int     init_gdc_system(uint8_t video_mode);
    void    ramdac_set_palette_color(uint8_t index, PaletteEntry *color);

#ifdef __cplusplus
}
#endif

#endif
