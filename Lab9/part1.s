# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c
GET_MAP                 = 0xffff2040

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle

RESPAWN_INT_MASK        = 0x2000      ## Respawn
RESPAWN_ACK             = 0xffff00f0  ## Respawn

GET_WOOD                = 0xffff2000
GET_STONE               = 0xffff2004
GET_WOOL                = 0xffff2008

CRAFT                   = 0xffff2024

BREAK_BLOCK             = 0xffff2020

GET_INVENTORY           = 0xffff2034

.data
### Puzzle
puzzle:     .byte 0:400
solution:   .byte 0:256
#### Puzzle

scanner_result: .byte 0 0 0

has_puzzle: .word 0

inv:    .word 0:8

has_bonked:    .byte 0
# -- string literals --
.text
main:
    sub $sp, $sp, 4
    sw  $ra, 0($sp)

    # Construct interrupt mask
    li      $t4, 0
    or      $t4, $t4, TIMER_INT_MASK            # enable timer interrupt
    or      $t4, $t4, BONK_INT_MASK             # enable bonk interrupt
    or      $t4, $t4, REQUEST_PUZZLE_INT_MASK   # enable puzzle interrupt
    or      $t4, $t4, 1 # global enable
    mtc0    $t4, $12
    
    li $t1, 0
    sw $t1, ANGLE
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t2, 0
    sw $t2, VELOCITY
        
    # YOUR CODE GOES HERE!!!!!!

    travel_left:
        lw $t3, BOT_X
        bge $t3, 288, turn_down                  
        li $t2, 10
        sw $t2, VELOCITY
        j travel_left
    
    turn_down:
        li $t2, 0                                   # set velocity to 0 to turn 
        sw $t2, VELOCITY                                     

        li $t1, 90                                  # turn 90 degrees towards the bottom of the grid
        sw $t1, ANGLE
        li $t1, 1
        sw $t1, ANGLE_CONTROL

    travel_down:
        lw $t4, BOT_Y
        bge $t4, 32, collect_stone
        li $t2, 10
        sw $t2, VELOCITY
        j travel_down  
    
    collect_stone:
        li $t2, 0                                   # set velocity to 0 to break block
        sw $t2, VELOCITY
        li $t0, 0x00002503                          # stone is located at (37, 3)
        sw $t0, BREAK_BLOCK
        lw $t0, GET_STONE 
        bge $t0, 1, travel_to_wool
        j collect_stone
    
    travel_to_wool:
        lw $t4, BOT_Y
        bge $t4, 288, collect_wool                    # check y coord exceeded
        li $t2, 10      
        sw $t2, VELOCITY                              # move down
        j travel_down      

    collect_wool:
        li $t2, 0
        sw $t2, VELOCITY
        li $t0, 0x00002425                             # wool located at (36, 37)
        sw $t0, BREAK_BLOCK
        lw $t0, GET_WOOL
        bge $t0, 1, turn_to_tree
        j collect_wool

    turn_to_tree:
        li $t1, 180                                      # turn 90 degrees towards the left of the grid
        sw $t1, ANGLE   
        li $t1, 1
        sw $t1, ANGLE_CONTROL

    travel_to_tree:
        lw $t3, BOT_X
        ble $t3, 56, collect_tree
        li $t2, 10
        sw $t2, VELOCITY
        j travel_to_tree

    collect_tree:
        li $t2, 0
        sw $t2, VELOCITY
        li $t9, 0x00000524                              # tree located at (5, 36)
        sw $t9, BREAK_BLOCK
        lw $t9, GET_WOOD
        bge $t9, 1, craft_stick
        j collect_tree

    craft_stick:
        li $t5, 0x00000007
        sw $t5, CRAFT
        bge $t5, 1, loop
        j craft_stick

loop: # Once done, enter an infinite loop so that your bot can be graded by QtSpimbot once 10,000,000 cycles have elapsed
    j loop

.kdata
chunkIH:    .space 40
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
    move    $k1, $at        # Save $at
                            # NOTE: Don't touch $k1 or else you destroy $at!
.set at
    la      $k0, chunkIH
    sw      $a0, 0($k0)        # Get some free registers
    sw      $v0, 4($k0)        # by storing them to a global variable
    sw      $t0, 8($k0)
    sw      $t1, 12($k0)
    sw      $t2, 16($k0)
    sw      $t3, 20($k0)
    sw      $t4, 24($k0)
    sw      $t5, 28($k0)

    # Save coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    mfhi    $t0
    sw      $t0, 32($k0)
    mflo    $t0
    sw      $t0, 36($k0)

    mfc0    $k0, $13                # Get Cause register
    srl     $a0, $k0, 2
    and     $a0, $a0, 0xf           # ExcCode field
    bne     $a0, 0, non_intrpt



interrupt_dispatch:                 # Interrupt:
    mfc0    $k0, $13                # Get Cause register, again
    beq     $k0, 0, done            # handled all outstanding interrupts

    and     $a0, $k0, BONK_INT_MASK     # is there a bonk interrupt?
    bne     $a0, 0, bonk_interrupt

    and     $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne     $a0, 0, timer_interrupt

    and     $a0, $k0, REQUEST_PUZZLE_INT_MASK
    bne     $a0, 0, request_puzzle_interrupt

    and     $a0, $k0, RESPAWN_INT_MASK
    bne     $a0, 0, respawn_interrupt

    li      $v0, PRINT_STRING       # Unhandled interrupt types
    la      $a0, unhandled_str
    syscall
    j       done

bonk_interrupt:
    sw      $0, BONK_ACK
    la      $t0, has_bonked
    li      $t1, 1
    sb      $t1, 0($t0)
    #Fill in your bonk handler code here
    j       interrupt_dispatch      # see if other interrupts are waiting

timer_interrupt:
    sw      $0, TIMER_ACK
    li $s7, 1
    j        interrupt_dispatch     # see if other interrupts are waiting

request_puzzle_interrupt:
    sw      $0, REQUEST_PUZZLE_ACK
    #Fill in your puzzle interrupt code here
    j       interrupt_dispatch

respawn_interrupt:
    sw      $0, RESPAWN_ACK
    #Fill in your respawn handler code here
    j       interrupt_dispatch

non_intrpt:                         # was some non-interrupt
    li      $v0, PRINT_STRING
    la      $a0, non_intrpt_str
    syscall                         # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH

    # Restore coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    lw      $t0, 32($k0)
    mthi    $t0
    lw      $t0, 36($k0)
    mtlo    $t0

    lw      $a0, 0($k0)             # Restore saved registers
    lw      $v0, 4($k0)
    lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
    lw      $t4, 24($k0)
    lw      $t5, 28($k0)

.set noat
    move    $at, $k1        # Restore $at
.set at
    eret

jr $ra