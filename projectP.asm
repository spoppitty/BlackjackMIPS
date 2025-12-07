# Group 2: Aaronn Mach, Kellan Young, Sarah Liu, William Tu
# CS2640.02
# 12/7/2025
# MIPS Assembly Final Project

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
askAgainString: .asciiz "\nWould you like to play again?\nPress (1) for yes\nPress (2) to exit\n"
noMoneyString: .asciiz "\nYou have no more money!"

currentString: .asciiz "\nYou currently have: "
coinString: .asciiz " coins"
betString: .asciiz "\nHow much would you like to bet? "

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
pushDrawPrompt: .asciiz "Push! Neither wins!\n"
	
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

	li $t4, 0x001C7A3C   	# $t4 = board color (dark green)
	
	# initialize coin count
	li $s7, 100

# fill/reset board with dark green
fill_board:
	beq $t3, $zero, menuSelection  # if no pixels left, finish

	sw $t4, 0($t0)       # store color at current address
	addi $t0, $t0, 4       # move to next unit 
	addi $t3, $t3, -1      # decrement unit counter
	j fill_board

# menu allows player to play or exit
menuSelection:
	# print menu
	printString(menuString)
	
	# get selection
	getInt
	move $s0, $v0
	
	# check input
	beq $s0, 1, passOutCards
	beq $s0, 2, exit
	printString(errorString)	# if input is not 1 or 2, try again
	j menuSelection

# pass out cards turned over before player makes bets
passOutCards:
	# pass out dealer's first card
	drawRect(4, 8, 13, 19, 0x00FFFFFF)
	drawRect(5, 9, 11, 17, 0x00FFA3B1)
	
	# pass out player's 2 cards
	drawRect(4, 37, 13, 19, 0x00FFFFFF)
	drawRect(5, 38, 11, 17, 0x00FFA3B1)
	# 2nd card
	drawRect(19, 37, 13, 19, 0x00FFFFFF)
	drawRect(20, 38, 11, 17, 0x00FFA3B1)

# allows players to bet their coins
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
	bgt $s6, $s7, invalidCoins	# if bet amount is greater than current amount
	bgez $s6, playerCards		# if bet amount is valid
	
	# if bet amount is negative or invalid
	invalidCoins:
		printString(errorString)
	
	j betSelection
	

# call the player's first 2 cards and display them
playerCards:
	# player has 2 cards
	li $s4, 2
	getRandomCard
	add $s2, $s2, $s0 # add to player total - used to compare to dealer's total count
	
	# display the card after the first hand
	drawRect(4, 37, 13, 19, 0x00FFFFFF)
	drawCardFace($s0, $s1, 4, 37)
	
	# second hand
	getRandomCard
	add $s2, $s2, $s0
	
	# display 2nd card
	drawRect(19, 37, 13, 19, 0x00FFFFFF)
	drawCardFace($s0, $s1, 19, 37)
	
	bgt $s2, 21, playerLose # over 21, player busts
	beq $s2, 21, playerWins
	
	printString(displayString)
	printInt($s2)
	printString(newLine)

# call the dealer's first card and display it
dealerCards:
	# --- dealer only draws one card in the beginning ---
	li $s5, 1
	getRandomCard
	add $s3, $s3, $s0 # add to dealers total
	
	# display the card after the first hand
	drawRect(4, 8, 13, 19, 0x00FFFFFF)
	drawCardFace($s0, $s1, 4, 8)
	
	printString(displayStringDealer)
	printInt($s3)
	printString(newLine)
	
	j promptSelection

# call 1 card for the player and display it	
playerCardSingular:
	addi $s4, $s4, 1
	getRandomCard
	add $s2, $s2, $s0
	
	# display the card
	printString(playerHits)
	printInt($s2)
	printString(newLine)
	
	beq $s4, 3, thirdPlayerCard
	bge $s4, 4, fourthPlayerCard
	
	thirdPlayerCard:
		drawRect(34, 37, 13, 19, 0x00FFFFFF)
		drawCardFace($s0, $s1, 34, 37)
		j continuePlayerSingular
	
	fourthPlayerCard:
		drawRect(49, 37, 13, 19, 0x00FFFFFF)
		drawCardFace($s0, $s1, 49, 37)
		j continuePlayerSingular
		
	continuePlayerSingular:
		bgt $s2, 21, playerLose # over 21, player busts
		beq $s2, 21, playerWins # 21, player wins
	
		j promptSelection

# call 1 card for the dealer and display it	
dealerCardSingular:
	addi $s5, $s5, 1
	getRandomCard
	add $s3, $s3, $s0
	
	# display the card
	printString(dealerHits)
	printInt($s3)
	printString(newLine)
	
	beq $s5, 2, secondDealerCard
	beq $s5, 3, thirdDealerCard
	bge $s5, 4, fourthDealerCard
	
	secondDealerCard:
		drawRect(19, 8, 13, 19, 0x00FFFFFF)
		drawCardFace($s0, $s1, 19, 8)
		j dealerCheck
	
	thirdDealerCard:
		drawRect(34, 8, 13, 19, 0x00FFFFFF)
		drawCardFace($s0, $s1, 34, 8)
		j dealerCheck
	
	fourthDealerCard:
		drawRect(49, 8, 13, 19, 0x00FFFFFF)
		drawCardFace($s0, $s1, 49, 8)
		j dealerCheck

# check the dealer's hand value
dealerCheck:
	# if the dealer total is less than 17, keep hitting until over 17
	blt $s3, 17, dealerCardSingular
	
	bgt $s3, 21, dealerLose # over 21, dealer busts
	
	# if the dealer is 17 or greater, show who wins
	bge $s3, 17, showResults

# ask player if they want to continue drawing or stand
promptSelection:
	printString(promptHitOrStand)
	getInt
	move $s0, $v0
	
	# check input
	beq $s0, 1, playerCardSingular # player hits
	beq $s0, 2, dealerCheck # if player stands, check dealers hand
	printString(errorString)	# if input is not 1 or 2, try again
	j promptSelection

# display the results, win or lose
showResults:
	printString(displayString)
	printInt($s2)
	printString(newLine)
	
	printString(displayStringDealer)
	printInt($s3)
	printString(newLine)
	
	beq $s2, $s3, pushDraw
	bgt $s2, $s3, playerWins
	bgt $s3, $s2, dealerWins
	
playerLose:
	resetBoard(0x009E1C1C)		# fill the board red
	sub $s7, $s7, $s6		# player loses their bet
	printString(playerLoses)
	j askAgain
		
dealerLose:
	resetBoard(0x0022B14C)		# fill the board green
	add $s7, $s7, $s6		# player wins their bet
	printString(dealerLoses)
	j askAgain
		
playerWins:
	resetBoard(0x0022B14C)		# fill the board green
	add $s7, $s7, $s6		# player wins their bet
	printString(playerWinner)
	j askAgain
		
dealerWins:
	resetBoard(0x009E1C1C)		# fill the board red
	sub $s7, $s7, $s6		# player loses their bet
	printString(dealerWinner)
	j askAgain

pushDraw:
	resetBoard(0x00B4B4B4)		# fill the board grey
	printString(pushDrawPrompt)	# player doesn't win or lose bet
	j askAgain
	
noMoreCoins:
	printString(noMoneyString)	# if player runs out of money, they can't play
	j exit

# ask to play again
askAgain:
	# check if player has money before asking to play again
	beq $s7, 0, noMoreCoins
	
	printString(askAgainString)
	getInt
	move $s0, $v0
	
	# check input
	beq $s0, 1, resetRegisters
	beq $s0, 2, exit
	printString(errorString)	# if input is not 1 or 2, try again
	j askAgain

# prepare registers for another game
resetRegisters:
	# reset player and dealer counters, and bet amount
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	resetBoard(0x001C7A3C)
	j passOutCards

# exit program and message
exit:
	printString(exitString)
	exitProgram
	
	
