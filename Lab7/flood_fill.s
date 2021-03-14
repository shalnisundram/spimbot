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
## // Mark an empty region as visited on the canvas using flood fill algorithm.
## void flood_fill(int row, int col, unsigned char marker, Canvas* canvas) {
##     // Check the current position is valid.
##     if (row < 0 || col < 0 ||
##         row >= canvas->height || col >= canvas->width) {
##         return;
##     }
##     unsigned char curr = canvas->canvas[row][col];
##     if (curr != canvas->pattern && curr != marker) {
##         // Mark the current pos as visited.
##         canvas->canvas[row][col] = marker;
##         // Flood fill four neighbors.
##         flood_fill(row - 1, col, marker, canvas);
##         flood_fill(row, col + 1, marker, canvas);
##         flood_fill(row + 1, col, marker, canvas);
##         flood_fill(row, col - 1, marker, canvas);
##     }
## }

.globl flood_fill
flood_fill:

sub $sp, $sp, 24
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)

move $s0, $a0
move $s1, $a1
move $s2, $a2
move $s3, $a3

if:
bge $a0, 0, second_or
j out

second_or:
bge $a1, 0, third_or
j out

third_or:
lw $t0, 0($a3)			# $t0 holds canvas->height
blt $a0, $t0, fourth_or
j out

fourth_or:
lw $t1, 4($a3)			# $t1 holds canvas->width
blt $a1, $t1, after_if
j out

after_if:
lw $t2, 12($a3)
mul $t7, $s0, 4
add $s4, $t7, $t2		# &canvas[row]
lw $t3, 0($s4)			# canvas[row]
add $s4, $s1, $t3   	# &canvas[row][col]
lb $t5, 0($s4)			# $t5 holds curr
lb $t6, 8($s3)			# $t6 holds canvas->pattern

main_if:
beq $t5, $t6, out
beq $t5, $a2, out
sb $s2, 0($s4)			# canvas->canvas[row][col] = marker
		
# first function call
move $a0, $s0
sub $a0, $a0, 1
move $a1, $s1
move $a2, $s2
move $a3, $s3
jal flood_fill

# second function call
move $a0, $s0
move $a1, $s1
add $a1, $a1, 1
move $a2, $s2
move $a3, $s3
jal flood_fill

# third function call
move $a0, $s0
add $a0, $a0, 1
move $a1, $s1
move $a2, $s2
move $a3, $s3
jal flood_fill

# # fourth function call
move $a0, $s0
move $a1, $s1
sub $a1, $a1, 1
move $a2, $s2
move $a3, $s3
jal flood_fill

out:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
add $sp, $sp, 24
jr $ra