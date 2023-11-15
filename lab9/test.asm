# MIPS CODE GENERATE by Compilers class

.data

_L0: .asciiz	 "inside f"
_L1: .asciiz	 "\n"
_L2: .asciiz	 "\nshould have written 3\n"
.align 2
x4: .space 400 # global variable
.text


.globl main


f:				# function definition
	move $a1, $sp		# Activation Record carve out copy SP
	subi $a1 $a1 20		# Activation Record carve out copy size of function
	sw $ra , ($a1)		# Store Return address 
	sw $sp 4($a1)		# Store the old Stack pointer
	move $sp, $a1		# Make SP the current activation record


	sw $t0 8($sp)		# Paramater store start of function
	sw $t1 12($sp)		# Paramater store start of function


	la $a0, _L0		# The string address
	li $v0, 4		# About to print a string
	syscall			# call write string


	move $a0 $sp		# VAR local make a copy of stackpointer
	addi $a0 $a0 8		# VAR local stack pointer plus offset
	lw $a0, ($a0)		# Expression is a VAR
	li $v0, 1		# About to print a number
	syscall			# call write number


	la $a0, _L1		# The string address
	li $v0, 4		# About to print a string
	syscall			# call write string


	move $a0 $sp		# VAR local make a copy of stackpointer
	addi $a0 $a0 8		# VAR local stack pointer plus offset
	lw $a0, ($a0)		# Expression is a VAR
	sw $a0, 16($sp)		# expression store LHS temporarily
	li $a0, 1		# expression is a constant
	move $a1, $a0		# #right hand side needs to be a1
	lw $a0, 16($sp)		# expression restore LHS from memory
	add $a0, $a0, $a1		# #EXPR ADD
	lw $ra ($sp)		# restore old environment RA
	lw $sp 4($sp)		# Return from function store SP

	jr $ra			# return to the caller
	li $a0, 0		# RETURN has no specified value set to 0
	lw $ra ($sp)		# restore old environment RA
	lw $sp 4($sp)		# Return from function store SP

	jr $ra			# return to the caller

			# END OF FUNCTION



main:				# function definition
	move $a1, $sp		# Activation Record carve out copy SP
	subi $a1 $a1 24		# Activation Record carve out copy size of function
	sw $ra , ($a1)		# Store Return address 
	sw $sp 4($a1)		# Store the old Stack pointer
	move $sp, $a1		# Make SP the current activation record




			# Setting Up Function Call
			# evaluate  Function Parameters
	li $a0, 2		# expression is a constant
	sw $a0, 16($sp)		# Store call Arg temporarily

	li $a0, 3		# expression is a constant
	sw $a0, 12($sp)		# Store call Arg temporarily

			# place   Parameters into T registers
	lw $a0, 16($sp)		# pull out stored  Arg 
	move $t0, $a0		# move arg in temp 
	lw $a0, 12($sp)		# pull out stored  Arg 
	move $t1, $a0		# move arg in temp 

	jal f			# Call the function


	sw $a0 20($sp)		# Assign store RHS temporarily
	move $a0 $sp		# VAR local make a copy of stackpointer
	addi $a0 $a0 8		# VAR local stack pointer plus offset
	lw $a1 20($sp)		# Assign get RHS temporarily
	sw $a1 ($a0)		# Assign place RHS into memory
	move $a0 $sp		# VAR local make a copy of stackpointer
	addi $a0 $a0 8		# VAR local stack pointer plus offset
	lw $a0, ($a0)		# Expression is a VAR
	li $v0, 1		# About to print a number
	syscall			# call write number


	la $a0, _L2		# The string address
	li $v0, 4		# About to print a string
	syscall			# call write string


	li $a0, 0		# RETURN has no specified value set to 0
	lw $ra ($sp)		# restore old environment RA
	lw $sp 4($sp)		# Return from function store SP

	li $v0, 10		# Exit from Main we are done
	syscall			# EXIT everything

			# END OF FUNCTION



