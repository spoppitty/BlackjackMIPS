# restructure

.include "macroP.asm"

.data
# to run bitmap display properly
# unit width and height is 8
# display width and height is 512 x 512
# base address is 0x10040000 (heap)
bmdA: .word 0x10040000	# bitmap display address
bmdW: .word 64		# bitmap display width / 8
bmdH: .word 64		# bitmap display height / 8

menuString: .asciiz "\nWould you like to play Blackjack?\nPress (1) for yes\nPress (2) to exit\n"
exitString: .asciiz "\nGG! Let's play again later!"
errorString: .asciiz "\nError, try again"

currentString: .asciiz "\nYou currently have: "
coinString: .asciiz " coins"
betString: .asciiz "\nHow much would you like to bet? "

.text
.globl main
main:
	# use $t registers for bitmap display 
	# use $s registers for game logic
	
	# load bitmap display base, width, height
	la $t0, bmdA
	lw $t0, 0($t0)       	# $t0 = BASE
	la $t1, bmdW
	lw $t1, 0($t1)       	# $t1 = width
	la $t2, bmdH
	lw $t2, 0($t2)       	# $t2 = height

	mul $t3, $t1, $t2     	# t3 = total unit counter

	li $t4, 0x00064227   	# $t4 = board color (dark green)
	
	# initialize coin count
	li $s7, 100

# fill/reset board with dark green
# Counter($t3) always needs to be reset before filling
fill_board:
	beq $t3, $zero, menuSelection  # if no pixels left, finish

	sw $t4, 0($t0)       # store color at current address
	addi $t0, $t0, 4       # move to next unit 
	addi $t3, $t3, -1      # decrement unit counter
	j fill_board

menuSelection:
	# print menu
	printString(menuString)
	
	# get selection
	getInt
	move $s0, $v0
	
	# check input
	beq $s0, 1, betSelection
	beq $s0, 2, exit
	printString(errorString)	# if input is not 1 or 2, try again
	j menuSelection

betSelection:
	# prompt bet amount
	printString(currentString)
	printInt($s7)
	printString(coinString)
	printString(betString)
	
	# get bet amount
	getInt
	move $s6, $v0			# bet amount is in $s6
	
	# check input
	bgez $s6, setCardGhost
	printString(errorString)	# if input is negative, try again
	j betSelection

setCardGhost:
	# cards are 13 x 19 pixels
	li $t5, 0x00FFFFFF	# $t5 = white
	li $t6, 0x00FFA0A0	# $t6 = pink
	
	# reset these counters for filling
	la $t0, bmdA
	lw $t0, 0($t0)       	# $t0 = BASE
	mul $t3, $t1, $t2     	# t3 = total unit counter
	
	sw $t5, 2124($t0)
	sw $t5, 2128($t0)
	sw $t5, 2132($t0)
	sw $t5, 2136($t0)
	sw $t5, 2140($t0)
	sw $t5, 2144($t0)
	sw $t5, 2148($t0)
	j exit

exit:
	printString(exitString)
	exitProgram
	
	
