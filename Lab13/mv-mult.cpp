#include "mv-mult.h"
#include <xmmintrin.h>

// Matrix-Vector multiplication
// mat is a SIZE by SIZE matrix, that is arranged in row-column, format,
// That is, you first select a particular row, and then a particular column.
// Each row is laid out as a one-dimensional, array, so if you wanted
// to select a particular row, you would use mat[row].  You can
// also select smaller intervals, by using &mat[row][col].
// The vector is also laid out as a one-dimensional arrow, similar to a row.
// M-V multiplication proceeds by taking the dot product of a matrix row
// with the vector, and doing this for each row in the matrix

// vectorize the below code using SIMD intrinsics
float *
mv_mult_vector(float mat[SIZE][SIZE], float vec[SIZE]) {
    // static float ret[SIZE];

    // for (int i = 0; i < SIZE; i ++) {
    //     ret[i] = 0;
    //     for (int j = 0; j < SIZE; j ++) {
    //         ret[i] += mat[i][j] * vec[j];
    //     }
    // }

    // return ret;

    static float ret[SIZE];
    float temp[4];
    __m128 mat_index, vec_index, final_sum;
    final_sum = _mm_set1_ps(0.0); // set all four words in final_sum to 0.0

    for (int i = 0; i < SIZE; i++) {
        ret[i] = 0;
        int j = 0;

        final_sum = _mm_set1_ps(0.0);
        for (; j < (SIZE - 3); j += 4) {
            mat_index = _mm_loadu_ps(&mat[i][j]);
            vec_index = _mm_loadu_ps(&vec[j]);
            final_sum = _mm_add_ps(final_sum, _mm_mul_ps(mat_index, vec_index));
        }
        _mm_store_ps(temp, final_sum);
        ret[i] += temp[0] + temp[1] + temp[2] + temp[3];

        for (; i < SIZE; i++) {
            ret[i] += mat[i][j] + vec[j];
        }
    }
    return ret;
} 
