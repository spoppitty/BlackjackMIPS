# Group 2: Aaronn Mach, Kellan Young, Sarah Liu, William Tu
# CS2640.02
# 11/26/2025
# MIPS Assembly Final Project

.include "macros.asm"

# constants for random number generator range
.eqv SUITRANGE, 4
.eqv NUMBERRANGE, 13

.data
menuString: .asciiz "Would you like to play Blackjack?\nPress (1) for yes\nPress (2) to exit\n"
exitString: .asciiz "\nGG! Let's play again later!"
errorString: .asciiz "Error, try again"
cardString: .asciiz "Your card is the: "

ofString: .asciiz " of "
diamondString: .asciiz "Diamonds"
clubString: .asciiz "Clubs"
heartString: .asciiz "Hearts"
spadeString: .asciiz "Spades"
jackString: .asciiz "Jack"
queenString: .asciiz "Queen"
kingString: .asciiz "King"
aceString: .asciiz "Ace"

currentVal: .asciiz "Your current value is: "
againString: .asciiz "hit again is in development"

newLine: .asciiz "\n"
commaSpace: .asciiz ", "

.text
main:
	printString(menuString)
	getInt
	move $s0, $v0
	beq $s0, 1, getRandomCard
	beq $s0, 2, exit
	b error

# randomly generates a value and suit
getRandomCard:
	# gets a random number from 0-3
	getRandom(NUMBERRANGE)
	move $t0, $a0
	addi $t0, $t0, 1		# make the value in $t0 reflect the actual card
	add $s1, $s1, $t0	# current value counter that will be compared with 21
	addi $s2, $s2, 1		# counting how many cards we picked so far
	
	# get a random number from 0-12
	getRandom(SUITRANGE)
	move $t1, $a0
	addi $t1, $t1, 1		# make the value in $t0 reflect the actual card

	printString(cardString)

# check the value of the card
numberCheck:
	beq $t0, 1, ifAce
	beq $t0, 11, ifJack
	beq $t0, 12, ifQueen
	beq $t0, 13, ifKing
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
	printInt($t0)
	j suitCheck

# check the suit of the card
suitCheck:
	beq $t1, 1, ifDiamond
	beq $t1, 2, ifClub
	beq $t1, 3, ifHeart
	beq $t1, 4, ifSpade

ifDiamond:
	printString(ofString)
	printString(diamondString)
	j cardCounter
	
ifClub:
	printString(ofString)
	printString(clubString)
	j cardCounter
	
ifHeart:
	printString(ofString)
	printString(heartString)
	j cardCounter
	
ifSpade:
	printString(ofString)
	printString(spadeString)
	j cardCounter

cardCounter:
	printString(newLine)
	beq $s2, 1, getRandomCard
	
	printString(currentVal)
	printInt($s1)
	printString(newLine)
	
	bge $s2, 2, hitAgainQ

hitAgainQ:
	printString(againString)
	j exit

error:
	printString(errorString)
	j main
	
exit: 
	printString(exitString)
	exitProgram
	
	
