.text

## struct Canvas {
##     // Height and width of the canvas.
##     unsigned int height;
##     unsigned int width;
##     // The pattern to draw on the canvas.
##     unsigned char pattern;
##     // Each char* is null-terminated and has same length.
##     char** canvas;
## };
## 
## // Count the number of disjoint empty area in a given canvas.
## unsigned int count_disjoint_regions_step(unsigned char marker,
##                                          Canvas* canvas) {
##     unsigned int region_count = 0;
##     for (unsigned int row = 0; row < canvas->height; row++) {
##         for (unsigned int col = 0; col < canvas->width; col++) {
##             unsigned char curr_char = canvas->canvas[row][col];
##             if (curr_char != canvas->pattern && curr_char != marker) {
##                 region_count ++;
##                 flood_fill(row, col, marker, canvas);
##             }
##         }
##     }
##     return region_count;
## }

.globl count_disjoint_regions_step
count_disjoint_regions_step:
        # Your code goes here :)$
        sub $sp, $sp, 40
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)
        sw $s6, 28($sp)
        sw $s7, 32($sp)
        sw $s8, 36($sp)

        move $s0, $a0           # $s0 holds marker
        move $s1, $a1           # $s1 holds canvas

        li $s2, 0               # $s2 holds region_count
        li $s3, 0               # $s3 holds row
        lw $s4, 0($s1)          # $s4 holds canvas->height

        first_for:
        bge $s3, $s4, out

        li $s5, 0               # $s5 holds col
        lw $s6, 4($s1)          # $s6 holds canvas->width

        col_for:
        bge $s5, $s6, increment_row
        lw $t0, 12($s1)
        mul $t1, $s3, 4
        add $t2, $t0, $t1       # &canvas->canvas[row]
        lw $t3, 0($t2)          # canvas->canvas[row]
        add $t4, $t3, $s5       # &canvas->canvas[row][col]
        lb $s8, 0($t4)          # $s8 holds canvas->canvas[row][col]

        if:
        lb $s7, 8($s1)          # $s7 holds canvas->pattern
        beq $s8, $s7, increment_col
        beq $s8, $s0, increment_col
        add $s2, $s2, 1
        move $a0, $s3
        move $a1, $s5
        move $a2, $s0
        move $a3, $s1
        jal flood_fill

        increment_col:
        add $s5, $s5, 1
        j col_for
        
        increment_row:
        add $s3, $s3, 1
        j first_for

        out:
        move $v0, $s2
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        lw $s8, 36($sp)
        add $sp, $sp, 40
        jr      $ra