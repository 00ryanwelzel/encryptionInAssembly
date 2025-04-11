.data
	# Actual information
	input: .asciiz "HELLOWORLD"  # (only use capital letters)
	shift_value: .word 3
	uppercase_alphabet: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	# Formatting
	input_prompt: .asciiz "Original Text: \n"
	encoded_prompt: .asciiz "Encoded Text: \n"
	
	nl: .asciiz "\n"

.text
.globl main

main:
	li $v0, 4
	la $a0, input_prompt  # print input prompt
	syscall
	
	la $a0, input  # print input
	syscall
	
	la $a0, nl  # newline
	syscall
	
	la $a0, encoded_prompt  # print encoded prompt
	syscall
	
	la $a0, input  # instantiate a0 for cypher
	la $a1, shift_value  # instantiate a1 for cypher
	la $a2, uppercase_alphabet  # instantiate a2 for cypher
	jal caesar_cypher
	
	li $v0, 10  # end of program
	syscall
	
	
# a0 contains input addr, a1 contains shift addr, a2 contains alphabet addr
caesar_cypher:
	addi $sp, $sp, -20
	sw $ra, 0($sp)  # store return addr
	sw $a0, 4($sp)  # store input addr
	sw $a1, 8($sp)  # store shift addr
	sw $a2, 12($sp)  # store alphabet addr

	add $s0, $zero, $zero  # s0 contains i
	
caesar_cypher_loop:
	lw $a0, 4($sp)  # restore a0
	lw $a1, 8($sp)  # restore a1
	lw $a2, 12($sp)  # restore a2
	
	add $t0, $s0, $a0  # input[i] addr
	lb $t0, 0($t0)  # input[i]
	
	beqz $t0, caesar_cypher_return  # if input[i] is null, return
	sll $zero, $zero, 0
	
	lw $a0, 12($sp)  # set a0 to alphabet addr for find char func
	move $a1, $t0  # set a1 to char for find char function
	
	jal find_char_index
	
	move $t0, $v0  # t0 contains char index
	
	lw $a1, 8($sp)  # get shift addr
	lw $t1, 0($a1)  # get shift
	
	add $t0, $t0, $t1  # shift char index
	
	addi $t1, $zero, 26  # length of alphabet
	div $t0, $t1  # divide shifted index by length
	mfhi $t0  # obtain shifted index % length for wrapping
	
	add $t0, $t0, $a2  # alphabet[index] addr
	lb $a0, 0($t0)  # alphabet[index]
	
	li $v0, 11  # print alphabet[index]
	syscall
	
	addi $s0, $s0, 1  # i++
	j caesar_cypher_loop
	
caesar_cypher_return:
	lw $ra, 0($sp)  # restore return addr
	addi $sp, $sp, 20
	jr $ra  # return
	

#a0 contains alphabet addr, a1 contains char to find	
find_char_index:
	add $s1, $zero, $zero  # s0 contains i
	
find_char_index_loop:
	add $t0, $a0, $s1  # alphabet[i] addr
	lb $t0, 0($t0)  # alphabet[i]
	
	beq $t0, $a1, find_char_index_return  # alphabet[i] == char, return
	sll $zero, $zero, 0
	
	addi $s1, $s1, 1  # i++
	
	j find_char_index_loop  # reiterate
	
find_char_index_return:
	move $v0, $s1  # set return value to index
	jr $ra  # return
	
