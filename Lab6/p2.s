# /**
#  * This function matches a 5x5 pattern across the map using 2D convolution.
#  * If the correlation between the pattern and a 5x5 patch of the map is above the
#  * given threshold, then the left hand corner of the patch will be returned.
#  * If no match was found, then -1 is returned.
#  */
# int pattern_match(int threshold, int pattern[5][5], int map[16][16]) {
#     const int PATTERN_SIZE = 5;
#     const int EDGE = 16 - 5 + 1;

#     for (int row = 0; row < EDGE; row++) {
#         for (int col = 0; col < EDGE; col++) {
#             int sum = 0;
#             for (int pat_row = 0; pat_row < PATTERN_SIZE; pat_row++) {
#                 for (int pat_col = 0; pat_col < PATTERN_SIZE; pat_col++) {
#                     if (pattern[pat_row][pat_col] == map[row + pat_row][col + pat_col]) {
#                         sum += 1;
#                     }
#                     if (sum > threshold) {
#                         return (row << 16) | col;
#                     }
#                 }
#             }
#         }
#     }
#     return -1;
# }

# /**
#  * This function matches a 5x5 pattern across the map using 2D convolution.
#  * If the correlation between the pattern and a 5x5 patch of the map is above the
#  * given threshold, then the left hand corner of the patch will be returned.
#  * If no match was found, then -1 is returned.
#  */
# int pattern_match(int threshold, int pattern[5][5], int map[16][16]) {
#     const int PATTERN_SIZE = 5;
#     const int EDGE = 16 - 5 + 1;

#     for (int row = 0; row < EDGE; row++) {
#         for (int col = 0; col < EDGE; col++) {
#             int sum = 0;
#             for (int pat_row = 0; pat_row < PATTERN_SIZE; pat_row++) {
#                 for (int pat_col = 0; pat_col < PATTERN_SIZE; pat_col++) {
#                     if (pattern[pat_row][pat_col] == map[row + pat_row][col + pat_col]) {
#                         sum += 1;
#                     }
#                     if (sum > threshold) {
#                         return (row << 16) | col;
#                     }
#                 }
#             }
#         }
#     }
#     return -1;
# }

.globl pattern_match

mips_asm:

pattern_match:
        li $t0, 0                          # $t0 holds row
        li $v0, 0                          # $v0 holds return value

        row_for:
                bge $t0, 12, last_out
                li $t1, 0                  # $t1 holds col
        col_for:
                bge $t1, 12, after_col_for
                li $t2, 0                  # $t2 holds sum
                li $t3, 0                  # $t3 holds pat_row
        pat_row_for:
                bge $t3, 5, after_pat_row_for
                li $t4, 0                  # $t4 holds pat_col
        pat_col_for:
                bge $t4, 5, after_pat_col_for
                
                if:                        # 2D array indexing: array[row * NUM COLUMNS + col]
                        mul $t5, $t3, 5
                        add $t5, $t5, $t4
                        mul $t5, $t5, 4   
                        add $t5, $a1, $t5
                        lw $t5, 0($t5)     # $t5 holds pattern[pat_row][pat_col]

                        add $t6, $t0, $t3
                        mul $t6, $t6, 16 
                        add $t7, $t1, $t4
                        add $t6, $t6, $t7
                        mul $t6, $t6, 4
                        add $t6, $a2, $t6
                        lw $t6, 0($t6)    # $t6 holds map[row + pat_row][col + pat_col]

                        bne  $t5, $t6, second_if
                        add $t2, $t2, 1
                        j second_if

                second_if:
                        ble $t2, $a0, after_pat_col_for_body
                        sll $t0, $t0, 16   # row << 16 
                        or $v0, $t0, $t1
                        j return_val_out

                          
        after_col_for:
                add $t0, $t0, 1             # increment row
                j row_for
        
        after_pat_row_for:
                add $t1, $t1, 1             # increment col
                j col_for

        after_pat_col_for:      
                add $t3, $t3, 1             # increment pat_row
                j pat_row_for

        after_pat_col_for_body:
                add $t4, $t4, 1             # increment pat_col
                j pat_col_for

        last_out:
                li $v0, -1
                jr      $ra

        return_val_out:
                jr      $ra

        