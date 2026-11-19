################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Magical Drop.
#
# Student 1: Arthur Xu, 1012306265
# Student 2: Ryan Ravas, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
# Pixel map of word pause, 12 lines tall, spans 64 pixels wide
# AI was used to generate this grid since it would be extremely tedioius to do so manually
# Google assistant was used after making a google search for "write 'pause' on 64x64 pixels"
PAUSE_MENU_GRID:
    .word 0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    .word 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0


##############################################################################
# Mutable Data
##############################################################################

# 7 columns x 14 rows = 98 words
# 0 = empty/ black, 1 = red, 2 = green, 3 = blue, 4 = yellow
# Currently written with words, not .space for debugging/ testing purposes
grid:
    .word 1, 2, 3, 4, 1, 2, 3    # Row 0
    .word 2, 3, 4, 1, 2, 3, 4    # Row 1
    .word 3, 4, 1, 2, 3, 4, 1    # Row 2
    .word 0, 0, 0, 0, 0, 0, 0    # Row 3
    .word 0, 0, 0, 0, 0, 0, 0    # Row 4
    .word 0, 0, 0, 0, 0, 0, 0    # Row 5
    .word 0, 0, 0, 0, 0, 0, 0    # Row 6
    .word 0, 0, 0, 0, 0, 0, 0    # Row 7
    .word 0, 0, 0, 0, 0, 0, 0    # Row 8
    .word 0, 0, 0, 0, 0, 0, 0    # Row 9
    .word 0, 0, 0, 0, 0, 0, 0    # Row 10
    .word 0, 0, 0, 0, 0, 0, 0    # Row 11
    .word 0, 0, 0, 0, 0, 0, 0    # Row 12
    .word 0, 0, 0, 0, 0, 0, 0    # Row 13

curr_pos: .word  3            # Current column position of the character (0-6)
curr_held: .word 0            # Number of bubbles held
curr_colour: .word 1          # Same colour IDs as grid (1-4)
keyboard_address: .word 0xffff0000

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    li $a0, 12                   # number of rows of random bubbles to generate (1-12)
    jal generate_starting_grid
    jal draw_border
    jal draw_grid
    jal draw_character
    jal draw_held


game_loop:
    lw $t0 , keyboard_address       # t0 - base address for keyboard 
    lw $t8 , 0($t0)                 # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word is 1, key is pressed

    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed2
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    # jal keyboard_address
    j game_loop

keyboard_input:                   # key is pressed
  lw $t2, 4($t0)                  # Load second word from keyboard 
  beq $t2, 0x61, input_A          # check if key_a was pressed
  beq $t2, 0x64, input_D          # check if key_d was pressed
  j game_loop

input_A:
  la $t0, curr_pos  
  lw $t1, 0($t0)
  beq $t1, 0, game_loop
  addi $t1, $t1, -1               # update the character's position 1 spot left
  sw $t1, 0($t0)
  j redraw
input_D:
  la $t0, curr_pos              
  lw $t1, 0($t0)
  beq $t1, 6, game_loop
  addi $t1, $t1, 1                # update the character's position 1 spot right
  sw $t1, 0($t0)
  j redraw

redraw:                           # update the character's position in response to loop
    jal wipe_screen
    jal draw_border
    jal draw_grid
    jal draw_character
    jal draw_held
    j game_loop
      

##################################################################################################
# draw_border: Draws a 1-unit white border around the 14x28 (7x14 with each 'ball' 2x2) playfield 
# Covers x = [1..16], y = [1..30], 1 unit padding top and left
##################################################################################################
draw_border:
    addi $sp, $sp, -4           # Save return address on stack
    sw $ra, 0($sp)

    li $a2, 0xb6b6b6            # $a2 = white

    # Draw Top (y = 1) and Bottom (y = 44) walls for x = 1 to 23
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

###############################################################################
# generate_starting_grid: generates $a0 many rows of randomly coloured bubbles
###############################################################################
generate_starting_grid:
    addi $sp, $sp, -16                   # Save $ra, $s, $a0 registers on stack
    sw $ra, 0($sp)                       
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $a0, 12($sp)
    
    li $s0, 0                           # Index i = 0
    li $t0, 7                           # load constant
    mul $s1, $t0, $a0                   # Generate 7 x $a0 bubbles, 7 cols * $a0 rows
    la $t0, grid                        # Base address of grid

starting_grid_loop:
    beq $s0, $s1, starting_grid_done

    jal generate_random_1_to_4         # generate random number 1-4
    
    sll $t1, $s0, 2                    # $t1 = i * 4 = Byte offset for the i-th bubble in grid
    add $t1, $t1, $t0                  # $t1 = exact ram address of i-th bubble in grid

    sw $a0, 0($t1)                     # Put the random number into the corresponding ram address

    addi $s0, $s0, 1                   # i++

    j starting_grid_loop

generate_random_1_to_4:
    li $v0, 42
    li $a0, 0
    li $a1, 4                          # return value is in $a0
    syscall                            # Generates number 0-3

    addi $a0, $a0, 1                   # Correct number to be between 1-4
    jr $ra

starting_grid_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $a0, 12($sp)
    addi $sp, $sp, 16                  # restore $s registers and return to the correct address
    jr $ra
    
##############################################################################
# draw_grid: Draws a 3x3 bubble for each ID in 'grid' in color $a2
# Covers a total area of 21x42, offset from the top-left by 4 units
##############################################################################
draw_grid:
    addi $sp, $sp, -16           # Save return address and $s registers on stack
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    la $s0, grid                # $s0 = pointer to current cell in grid
    li $s1, 0                   # $s1 = cell index i (0 to 97)
    li $s2, 98                  # $s2 = total cells (7 * 14)
    li $s3, 7                   # $s3 = number of columns
    
    li $a3, 2                   # padding = 2 pixels from top left

grid_loop:
    beq $s1, $s2, grid_done     # End loop when i == 98 (all pixels loaded)

    lw $t0, 0($s0)              # Load cell ID (0, 1, 2, 3, or 4)

    # Map cell to hex colour
    li $a2, 0x000000            # Default: black (ID 0)
    beq $t0, 1, set_grid_red
    beq $t0, 2, set_grid_green
    beq $t0, 3, set_grid_blue
    beq $t0, 4, set_grid_yellow
    j compute_grid_coords
    
set_grid_red:
    li $a2, 0xff0000
    j compute_grid_coords
set_grid_green:
    li $a2, 0x00ff00
    j compute_grid_coords
set_grid_blue:
    li $a2, 0x0000ff
    j compute_grid_coords
set_grid_yellow:
    li $a2, 0xffff00

#################################################################################################################
# compute_grid_coords: Compute ram address of 3x3 pixel with top left pixel at (x = $a0, y = $a1) padding of $a3
#################################################################################################################
compute_grid_coords:
    div $s1, $s3                  # cell index i($s1) / number of columns($s3)
    mflo $t5                      # row (quotient)
    mfhi $t6                      # column (remainder)

    # Each pixel has width of 3 and an offset from the top left corner of $a3 pixels for padding
    sll $a0, $t6, 1               # $a0 = (col * 2)
    add $a0, $a0, $t6             # $a0 = (col * 2) + col
    add $a0, $a0, $a3             # $a0 = x_coordinate = (col * 3) + padding
  
    sll $a1, $t5, 1               # $a1 = (row * 2)
    add $a1, $a1, $t5             # $a1 = (row * 2) + row
    add $a1, $a1, $a3             # $a1 = y_coordinate = (row * 3) + padding

    jal draw_bubble  

    addi $s0, $s0, 4              # Increment the grid pointer
    addi $s1, $s1, 1              # i++
    j grid_loop


grid_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 16             # Restore $s registers and return to correct return address
    jr $ra
  
####################################################################################################
# draw_bubble: Draws a 3x3 pixel, top left pixel at (x = $a0, y = $a1) in color $a2, padding in $a3
# Return: $v0 = ram address of top left pixel of the bubble
####################################################################################################
draw_bubble:
    lw $t0, ADDR_DSPL              # Base display address

    # Calculate byte offset 64 units wide (4 pixel units, 256 pixel dimensions)
    # Offset = ((y * 64) + x) * 4
    sll $t8, $a1, 6                # $t8 = y * 64
    add $t8, $t8, $a0              # $t8 = (y * 64) + x
    sll $t8, $t8, 2                # $t8 = byte offset = ((y * 64) + x) * 4
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


####################################################################################
# draw_character: Draws a 1x1 pixel below the board in its current position
####################################################################################
draw_character:
    addi $sp, $sp, -4          # Allocate 12 bytes on stack
    sw $ra, 0($sp)
    
    # Character position:
    # x_coordinate = (curr_pos + offset(padding))
    # y_coordinate = playfield_height + border(top and bottom) + offset(padding)
    
    li $a2, 0xffffff            # $a2 = character colour = white
    li $a3, 2                   # padding(top and left) = 2

    lw $a0, curr_pos            # $t0 = curr_pos
    mul $a0, $a0, 3             # $t0 = curr_pos * 4
    add $a0, $a0, $a3           # $t0 = (curr_pos) * 4 + padding(top and left)
  
    li $a1, 45                  # $t1 = playfield_height + border(bottom) + padding(top) 

    sw $a0, 4($sp)              # Save x_coord on stack
    sw $a1, 8($sp)              # Save y_coord on stack
  
    jal draw_bubble
  
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
########################################################################
# draw_held: Draws a n x 1 pixel vertical bar below the character pixel
########################################################################
draw_held:
    addi $sp, $sp, -16          # Preserve $ra and $s registers
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
  
    lw $s0, curr_held           # Number of bubbles held
    li $s1, 0                   # Index i = 0
    
    lw $s2, curr_pos
    mul $s2, $s2, 3             # $s2 = curr_pos * 3
    addi $s2, $s2, 2            # $s2 = x_coord = (curr_pos * 3) + 2
    
    lw $s3, curr_colour         # Colour of held bubbles

held_loop:
    beq $s0, $s1, held_done     # exit loop when all held bubbles are drawn (i = curr_held)

    li $a3, 2                   # padding = 2 pixels from top left

    li $a2, 0x000000            # Default colour is black
    beq $s3, 1, set_held_red
    beq $s3, 2, set_held_green
    beq $s3, 3, set_held_blue
    beq $s3, 4, set_held_yellow
    j held_draw

set_held_red:
    li $a2, 0xff0000
    j held_draw
set_held_green:
    li $a2, 0x00ff00
    j held_draw
set_held_blue:
    li $a2, 0x0000ff
    j held_draw
set_held_yellow:
    li $a2, 0xffff00
    
held_draw:
    move $a0, $s2               # x_coord = (curr_pos * 3) + 2
    addi $t5, $s1, 1            # $t5 = i + 1  (1 for 1st bubble, 2 for 2nd, etc.)
    mul $t5, $t5, 3             # $t5 = (i + 1) * 3  (3, 6, 9, ...)
    addi $a1, $t5, 45           # $a1 = y_coord = 45 + (i + 1) * 3  (48, 51, 54, ...)

    jal draw_bubble

    addi $s1, $s1, 1            # i++
    j held_loop
    
held_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

#################################################################################################
# draw_pause: Draws a pause menu on screen
# 'Pause' is 12 pixels tall, 26 blank lines above and below it
#################################################################################################

draw_pause:
    addi $sp, $sp, -20                   # Save return address and $s registers
    sw $ra, 0($sp)                 
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    lw $t8, ADDR_DSPL
    li $t9, 0xbb0000
    sw $t9, 0($t8)
    
    lw $s0, ADDR_DSPL                    # Base address of display
    la $s1, PAUSE_MENU_GRID              # Grid of 'pause' pixels

    li $s2, 0                            # Index i = 0
    li $s3, 768                          # 12 rows x 64 cols = 764 pixels
    
    # Base display offset = 6656 = 26 rows x 64 pixels x 4 bytes per pixel
    addi $s0, $s0, 6656                  # Centre vertically 'pause' 
    jal wipe_screen

draw_pause_word_loop:
    beq $s2, $s3, draw_pause_menu_done

    sll $t1, $s2, 2                      # Offset = i * 4   

    add $a0, $t1, $s0                    # Display address = base display address + offset of current pixel
    add $t2, $t1, $s1                    # Grid address = base grid address + offset of current pixel
    
    lw $t4, 0($t2)                       # 0 or 1 if pixel should be drawn white(1) or black(0)

    beq $t4, 0, set_pause_pixel_black
    beq $t4, 1, set_pause_pixel_white
    
    j draw_pause_word_loop

set_pause_pixel_black:
    li $a1, 0x000000
    j draw_pause_pixel
  
set_pause_pixel_white:
    li $a1, 0xffffff
    j draw_pause_pixel

#######################################################
# draw_pause_pixel: Draws a pixel at $a0 in colour $a1
#######################################################
draw_pause_pixel:
    sw $a1, 0($a0)
    addi $s2, $s2, 1                     # i++
    j draw_pause_word_loop

draw_pause_menu_done:  
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
#######################################################
# wipe_screen: Makes every pixel black
#######################################################
wipe_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0                        # Index i = 0
    li $t1, 4096                     # 64x64 = number of pixels

    lw $t2, ADDR_DSPL                # Base display address
    
wipe_screen_loop:
    beq $t0, $t1, wipe_screen_done

    mul $t3, $t0, 4                  # Offset of current pixel
    add $t3, $t3, $t2                # Address of current pixel

    li $t4, 0x000000                 # black

    sw $t4, 0($t3)                   # Draw pixel

    addi $t0, $t0, 1                 #i++
    j wipe_screen_loop

wipe_screen_done:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra


  