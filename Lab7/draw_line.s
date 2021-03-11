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

## void draw_line(unsigned int start_pos, unsigned int end_pos, Canvas* canvas) {
##     unsigned int width = canvas->width;
##     unsigned int step_size = 1;
##     // Check if the line is vertical.
##     if (end_pos - start_pos >= width) {
##         step_size = width;
##     }
##     // Update the canvas with the new line.
##     for (int pos = start_pos; pos != end_pos + step_size; pos += step_size) {
##         canvas->canvas[pos / width][pos % width] = canvas->pattern;
##     }
## }

.globl draw_line
draw_line:

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
        
        move $s0, $a0
        move $s1, $a1
        move $s2, $a2
        li $t0, 1                  # $t0 holds step_size

        if:
        sub $s3, $s1, $s0          # $s3 holds end_pos - start_pos
        lw $t4, 4($s2)             # $t4 holds 4($s2): canvas->width
        blt $s3, $t4, pre_for
        lw $t0, 4($s2)             # step_size = width

        pre_for:
        move $s4, $s0              # $s4 holds pos

        for:
        add $s5, $s1, $t0          # $s5 holds end_pos + step_size
        beq $s4, $s5, out
        rem $s8, $s4, $t4          # $s8 holds [pos % width]
        div $s7, $s4, $t4          # $s7 holds [pos / width]
        mul $s6, $s7, 4

        lw $t1, 12($s2)
        add $s7, $t1, $s6          # &canvas->canvas[pos / width]
        lw $t2, 0($s7)             # canvas->canvas[pos / width]
        add $s8, $t2, $s8          # &canvas->canvas[pos / width][pos % width]
        #lw $t2, 0($s8)
        lb $t3, 8($s2)             # $t3 holds canvas->pattern
        sb $t3, 0($s8)             # canvas->canvas[pos / width][pos % width] = canvas->pattern

        add $s4, $s4, $t0
        j for

        out:
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
        jr $ra
