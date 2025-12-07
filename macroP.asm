# Group 2: Aaronn Mach, Kellan Young, Sarah Liu, William Tu
# CS2640.02
# 12/7/2025
# MIPS Assembly Final Project
# macroP.asm

# print the given string
.macro printString(%string)
	li $v0, 4
	la $a0, %string
	syscall
	.end_macro

# print the given int (has be a register $)
.macro printInt(%int)
	li $v0, 1
	move $a0, %int
	syscall
	.end_macro

# read int
# int stored in $v0
.macro getInt
	li $v0, 5
	syscall
	.end_macro

# random number generator given a range (has to be a literal integer, not a register)
# random int is stored in $a0
.macro getRandom(%max)
	li $v0, 42  
	li $a1, %max   
	syscall
	.end_macro

# get a random card representation, number value in $s0, suit value in $s1
.macro getRandomCard
	getRandom(13)		# get number value
	move $s0, $a0		# move value to $s0
	addi $s0, $s0, 1	# add 1 because range was 0-12
	
	getRandom(4)		# get suit value
	move $s1, $a0		# move value to $s1
	addi $s1, $s1, 1	# add 1 because range was 0-3
	.end_macro

# create a delay for usability in the bitmap display
# give value as milliseconds
.macro delay(%milli)
	li $v0, 32
	li $a0, %milli
	syscall
	.end_macro	

.macro resetBoard(%boardColor)
	# Base address of bitmap display
	li $t0, 0x10040000
	li $t3, 4096		# pixels
	li $t4, %boardColor   	# $t4 = board color (dark green)
	
	fillBoard_loop:
		beq $t3, 0, finishResetBoard
		sw $t4, 0($t0)       # store color at current address
		addi $t0, $t0, 4       # move to next unit 
		addi $t3, $t3, -1      # decrement unit counter
		j fillBoard_loop
	
	finishResetBoard:
		.end_macro

# draw a rectangle on the bitmap display given the position by row and column, width, height, and color, all as immediate values
.macro drawRect(%col, %row, %w, %h, %color)
	# Base address of bitmap display
	li   $t0, 0x10040000

	# Compute offset = (row * 64 + col) * 4
	li   $t1, 64
	mul  $t2, $t1, %row      # t2 = row * 64
	add  $t2, $t2, %col      # t2 = row*64 + col
	sll  $t2, $t2, 2         # t2 = (row*64 + col) * 4
	add  $t0, $t0, $t2       # t0 = address of top-left pixel of rectangle

	# color
	li   $t3, %color

	# Copy height to t4 (row counter)
	li $t4, %h

	row_loop:
		# For each row, we start writing at address in t0
		li $t5, %w          # t5 = remaining pixels in this row
		move $t6, $t0         # t6 = current pixel address in this row

		col_loop:
			sw   $t3, 0($t6)      # write white pixel
			addi $t6, $t6, 4      # move to next pixel (4 bytes)
			addi $t5, $t5, -1
			bgtz $t5, col_loop

			# Finished one row of the rectangle
			addi $t4, $t4, -1
			blez $t4, rect_done

			# Move t0 to the first pixel of the next row of the rectangle.
			# One full bitmap row = 64 pixels * 4 bytes = 256 bytes.
			# We already moved %w pixels inside this row, so we need to:
			#   t0 = t0 + 256
			addi $t0, $t0, 256
			j    row_loop

	rect_done:
		.end_macro

# draw card value and suit given the value, suit, col, and row of card
# value and suit are registers, col and row are immediate values
# hard coding every value and suit
.macro drawCardFace(%value, %suit, %col, %row)
	# Base address of bitmap display
	li   $t0, 0x10040000

	# Compute offset = (row * 64 + col) * 4
	li   $t1, 64
	mul  $t2, $t1, %row      # t2 = row * 64
	add  $t2, $t2, %col      # t2 = row*64 + col
	sll  $t2, $t2, 2         # t2 = (row*64 + col) * 4
	add  $t0, $t0, $t2       # t0 = address of top-left pixel of rectangle
	
	# if the value is 10, we have to shift over by 1 pixel
	beq %value, 10, ifValue10
	j decideColor
	
	ifValue10:
		addi $t0, $t0, 4
	
	# color of suit
	decideColor:
		beq %suit, 1, redColor
		beq %suit, 3, redColor
		beq %suit, 2, blackColor
		beq %suit, 4, blackColor
	
		redColor:
			li $t3, 0x009E1C1C
			j drawValue
	
		blackColor:
			li $t3, 0x00000000
			j drawValue
	
	# draw the value
	drawValue:
		beq %value, 0, draw0
		beq %value, 1, draw1
		beq %value, 2, draw2
		beq %value, 3, draw3
		beq %value, 4, draw4
		beq %value, 5, draw5
		beq %value, 6, draw6
		beq %value, 7, draw7
		beq %value, 8, draw8
		beq %value, 9, draw9
		beq %value, 10, draw10
		beq %value, 11, draw11
		beq %value, 12, draw12
		beq %value, 13, draw13
		
		# draws rectangle
		draw0:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2060($t0)
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2572($t0)
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw1:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw2:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2064($t0)	# second row
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
			
		draw3:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw4:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)

			sw   $t3, 2576($t0)
			
			sw   $t3, 2832($t0)
			j drawSuit
			
		draw5:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw6:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
			
		draw7:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2064($t0)
			
			sw   $t3, 2320($t0)
			
			sw   $t3, 2576($t0)
			
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw8:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw9:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			sw   $t3, 2320($t0)
			
			sw   $t3, 2576($t0)
			
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw10:
			sw   $t3, 1792($t0)
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2048($t0)
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2304($t0)
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2320($t0)
			
			sw   $t3, 2560($t0)
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2816($t0)
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2828($t0)
			sw   $t3, 2832($t0)
			j drawSuit
			
		draw11:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2064($t0)
			
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2828($t0)
			j drawSuit
		
		draw12:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1804($t0)
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2320($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2572($t0)
			
			sw   $t3, 2832($t0)
			j drawSuit
		
		draw13:
			sw   $t3, 1800($t0)	# first row
			sw   $t3, 1808($t0)
	
			sw   $t3, 2056($t0)	# second row
			sw   $t3, 2064($t0)
			
			sw   $t3, 2312($t0)	# third row
			sw   $t3, 2316($t0)
			
			sw   $t3, 2568($t0)	# fourth row
			sw   $t3, 2576($t0)
			
			sw   $t3, 2824($t0)	# fifth row
			sw   $t3, 2832($t0)
			j drawSuit
	
	# draw the suit	
	drawSuit:
		beq %suit, 0, drawBlank
		beq %suit, 1, drawDiamond
		beq %suit, 2, drawClub
		beq %suit, 3, drawHeart
		beq %suit, 4, drawSpade
		
		# draws square
		drawBlank:
			sw   $t3, 1816($t0)	# first row
			sw   $t3, 1820($t0)
			sw   $t3, 1824($t0)
			sw   $t3, 1828($t0)
			sw   $t3, 1832($t0)
			
			sw   $t3, 2072($t0)	# second row
			sw   $t3, 2076($t0)
			sw   $t3, 2080($t0)
			sw   $t3, 2084($t0)
			sw   $t3, 2088($t0)
			
			sw   $t3, 2328($t0)	# third row
			sw   $t3, 2332($t0)
			sw   $t3, 2336($t0)
			sw   $t3, 2340($t0)
			sw   $t3, 2344($t0)
			
			sw   $t3, 2584($t0)	# fourth row
			sw   $t3, 2588($t0)
			sw   $t3, 2592($t0)
			sw   $t3, 2596($t0)
			sw   $t3, 2600($t0)
			
			sw   $t3, 2840($t0)	# fifth row
			sw   $t3, 2844($t0)
			sw   $t3, 2848($t0)
			sw   $t3, 2852($t0)
			sw   $t3, 2856($t0)
			j draw_done
		
		drawDiamond:
			sw   $t3, 1824($t0)	# first row
				
			sw   $t3, 2076($t0)	# second row
			sw   $t3, 2080($t0)
			sw   $t3, 2084($t0)
			
			sw   $t3, 2328($t0)	# third row
			sw   $t3, 2332($t0)
			sw   $t3, 2336($t0)
			sw   $t3, 2340($t0)
			sw   $t3, 2344($t0)
				
			sw   $t3, 2588($t0)	# fourth row
			sw   $t3, 2592($t0)
			sw   $t3, 2596($t0)
			
			sw   $t3, 2848($t0)	# fifth row
			j draw_done
		
		drawClub:
			sw   $t3, 1820($t0)	# first row
			sw   $t3, 1824($t0)
			sw   $t3, 1828($t0)
			
			sw   $t3, 2076($t0)	# second row
			sw   $t3, 2080($t0)
			sw   $t3, 2084($t0)
			
			sw   $t3, 2328($t0)	# third row
			sw   $t3, 2332($t0)
			sw   $t3, 2336($t0)
			sw   $t3, 2340($t0)
			sw   $t3, 2344($t0)
			
			sw   $t3, 2584($t0)	# fourth row
			sw   $t3, 2588($t0)
			sw   $t3, 2592($t0)
			sw   $t3, 2596($t0)
			sw   $t3, 2600($t0)
			
			sw   $t3, 2848($t0)	# fifth row
			j draw_done
		
		drawHeart:
			sw   $t3, 1820($t0)	# first row
			sw   $t3, 1828($t0)
			
			sw   $t3, 2072($t0)	# second row
			sw   $t3, 2076($t0)
			sw   $t3, 2080($t0)
			sw   $t3, 2084($t0)
			sw   $t3, 2088($t0)
			
			sw   $t3, 2328($t0)	# third row
			sw   $t3, 2332($t0)
			sw   $t3, 2336($t0)
			sw   $t3, 2340($t0)
			sw   $t3, 2344($t0)
			
			sw   $t3, 2588($t0)	# fourth row
			sw   $t3, 2592($t0)
			sw   $t3, 2596($t0)
	
			sw   $t3, 2848($t0)	# fifth row
			j draw_done
		
		drawSpade:
			sw   $t3, 1824($t0)	# first row
			
			sw   $t3, 2076($t0)	# second row
			sw   $t3, 2080($t0)
			sw   $t3, 2084($t0)
			
			sw   $t3, 2328($t0)	# third row
			sw   $t3, 2332($t0)
			sw   $t3, 2336($t0)
			sw   $t3, 2340($t0)
			sw   $t3, 2344($t0)
			
			sw   $t3, 2584($t0)	# fourth row
			sw   $t3, 2588($t0)
			sw   $t3, 2592($t0)
			sw   $t3, 2596($t0)
			sw   $t3, 2600($t0)
			
			sw   $t3, 2848($t0)	# fifth row
			j draw_done
	
	draw_done:
		.end_macro

# exit the program	
.macro exitProgram
	li $v0, 10
	syscall
	.end_macro
