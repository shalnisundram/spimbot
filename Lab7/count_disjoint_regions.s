.text

## struct Lines {
##     unsigned int num_lines;
##     // An int* array of size 2, where first element is an array of start pos
##     // and second element is an array of end pos for each line.
##     // start pos always has a smaller value than end pos.
##     unsigned int* coords[2];
## };
## 
## struct Solution {
##     unsigned int length;
##     int* counts;
## };
## 
## // Count the number of disjoint empty area after adding each line.
## // Store the count values into the Solution struct. 
## void count_disjoint_regions(const Lines* lines, Canvas* canvas,
##                             Solution* solution) {
##     // Iterate through each step.
##     for (unsigned int i = 0; i < lines->num_lines; i++) {
##         unsigned int start_pos = lines->coords[0][i];
##         unsigned int end_pos = lines->coords[1][i];
##         // Draw line on canvas.
##         draw_line(start_pos, end_pos, canvas);
##         // Run flood fill algorithm on the updated canvas.
##         // In each even iteration, fill with marker 'A', otherwise use 'B'.
##         unsigned int count =
##                 count_disjoint_regions_step('A' + (i % 2), canvas);
##         // Update the solution struct. Memory for counts is preallocated.
##         solution->counts[i] = count;
##     }
## }

.globl count_disjoint_regions
count_disjoint_regions:
        # Your code goes here :)
        sub $sp, $sp, 24
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)

        move $s0, $a0           # $s0 holds lines
        move $s1, $a1           # $s1 holds canvas
        move $s2, $a2           # $s2 holds solution

        li $s3, 0               # $s3 holds i

for:
        lw $t0, 0($s0)          # $t0 holds num_lines
        bge $s3, $t0, out
        lw $t1, 4($s0)          # $t1 holds lines->coords[0]
        mul $t2, $s3, 4
        add $t3, $t1, $t2       # &lines->coords[0][i]
        lw $t4, 0($t3)          # $t4 holds start_pos

        lw $t5, 8($s0)          # $t5 holds lines->coords[1]
        add $t5, $t5, $t2       # &lines->coords[1][i]
        lw $t6, 0($t5)          # $t6 holds end_pos

        move $a0, $t4
        move $a1, $t6
        move $a2, $s1
        jal draw_line

        rem $t7, $s3, 2
        add $t8, $t7, 65       # $t8 holds 'A' + (i % 2)
        move $a0, $t8
        move $a1, $s1
        jal count_disjoint_regions_step

        add $s4, $v0, 0         # $s4 holds count
        mul $t2, $s3, 4
        lw $s5, 4($s2)          # &solution->counts
        add $s5, $t2, $s5       # &solution->counts[i]
        sw $s4, 0($s5)
        add $s3, $s3, 1
        j for

out:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        add $sp, $sp, 24
        jr      $ra
