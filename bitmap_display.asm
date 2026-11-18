##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL: 
    .word 0x10008000

# 7 columns x 14 rows = 98 words
# 0 = empty, 1 = red, 2 = green, 3 = blue, 4 = yellow
grid:
    .word 1, 2, 3, 4, 1, 2, 3    # Row 0
    .word 2, 3, 4, 1, 2, 3, 4    # Row 1
    .word 3, 4, 1, 2, 3, 4, 1    # Row 2
    .word 4, 1, 2, 3, 0, 0, 0    # Row 3
    .word 0, 3, 0, 0, 0, 0, 0    # Row 4
    .word 0, 3, 0, 0, 0, 0, 0    # Row 5
    .word 0, 3, 0, 0, 0, 0, 0    # Row 6
    .word 0, 3, 0, 0, 0, 0, 0    # Row 7
    .word 0, 3, 0, 0, 0, 0, 0    # Row 8
    .word 0, 3, 0, 0, 0, 0, 0    # Row 9
    .word 0, 3, 0, 0, 0, 0, 0    # Row 10
    .word 0, 3, 0, 0, 0, 0, 0    # Row 11
    .word 0, 3, 0, 0, 0, 0, 0    # Row 12
    .word 0, 3, 0, 0, 0, 0, 0    # Row 13

    .text
    .globl main


main:
  jal draw_border
  jal draw_grid
   
exit:
    li $v0, 10                  # terminate the program gracefully
    syscall

##################################################################################################
# draw_border: Draws a 1-unit white border around the 14x28 (7x14 with each 'ball' 2x2) playfield 
# Covers x = [1..16], y = [1..30]
##################################################################################################
draw_border:
    addi $sp, $sp, -4           # Save return address on stack
    sw $ra, 0($sp)

    li $a2, 0xb6b6b6            # $a2 = white

    # 1. Draw Top (y = 1) and Bottom (y = 44) walls for x = 1 to 23
    li $s0, 1                   # x = 1
    li $s1, 24                  # stop when x == 24
    
border_horiz_loop:
    beq $s0, $s1, border_horiz_done

    move $a0, $s0               # x = $s0
    li $a1, 1                   # y = 1 (top wall)
    jal draw_unit

    move $a0, $s0               # x = $s0
    li $a1, 44                  # y = 44 (bottom wall)
    jal draw_unit

    addi $s0, $s0, 1            # x++
    j border_horiz_loop

border_horiz_done:
    # 2. Draw Left (x = 1) and Right (x = 23) walls for y = 1 to 44
    li $s0, 1                   # y = 1
    li $s1, 45                  # stop when y == 45

border_vert_loop:
    beq $s0, $s1, border_vert_done

    li $a0, 1                   # x = 1 (left wall)
    move $a1, $s0               # y = $s0
    jal draw_unit

    li $a0, 23                  # x = 23 (right wall)
    move $a1, $s0               # y = $s0
    jal draw_unit

    addi $s0, $s0, 1            # y++
    j border_vert_loop

border_vert_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##############################################################################
# draw_unit: Draws a single 1x1 unit at (x = $a0, y = $a1) in color $a2
##############################################################################
draw_unit:
    lw $t0, ADDR_DSPL           # Base display address (0x10008000)

    sll $t8, $a1, 6             # $t8 = y * 32
    add $t8, $t8, $a0           # $t8 = (y * 32) + x
    sll $t8, $t8, 2             # $t8 = byte offset
    add $t9, $t8, $t0           # $t9 = exact RAM address

    sw $a2, 0($t9)              # Paint single unit
    jr $ra
    
##############################################################################
# draw_grid: Draws a 2x2 bubble for each ID in 'grid' in color $a2
# Covers a total area of 14x28, offset from the top-left by 4 units
##############################################################################
draw_grid:
    addi $sp, $sp, -4           # Save return address on stack
    sw $ra, 0($sp)

    # Load colour palette into $t1 - $t4
    li $t1, 0xff0000            # $t1 = red (ID 1)
    li $t2, 0x00ff00            # $t2 = green (ID 2)
    li $t3, 0x0000ff            # $t3 = blue (ID 3)
    li $t4, 0xffff00            # $t4 = yellow (ID 4)

    la $s0, grid                # $s0 = pointer to current cell in grid
    li $s1, 0                   # $s1 = cell index i (0 to 97)
    li $s2, 98                  # $s2 = total cells (7 * 14)
    li $s3, 7                   # $s3 = number of columns

grid_loop:
    beq $s1, $s2, grid_done     # End loop when i == 98 (all pixels loaded)

    lw $t0, 0($s0)              # Load cell ID (0, 1, 2, 3, or 4)

    # Map cell to hex colour
    li $a2, 0x000000            # Default: black (ID 0)
    beq $t0, 1, set_red
    beq $t0, 2, set_green
    beq $t0, 3, set_blue
    beq $t0, 4, set_yellow
    j compute_coords
    
set_red:
  move $a2, $t1                 # $a2 = 0xff0000
  j compute_coords
set_green:
  move $a2, $t2                 # $a2 = 0x00ff00
  j compute_coords
set_blue:
  move $a2, $t3                 # $a2 = 0x0000ff
  j compute_coords
set_yellow:
  move $a2, $t4                 # $a2 = 0xffff00

#############################################################################################
# compute_coords: Compute ram address of 2x2 pixel with top left pixel at (x = $a0, y = $a1)
#############################################################################################
compute_coords:
  div $s1, $s3                  # cell index i($s1) / number of columns($s3)
  mflo $t5                      # row (quotient)
  mfhi $t6                      # column (remainder)

  # Each pixel has width of 3 and an offset from the top left corner of 2 pixels for padding
  sll $a0, $t6, 1               # $a0 = (col * 2)
  add $a0, $a0, $t6             # $a0 = (col * 2) + col
  addi $a0, $a0, 2              # $a0 = x_coordinate = (col * 3) + 2
  
  sll $a1, $t5, 1               # $a1 = (row * 2)
  add $a1, $a1, $t5             # $a1 = (row * 2) + row
  addi $a1, $a1, 2              # $a1 = y_coordinate = (row * 3) + 2

  jal draw_bubble  

  addi $s0, $s0, 4              # Increment the grid pointer
  addi $s1, $s1, 1              # i++
  j grid_loop


grid_done:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
  
###################################################################################
# draw_bubble: Draws a 2x2 pixel, top left pixel at (x = $a0, y = $a1) in color $a2
###################################################################################
draw_bubble:
    lw $t0, ADDR_DSPL              # Base display address

    # Calculate byte offset 64 units wide (4 pixel units, 256 pixel dimensions)
    # Offset = ((y * 64) + x) * 4
    sll $t8, $a1, 6                # $t8 = y * 64
    add $t8, $t8, $a0              # $t8 = (y * 64) + x
    sll $t8, $t8, 2                # $t8 = byte offset
    add $t9, $t8, $t0              # $t9 = top-left ram address

    # Paint Row 0 (y)
    sw $a2, 0($t9)                 # Col 0
    sw $a2, 4($t9)                 # Col 1 (+4 bytes)
    sw $a2, 8($t9)                 # Col 2 (+8 bytes)

    # Paint Row 1 (y + 1(256 bytes per row))
    sw $a2, 256($t9)               # Col 0
    sw $a2, 260($t9)               # Col 1
    sw $a2, 264($t9)               # Col 2

    # Paint Row 2 (y + 2(256 bytes per row))
    sw $a2, 512($t9)               # Col 0
    sw $a2, 516($t9)               # Col 1
    sw $a2, 520($t9)               # Col 2

    jr $ra

