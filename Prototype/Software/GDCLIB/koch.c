#include <math.h>
#include <stdio.h>
#include <stdint.h>

#include "gdc7220.h"

const double_t PI = 3.14159;

static int color_index = 0;

void draw_star(uint16_t x, uint16_t y, uint16_t length, int level)
{
    double_t dbl_length = (double_t) length;
    if (length < 5) return;
  
    //printf("koch iteration: x = %d, y = %d, length = %d, level = %d\r\n", x, y, length, level);

    color_index++;
    if (color_index > 8) color_index = 1;

    color_setup(color_index);

    uint16_t x1 = (uint16_t)(dbl_length * cos(PI / 6.0));
    uint16_t y1 = length / 2;

    color_line(x, y + length, x + x1, y - y1);
    color_line(x + x1, y - y1, x - x1, y - y1);
    color_line(x - x1, y - y1, x, y + length);

    color_line(x, y - length, x + x1, y + y1);
    color_line(x + x1, y + y1, x - x1, y + y1);
    color_line(x - x1, y + y1, x, y - length);

    for (uint16_t angle = 0; angle < 360; angle += 60) { 
        double_t rad_angle = (double_t)(angle) * PI / 180.0;
        double_t delta_x = dbl_length * sin(rad_angle);
        double_t delta_y = dbl_length * cos(rad_angle);
        uint16_t newx = x + (int16_t)(delta_x);
        uint16_t newy = y + (int16_t)(delta_y);
        draw_star(newx, newy, length / 3, level);
    }
    draw_star(x, y, length / 3, level);
}

int main(void)
{
    const int Xmax = 640, Ymax = 480;
    if (!init_gdc_system(MODE_640X480)) { 
        printf("Failed to initialize UPD7220 video.\n");
        return 1;
    }

    draw_star(Xmax/2, Ymax/2, 150, 0);

    return 0;
}


