# BlackjackMIPS

## CS2640.02 Final Project

Authors: Aaronn Mach, Kellan Young, Sarah Liu, William Tu

This project recreates the classic Blackjack card game using MIPS assembly, implementing the use of game logic, and bitmap display.

Overview:
The program simulates a simple version of Blackjack where the player competes against the dealer. It includes:
- Card generation
- Hand value calculation
- Game logic
- Dealer rules
- Win/lose conditions
- Coin system with betting
- Bitmap display card rendering

Features:
- Random card generation
    - card value (Ace-King) randomly selected
    - card suit (Diamonds, Clubs, Hearts, Spades) randomly selected
- Card name display
    - Handles face cards (Jack, Queen, King) and Ace
- Scorekeeping
    - Player's running total updates after each new card
    - Detects busts (score > 21)
- Player choices
    - After the first two cards, the player chooses whether to hit (draw another card) or stand (end turn)
- Win/lose Result Screen
- Coin System (Betting Feature)
    - Player begins with 100 coins
    - Before each round, the player is asked how much they want to bet
    - Cannot bet more than current coin balance or negative values
    - Win/loss updates coin balance accordingly
- Bitmap display

How It Works:
1. Menu
   - Enter 1 to start playing
   - Enter 2 to exit
   - If input invalid, redirect to error message and repeat menu

2. Betting
   - After first cards are drawn, the program displays:
     You currently have : <coins> coins
     How much would you like to bet?
     
2. Random Card Generation
   - uses macros to generate random card value (1-13) and random suit (1-4))
   - Special cases: Ace is displayed as "Ace", 11 is "Jack", 12 is "Queen", and 13 is "King"
     
3. Displaying cards
   - Each card is in the format: "Your card is the: King of Hearts"
   
4. Score Tracking
   - Each drawn card is added to the player's total and displayed on the screen
     
5. Player Choices
   - After the first two cards are drawn, the program gives the user the option:
   Would you like to hit another card?
   Press (1) for yes
   Press (2) for no
   
6. Results
   - Bases on the final score, if the player has a score:
   Score <= 21, then Player Wins
   Score > 21, then Player loses


Conclusion
This project demonstrates the use of MIPS Assembly to create a functional Blackjack game using system calls, macros, and bitmap graphics.
