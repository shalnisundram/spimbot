#include "transpose.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

void
transpose_none(int **src, int **dest) {
    for (int i = 0; i < N; i ++) {
        for (int j = 0; j < N; j ++) {
            dest[i][j] = src[j][i];
        }
    }
}

int
main(int argc, char *argv[]) {
    // allocate memory for the images.
    int **image1, **image2, **image3;
    image1 = (int **) malloc(N * sizeof(int *));
    image2 = (int **) malloc(N * sizeof(int *));
    image3 = (int **) malloc(N * sizeof(int *));

    for (int x = 0; x < N; x ++) {
        image1[x] = (int *) malloc(N * sizeof(int));
        image2[x] = (int *) malloc(N * sizeof(int));
        image3[x] = (int *) malloc(N * sizeof(int));
    }

    for (int i = 0; i < N; i ++) {
        for (int j = 0; j < N; j ++) {
            image1[i][j] = random() % 10;
            image2[i][j] = 0;
            image3[i][j] = 0;
        }
    }

    clock_t c0 = clock(), c1;

    transpose_none(image1, image2);

    c1 = clock();
    printf("Elapsed CPU time without optimization is %lf seconds\n",
           (((double) c1) - c0) / CLOCKS_PER_SEC);

    c0 = clock();

    transpose(image1, image3);

    c1 = clock();
    printf("Elapsed CPU time with optimization is %lf seconds\n",
           (((double) c1) - c0) / CLOCKS_PER_SEC);

    // check to make sure we did things right
    bool matches = true;
    for (int i = 0; i < N; i ++) {
        for (int j = 0; j < N; j ++) {
            if (image2[i][j] != image3[i][j]) {
                matches = false;
                break;
            }
        }
    }
    printf("the transformed images %s\n", matches ? "match" : "don't match");
}

int min(int x, int y){
    if (x < y)
        return x;
    else
        return y;
}
