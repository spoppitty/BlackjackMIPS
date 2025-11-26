# Group 2: Aaronn Mach, Kellan Young, Sarah Liu, William Tu
# CS2640.02
# 11/26/2025
# MIPS Assembly Final Project

.include "macros.asm"

# constants for random number generator range
.eqv SUITRANGE, 4
.eqv NUMBERRANGE, 13

.data
ofString: .asciiz " of "
diamondString: .asciiz "Diamonds"
clubString: .asciiz "Clubs"
heartString: .asciiz "Hearts"
spadeString: .asciiz "Spades"
jackString: .asciiz "Jack"
queenString: .asciiz "Queen"
kingString: .asciiz "King"
aceString: .asciiz "Ace"

newLine: .asciiz "\n"
commaSpace: .asciiz ", "

.text
main:
	getRandom(NUMBERRANGE)
	move $t0, $a0
	
	getRandom(SUITRANGE)
	move $t1, $a0

numberCheck:
	beq $t0, 0, ifAce
	beq $t0, 10, ifJack
	beq $t0, 11, ifQueen
	beq $t0, 12, ifKing
	b numOther
	
ifAce:
	printString(aceString)
	j suitCheck

ifJack:
	printString(jackString)
	j suitCheck

ifQueen:
	printString(queenString)
	j suitCheck
	
ifKing:
	printString(kingString)
	j suitCheck

numOther:
	addi $t0, $t0, 1
	printInt($t0)
	j suitCheck

suitCheck:
	beq $t1, 0, ifDiamond
	beq $t1, 1, ifClub
	beq $t1, 2, ifHeart
	beq $t1, 3, ifSpade

ifDiamond:
	printString(ofString)
	printString(diamondString)
	j exit
	
ifClub:
	printString(ofString)
	printString(clubString)
	j exit
	
ifHeart:
	printString(ofString)
	printString(heartString)
	j exit
	
ifSpade:
	printString(ofString)
	printString(spadeString)
	j exit
	
exit: 
	exitProgram
	
	
