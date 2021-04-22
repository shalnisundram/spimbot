#include "transpose.h"
int min(int, int);
#define TILE_SIZE 32
// 120 -> 3.75 seconds, 3.42
// 110 -> 3.89 seconds

// modify this function to add tiling
void transpose(int **A, int **B) {
    for (int i = 0; i < N; i += TILE_SIZE) {
        for (int j = 0; j < N; j += TILE_SIZE) {
            for (int ii = i; ii < min(N, i + TILE_SIZE); ii++) {
                for (int jj = j; jj < min(N, j + TILE_SIZE); jj ++) {
                    B[ii][jj] = A[jj][ii];
                }   
            }
        }
    }
}
