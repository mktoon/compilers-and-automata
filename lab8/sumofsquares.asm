# This is a MIPS code that calculates the sum of squres starting from 0 to a user specified number
# It initializes counting (i) and accumulatin(s) var in main
#Loop L1 - calculates square of current i and and adds to s until (i <= user input) then terminates and prints the sum
#       Micah Too
#       Lab 8
#       04/01/2023

.text
main:
        # Increasing activation record by one word to accomodate user input
        addi $sp, $sp, -16

        # Save return address and previous stack pointer
        sw $ra, 4($sp)
        sw $sp, 8($sp)

        # Prompt user for input
        li $v0, 4
        la $a0, userInput
        syscall

        # Read user input
        li $v0, 5
        syscall
        move $t0, $v0                   # Move user input to register $t0

        # Initialize counting and accumulating variables
        sw $0, 12($sp)                  # Counting variable i
        sw $0, 16($sp)                  # Accumulating variable s
 
L1:
        # Calculate square of i and add to s
        lw $t1, 12($sp)                 # i
        mul $t2, $t1, $t1               # i * i
        lw $t3, 16($sp)                 # s
        addu $t4, $t3, $t2              # s + i*i
        sw $t4, 16($sp)                 # s = s + i*i 
        
        # Increment i and check if we've reached user input
        lw $t1, 12($sp)                 # i 
        addiu $t5, $t1, 1               # i + 1
        sw $t5, 12($sp)                 # i = i + 1
        ble $t5, $t0, L1                # Keep looping until i <= user input

        # Printing the  result
        li $v0, 4
        la $a0, sum
        syscall
        li $v0, 1
        lw $a0, 16($sp)
        syscall

.data
userInput:
        .asciiz "Enter a value here: "
sum:
        .asciiz "The sum of squares from 0 to user Input is: "
