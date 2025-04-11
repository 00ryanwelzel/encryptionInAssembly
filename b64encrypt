.data
	# Actual information
	input: .asciiz "hello world!"
	input_len: .word 12
	b64lookuptable: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	pad_char: .asciiz "="

	# Formatting
	input_prompt: .asciiz "Original Text: \n"
	encoded_prompt: .asciiz "Encoded Text: \n"
	
	nl: .ascii "\n"


.text
.globl main

main:
	li $v0, 4
	la $a0, input_prompt  # display the original text prompt
	syscall
	
	la $a0, input  # display the original text
	syscall
	
	la $a0, nl  # newline
	syscall
	
	la $a0, input  # load input address
	la $a1, input_len  # load input length address
	la $a2, b64lookuptable  # load lookup table address
	
	jal b64enc
	
	move $t0, $v0  # store address of encoded string
	
	li $v0, 4
	la $a0, encoded_prompt  # display the encoded text prompt
	syscall
	
	move $a0, $t0  # display the encoded text
	syscall
	
	li $v0, 10  # end of program
	syscall
	

# ----------------------------------------------------------------------------------------
# a0 contains input address, a1 contains input size address, a2 contains b64 table address
# ----------------------------------------------------------------------------------------
b64enc:
	addi $sp, $sp, -20
	sw $ra, 0($sp)  # store return address
	sw $a0, 4($sp)  # store input address
	sw $a1, 8($sp)  # store input length address
	sw $a2, 12($sp)  # store lookup table address
	
	lw $a0, 8($sp)  # a0 contains input length address
	lw $a0, 0($a0)  # a0 contains input length
	
	jal calc_heap_size
	
	move $s0, $v0  # s0 contains output size
	
	lw $a0, 8($sp)  # a0 contains input length address
	lw $a0, 0($a0)  # a0 contains input length
	
	jal calc_pad_size
	
	move $s1, $v0  # s1 contains # of padding bytes
	
	li $v0, 9
	move $a0, $s0
	syscall  # allocate memory for output
	
	sw $v0, 16($sp)  # store output address

init_encrypt_block_loop:
	lw $a0, 4($sp)  # a0 contains the input address
	lw $a1, 16($sp)  # a1 contains the output address
	lw $a2, 12($sp)  # a2 contains the b64 table address
	add $s2, $zero, $zero  # s2 contains input iterator (i)
	add $s3, $zero, $zero  # s3 contains output iterator (j)
	
# this loop works per block not per character
# input block = 3 characters, output block = 4 characters
encrypt_block_loop:
	add $t0, $a0, $s2  # get address of inchar1
	lb $t0, 0($t0)  # inchar1
	
	addi $s2, $s2, 1  # i++
	
	add $t1, $a0, $s2  # get address of inchar2
	lb $t1, 0($t1)  # inchar2
	
	addi $s2, $s2, 1  # i++
	
	add $t2, $a0, $s2  # get address of inchar3
	lb $t2, 0($t2)  # inchar3
	
	addi $s2, $s2, 1  # i++
	
	
	srl $t4, $t0, 2  # 6 most significant bits of inchar1
	
	add $t4, $t4, $a2  # address of corresponding b64 char 
	lb $t4, 0($t4)  # outchar1
	
	add $t5, $a1, $s3  # address of next open slot in output string
	sb $t4, 0($t5)  # store outchar1
	
	addi $s3, $s3, 1  # j++
	
	
	sll $t4, $t0, 30  # 2 least significant bits of inchar1
	srl $t4, $t4, 26  # move bits into place
	srl $t5, $t1, 4  # 4 most significant bits of inchar2
	or $t4, $t4, $t5  # combine the two
	
	add $t4, $t4, $a2  # address of corresponding b64 char
	lb $t4, 0($t4)  # outchar2
	
	add $t5, $a1, $s3  # address of next open slot in output string
	sb $t4, 0($t5)  # store outchar2
	
	addi $s3, $s3, 1  # j++
	
	
	sll $t4, $t1, 28  # 4 least significant bits of inchar2
	srl $t4, $t4, 26  # move bits into place
	srl $t5, $t2, 6  # 2 most significant bits of inchar3 
	or $t4, $t4, $t5  # combine the two
	
	add $t4, $t4, $a2  # address of corresponding b64 char
	lb $t4, 0($t4)  # outchar3
	
	add $t5, $a1, $s3  # address of next open slot in output string
	sb $t4, 0($t5)  # store outchar3
	
	addi $s3, $s3, 1  # j++
	
	
	sll $t4, $t2, 26  # 6 least significant bits of inchar3
	srl $t4, $t4, 26  # move bits into place
	
	add $t4, $t4, $a2  # address of corresponding b64 char
	lb $t4, 0($t4)  # outchar4
	
	add $t5, $a1, $s3  # address of next open slot in output string
	sb $t4, 0($t5)  # store outchar4
	
	addi $s3, $s3, 1  # j++
	
	blt $s3, $s0, encrypt_block_loop  # if output isnt full, repeat
	sll $zero, $zero, 0
	
init_insert_padding_loop:
	addi $s2, $s0, -1  # s2 contains index of last char in output
	sub $s3, $s2, $s1  # s3 contains index of last non-padding char in output

insert_padding_loop:
	beq $s2, $s3, b64enc_return  # break on s2 = s3
	sll $zero, $zero, 0
	
	add $t0, $s2, $a1  # address of last character in output
	
	lb $t1, pad_char  # load padding character
	sb $t1, 0($t0)  # replace corresponding character
	
	addi $s2, $s2, -1  # last char index --
	
	j insert_padding_loop
	
b64enc_return:
	move $v0, $a1  # set return value
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	addi $sp, $sp, 20
	
	jr $ra
	

# ----------------------
# a0 contains input size
# ----------------------
calc_heap_size:
	addi $t0, $zero, 3  # t0 contains block size
	addi $t1, $zero, 2  # t1 contains a truncating value
	addi $t2, $zero, 4  # t2 contains encrypted block size
	
	div $a0, $t0
	mflo $t3  # t2 contains len / 3
	mfhi $t4  # t3 contains len % 3
	
	mult $t2, $t3
	mflo $v0  # restore number of blocks within input
	
	div $t4, $t1  # if t3 is 1 or 2, one of the below values will be 1
	mflo $t3  # t2 contains t3 / 3
	mfhi $t4  # t3 contains t3 % 3
	
	or $t3, $t3, $t4  # ensure a value of 1
	
	mult $t3, $t2  # adjust the value by block size
	mflo $t3
	
	add $v0, $v0, $t3  # return number of blocks + extra block if its needed
	
	jr $ra
	
# ----------------------
# a0 contains input size
# ----------------------
calc_pad_size:
	addi $t0, $zero, 3  # t0 contains block size
	
	div $a0, $t0
	mfhi $t1  # obtain number of characters outside of block size
	
	sub $t1, $t0, $t1  # subtract outside num from block size
	
	div $t1, $t0
	mfhi $t1  # if result is 3 or 0, ignore
	
	move $v0, $t1  # return result
	
	jr $ra
