.data
	# Actual information
	cyphertext: .asciiz "hello world!"
	key: .asciiz "mips"

	# Formatting
	input_prompt: .asciiz "Original Text: \n"
	output_prompt: .asciiz "Encrypted / Decrypted Text: \n"
	binary_output_prompt: .asciiz "Encrypted / Decrypted Text in Binary (as some characters might not be visible): \n"
	
	nl: .ascii "\n"


.text
.globl main

main:
	li $v0, 4
	la $a0, input_prompt  # print input prompt
	syscall
	
	la $a0, cyphertext  # print original text
	syscall
	
	la $a0, nl  # newline
	syscall
	
	la $a0, cyphertext  # load cyphertext address for encrypt / decrypt
	la $a1, key  # load key address for encrypt /  decrypt
	
	jal xor_enc_dec_init  # encrypt / decrypt
	
	la $v0, 4
	la $a0, output_prompt  # print output prompt
	syscall
	
	la $a0, cyphertext  # print encrypted / decrypted text
	syscall
	
	la $a0, nl  # newline
	syscall
	
	la $a0, binary_output_prompt  # print binary output prompt
	syscall
	
	la $a1, cyphertext  # load cyphertext address for binary printing
	jal print_binary_init
	
	li $v0, 10
	syscall	

	
# -------------------------------------------------------	
# a0 contains cyphertext address, a1 contains key address
# s0 contains cyphertext index, s1 contains key index
# -------------------------------------------------------
xor_enc_dec_init:
	add $s0, $zero, $zero  # cyphertext i = 0
	add $s1, $zero, $zero  # key i = 0
	
xor_enc_dec:
	add $t0, $a0, $s0  # t0 contains yphertext[i] addr
	add $t1, $a1, $s1  # t1 contains key[i] addr
	 
	lb $t2, 0($t0)  # cyphertext[i]
	lb $t3, 0($t1)  # key[i]
	
	beqz $t2, xor_enc_dec_return  # return on cyphertext[i] == ascii char 0
	sll $zero, $zero, 0
	
	beqz $t3, reset_key_iter  # wrap key on key[i] == ascii char 0
	sll $zero, $zero, 0
	
	xor $t4, $t2, $t3  # xor cyphertext[i] and key[i]
	
	sb $t4, 0($t0)  # cyphertext[i] = xor[i]
	
	addi $s0, $s0, 1  # cyphertext i++
	addi $s1, $s1, 1  # key i++
	
	j xor_enc_dec  # loop
	
reset_key_iter:
	add $s1, $zero, $zero  # reset key i
	j xor_enc_dec  # loop
	
xor_enc_dec_return:
	jr $ra  # return
	

# ------------------------------
# a1 contains cyphertext address
# s0 contains cyphertext index
# ------------------------------
print_binary_init:
	add $s0, $zero, $zero  # cyphertext i = 0
	
print_binary:
	add $t0, $a1, $s0  # cyphertext[i] addr
	lb $t0, 0($t0)  # cyphertext[i]
	
	beqz $t0, print_binary_return  # return on cyphertext[i] == ascii char 0
	sll $zero, $zero, 0
	
	li $v0, 1  # integer syscall
	
	srl $t1, $t0, 7
	move $a0, $t1  # print bit 0
	syscall
	
	sll $t1, $t0, 25
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 1
	syscall
	
	sll $t1, $t0, 26
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 2
	syscall
	
	sll $t1, $t0, 27
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 3
	syscall
	
	sll $t1, $t0, 28
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 4
	syscall

	sll $t1, $t0, 29
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 5
	syscall
	
	sll $t1, $t0, 30
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 6
	syscall
	
	sll $t1, $t0, 31
	srl $t1, $t1, 31
	move $a0, $t1  # print bit 7
	syscall
	
	addi $s0, $s0, 1  # cyphertext i++
	
	j print_binary  # loop

print_binary_return:
	jr $ra  # return





