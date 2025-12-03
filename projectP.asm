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

# William
	# feel free to delete/change, this is mainly for testing to see if the counter works
displayString: .asciiz "Player has: "
newLine: .asciiz "\n"
displayStringDealer: .asciiz "Dealer has: "
promptHitOrStand: .asciiz "Would you like to hit or stand?\n1.)Hit\n2.)Stand\n"
playerHits: .asciiz "Player Hits\nPlayer Count: "
dealerHits: .asciiz "Dealer Hits\nDealer Count: "
playerLoses: .asciiz "Player busts! Better luck next time!\n"
dealerLoses: .asciiz "Dealer busts! You win!\n"
playerWinner: .asciiz "You win this hand!\n"
dealerWinner: .asciiz "You lose this hand!\n"
	

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
	# j exit
	
# William
	# give a card after displaying blank cards.
	# after, display the card that was given
	# then, give a 2nd card
	# display that second card after
	# feel free to change/delete/add anything
playerCards:
	getRandomCard
	add $s2, $s2, $s0 # add to player total - used to compare to dealer's total count
	
	
	# display the card after the first hand
		# printInt($s0)
		# printSuit($s1)
	
	# second hand
	getRandomCard
	add $s2, $s2, $s0
	
	bgt $s2, 21, playerLose # over 21, player busts
	beq $s2, 21, playerWins
	
	printString(displayString)
	printInt($s2)
	printString(newLine)
	
dealerCards:
	# --- dealer only draws one card in the beginning ---
	getRandomCard
	add $s3, $s3, $s0 # add to dealers total
	
	# display the card after the first hand
		# printInt($s0)
		# printSuit($s1)
	
	printString(displayStringDealer)
	printInt($s3)
	printString(newLine)
	
	j promptSelection
	
playerCardSingular:
	getRandomCard
	add $s2, $s2, $s0
	
	# display the card
	printString(playerHits)
	printInt($s2)
	printString(newLine)
	
	bgt $s2, 21, playerLose # over 21, player busts
	
	j promptSelection
	
dealerCardSingular:
	getRandomCard
	add $s3, $s3, $s0
	
	# display the card
	printString(dealerHits)
	printInt($s3)
	printString(newLine)
	
	j dealerCheck
	
dealerCheck:
	# if the dealer total is less than 17, keep hitting until over 17
	blt $s3, 17, dealerCardSingular
	
	bgt $s3, 21, dealerLose # over 21, dealer busts
	
	# if the dealer is 17 or greater, show who wins
	bge $s3, 17, showResults

	
promptSelection:
	printString(promptHitOrStand)
	getInt
	move $s0, $v0
	
	# check input
	beq $s0, 1, playerCardSingular # player hits
	beq $s0, 2, dealerCheck # if player stands, check dealers hand
	
showResults:
	printString(displayString)
	printInt($s2)
	printString(newLine)
	
	printString(displayStringDealer)
	printInt($s3)
	printString(newLine)
	
	bgt $s2, $s3, playerWins
	bgt $s3, $s2, dealerWins
	
playerLose:
	printString(playerLoses)
	j exit
		
dealerLose:
	printString(dealerLoses)
	j exit
		
playerWins:
	printString(playerWinner)
	j exit
		
dealerWins:
	printString(dealerWinner)
	j exit
	

exit:
	printString(exitString)
	exitProgram
	
	
