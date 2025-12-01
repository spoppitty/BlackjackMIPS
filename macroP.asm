# practice macros
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

# exit the program	
.macro exitProgram
	li $v0, 10
	syscall
	.end_macro
