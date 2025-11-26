# Group 2: Aaronn Mach, Kellan Young, Sarah Liu, William Tu
# CS2640.02
# 11/26/2025
# MIPS Assembly Final Project
# macros.asm

# print the given string
.macro printString(%string)
	li $v0, 4
	la $a0, %string
	syscall
	.end_macro

# print the given int (has to give a register $)
.macro printInt(%int)
	li $v0, 1
	move $a0, %int
	syscall
	.end_macro

# call read integer, integer will be in $v0 and must be moved after this call
.macro getInt
	li $v0, 5
	syscall
	.end_macro

# random number generator given a range (has to be a literal integer, not a register)
# random int is stored in $a0, needs to be moved after this call
.macro getRandom(%max)
	li $v0, 42  
	li $a1, %max   
	syscall
	.end_macro

# exit the program	
.macro exitProgram
	li $v0, 10
	syscall
	.end_macro
