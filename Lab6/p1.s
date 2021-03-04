# /**
#  * Given a table of recipes and an inventory of items, this function
#  * will populate times_craftable with the number of times each recipe
#  * can be crafted.
#  *
#  * Note: When passing arrays as parameters, the register $a0 will hold the starting
#  * address of the array, not the contents of the array.
#  */

# void craftable_recipes(int inventory[5], int recipes[10][5], int times_craftable[10]) {
#     const int NUM_ITEMS = 5;
#     const int NUM_RECIPES = 10;

#     for (int recipe_idx = 0; recipe_idx < NUM_RECIPES; recipe_idx++) {
#         times_craftable[recipe_idx] = 0x7fffffff;  // Largest positive number
#         int assigned = 0;

#         for (int item_idx = 0; item_idx < NUM_ITEMS; item_idx++) {
#             if (recipes[recipe_idx][item_idx] > 0) {
#                 // If the item is not required for the recipe, skip it
#                 // Note: There is a div psuedoinstruction to do the division
#                 // The format is:
#                 //    div   $rd, $rs, $rt
#                 int times_item_req = inventory[item_idx] / recipes[recipe_idx][item_idx];
#                 if (times_item_req < times_craftable[recipe_idx]) {
#                     times_craftable[recipe_idx] = times_item_req;
#                     assigned = 1;
#                 }
#             }
#         }

#         if (assigned == 0) {
#             times_craftable[recipe_idx] = 0;
#         }
#     }
# }

.globl craftable_recipes
mips_asm:
        
craftable_recipes:
        li $t0, 5               # $t0 holds NUM_ITEMS (NUM COLUMNS)
        li $t1, 10              # $t1 holds NUM_RECIPES (NUM ROWS)
        li $t2, 0               # $t2 holds recipe_index (i or row)

        # **check if dealing with array params correctly**

        for_one: 
                bge $t2, $t1, out
                mul $t3, $t2, 4     # $t3 has offset 4
                add $t4, $a2, $t3   # &times_craftable[r_ind]  **NOTE: check what to do for times_craftable[10]**     
                li $s0, 0x7fffffff  # CLARIFY THIS LI: $t4 - times_craftable[recipe_index] = 0x7fffffff
                sw $s0, 0($t4)
                li $t9, 0            # assigned = 0
                
                li $t5, 0           # $t5 holds item_index (col)
                for_two:
                        bge $t5, $t0, check_assign
                        if:                      # 2D array indexing: array[row * NUM COLUMNS + col]
                            mul $t6, $t2, $t0    # need to do a t2 offset?
                            add $t6, $t6, $t5   
                            mul $t6, $t6, 4      # col offset
                            add $t7, $a1, $t6    
                            lw $t7, 0($t7)       # $t7 holds recipes[recipe_idx][item_idx]
                            
                            ble $t7, $zero, after_if 
                            mul $t8, $t5, 4            
                            add $t8, $a0, $t8
                            lw $t8, 0($t8)  
                            div $t8, $t8, $t7    # $t8 now holds times_item_req

                            if_two:
                                bge $t8, $s0, after_if
                                sw $t8, 0($t4)  
                                li $t9, 1        # assigned = 1 
                                # add $t7, $t7, 1  # increment col
                                # j for_two

                        after_if:
                                add $t5, $t5, 1  # increment column
                                j for_two
                
                check_assign:
                        bne $t9, $zero, after
                        sw $zero, 0($t4)

                after:
                        add $t2, $t2, 1
                        j for_one

        out:
                jr      $ra