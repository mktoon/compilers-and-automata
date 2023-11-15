.text
main:
        # Increase activation record by one word
        addi $sp, $sp, -16

        # Save return address and previous stack pointer
        sw $ra, 4($sp)
        sw $sp, 8($sp)

        # Prompt user for input
        li $v0, 4
        la $a0, prompt
        syscall

        # Read user input
        li $v0, 5
        syscall
        move $t0, $v0  # Move user input to register $t0

        # Initialize counting and accumulating variables
        sw $0, 12($sp)  # Counting variable i
        sw $0, 16($sp)  # Accumulating variable s
 
loop:
        # Calculate square of i and add to s
        lw $t1, 12($sp)   # i
        mul $t2, $t1, $t1  # i * i
        lw $t3, 16($sp)   # s
        addu $t4, $t3, $t2  # s + i*i
        sw $t4, 16($sp)   # s = s + i*i 
        
        # Increment i and check if we've reached user input
        lw $t1, 12($sp)   # i 
        addiu $t5, $t1, 1  # i + 1
        sw $t5, 12($sp)   # i = i + 1
        bne $t5, $t0, loop # Keep looping until i == user input
        
        # Print result
        li $v0, 4
        la $a0, result
        syscall
        li $v0, 1
        lw $a0, 16($sp)
        syscall

        # Restore stack pointer and return
        lw $ra, 4($sp)
        lw $sp, 8($sp)
        jr $ra

.data
prompt:
        .asciiz "Enter a value here: "
result:
        .asciiz "The sum of squares is: "
