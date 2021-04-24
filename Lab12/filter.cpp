#include <stdio.h>
#include <stdlib.h>
#include "filter.h"
int min(int, int);

void filter(pixel_t **image1, pixel_t **image2) {
    // for (int i = 1; i < SIZE - 1; i ++) {
    //     filter1(image1, image2, i);
    // }

    // for (int i = 2; i < SIZE - 2; i ++) {
    //     filter2(image1, image2, i);
    // }

    // for (int i = 1; i < SIZE - 5; i ++) {
    //     filter3(image2, i);
    // }

    for (int i = 1; i < SIZE - 1; i ++) {
        __builtin_prefetch(&image1[i + 1], 0, 3); // read
        __builtin_prefetch(&image1[i + 1], 1, 3); // write  
        filter1(image1, image2, i);

        if (i > 1 && i < SIZE - 2) {
            // __builtin_prefetch(&image2[i + 2], 0, 3); // read
            // __builtin_prefetch(&image2[i + 2], 1, 3); // write
            filter2(image1, image2, i);
        }

        if (i >= 6) {
            filter3(image2, i - 5);
        }
    }
}
