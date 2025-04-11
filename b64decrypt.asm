.data
	# Actual information
	input: .asciiz "aGVsbG8gd29ybGQh"
	input_len: .word 16
	b64lookuptable: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	pad_char: .asciiz "="

	# Formatting
	input_prompt: .asciiz "Original Text: \n"
	decoded_prompt: .asciiz "Decoded Text: \n"
	
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
	
	jal b64dec
	
	move $t0, $v0  # t0 contains output addr
	
	li $v0, 4
	la $a0, decoded_prompt  # display the decoded text prompt
	syscall
	
	move $a0, $t0  # display the decoded text
	syscall
	
	li $v0, 10  # end of program
	syscall
	
# ---------------------------------------------------------------------------------------------
# a0 contains input address, a1 contains input length address, a2 contains lookup table address
# ---------------------------------------------------------------------------------------------

b64dec:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	
	lw $a0, 4($sp)  # change a0 for pad
	lw $a1, 8($sp)  # change a1 for pad
	lb $a2, pad_char  # specify pad char
	
	jal calc_pad_size
	
	move $s0, $v0  # s0 contains pad char count
	
	lw $a0, 8($sp)  # change a0 for heap
	move $a1, $s0  # change a1 for heap
	
	jal calc_heap_size
	
	move $s1, $v0  # s1 contains output size
	
	li $v0, 9
	move $a0, $s1  # allocate output size # of bytes
	syscall
	
	sw $v0, 16($sp)  # 16sp contains output addr
	
decrypt:
	add $s2, $zero, $zero  # s2 contains output iter
	add $s3, $zero, $zero  # s3 contains input iter
	
# takes 4 input char converts to 3 output char
decrypt_loop:
	lw $a0, 4($sp)  # a0 contains input addr
	lw $a1, 16($sp)  # a1 contains output addr
	lw $a2, 12($sp)  # a2 contains lookup table addr

	add $t0, $a0, $s3  # inchar1 addr
	lb $t0, 0($t0)  # inchar1
	
	addi $s3, $s3, 1  # input iter++
	
	add $t1, $a0, $s3  # inchar2 addr
	lb $t1, 0($t1)  # inchar2
	
	addi $s3, $s3, 1  # input iter++
	
	add $t2, $a0, $s3  # inchar3 addr
	lb $t2, 0($t2)  # inchar3
	
	addi $s3, $s3, 1  # input iter++
	
	add $t3, $a0, $s3  # inchar4 addr
	lb $t3, 0($t3)  # inchar4
	
	addi $s3, $s3, 1  # input iter++
	
	add $s5, $zero, $zero  # reset index iter (i)
	lw $a0, 12($sp)  # a0 contains lookup table addr
	move $a1, $t0  # a1 contains char to find
	jal find_b64_index
	
	move $t0, $s5  # t0 contains char index
	
	add $s5, $zero, $zero  # reset index iter (i)
	lw $a0, 12($sp)  # a0 contains lookup table addr
	move $a1, $t1  # a1 contains char to find
	jal find_b64_index
	
	move $t1, $s5  # t1 contains char index
	
	add $s5, $zero, $zero  # reset index iter (i)
	lw $a0, 12($sp)  # a0 contains lookup table addr
	move $a1, $t2  # a1 contains char to find
	jal find_b64_index
	
	move $t2, $s5  # t2 contains char index
	
	add $s5, $zero, $zero  # reset index iter (i)
	lw $a0, 12($sp)  # a0 contains lookup table addr
	move $a1, $t3  # a1 contains char to find
	jal find_b64_index
	
	move $t3, $s5  # t3 contains char index
	
	lw $a1, 16($sp)  # reobtain output addr
	
	sll $t4, $t0, 2  # move inchar1 6 most significant bits
	srl $t5, $t1, 4  # get inchar2 2 least significant bits
	or $t4, $t4, $t5  # outhcar1
	
	add $t5, $a1, $s2  # addr of output[j]
	sb $t4, 0($t5)  # output[j] = outchar1 
	
	addi $s2, $s2, 1  # j++
	
	sll $t4, $t1, 28  # get inchar2 4 least significant bits
	srl $t4, $t4, 24  # move inchar2 4 least significant bits
	srl $t5, $t2, 2  # get inchar3 4 most significant bits
	or $t4, $t4, $t5  # outchar2
	
	add $t5, $a1, $s2  # addr of output[j]
	sb $t4, 0($t5)  # output[j] = outchar1 
	
	addi $s2, $s2, 1  # j++
	
	sll $t4, $t2, 30  # get inchar3 2 least significant bits
	srl $t4, $t4, 24  # move inchar3 2 least significant bits
	or $t4, $t4, $t3  # outchar3
	
	add $t5, $a1, $s2  # addr of output[j]
	sb $t4, 0($t5)  # output[j] = outchar1 
	
	addi $s2, $s2, 1  # j++
	
	lw $t5, 8($sp)  # addr of input_len
	lw $t5, 0($t5)  # input_len
	
	blt $s3, $t5, decrypt_loop  # if input iter < input len, repeat
	sll $zero, $zero, 0
	
b64dec_return:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $v0, 16($sp)  # v0 contains output addr
	
	addi $sp, $sp, 20
	
	jr $ra
	
	
# -------------------------------------------------------
# a0 contains lookup table addr, a1 contains char to find
# do not use t0 to t3 for temps
# -------------------------------------------------------
find_b64_index:
	la $t4, pad_char  # pad_char addr
	lb $t4, 0($t4)  # pad char
	
	beq $a1, $t4, is_pad_char  # if char to find == pad_char, break
	sll $zero, $zero, 0

	add $t4, $a0, $s5  # addr of lookup[i]
	lb $t4, 0($t4)  # lookup[i]
	
	beq $a1, $t4, find_b64_index_return  # if char to find == lookup[i], break
	sll $zero, $zero, 0
	
	# somewhere in here check if char == pad_car
	
	addi $s5, $s5, 1  # i++
	
	j find_b64_index  # reiterate
	
is_pad_char:
	add $s5, $zero, $zero  # pad_char value = 0
	jr $ra  # return
	
	
find_b64_index_return:
	jr $ra  # return
	
	
	
# ---------------------------------------------------------------------------
# a0 contains input address, a1 contains length address, a2 contains pad char
# ---------------------------------------------------------------------------
calc_pad_size:
	lw $s0, 0($a1)  # iter starts at last index
	add $s1, $s0, -4  # iter - block size
	add $s2, $zero, $zero # pad char counter
	
calc_pad_size_loop:
	add $t0, $s0, $a0  # get address of input[len-1]
	lb $t0, 0($t0)  # get char at input[len-1]
	
	beq $t0, $a2, inc_pad_counter  # if char == '=' pad counter++
	sll $zero, $zero, 0
	
	addi $s0, $s0, -1  # iter--
	
	bgt $s0, $s1, calc_pad_size_loop  # iter > iter - block size, repeat
	sll $zero, $zero, 0
	
calc_pad_size_exit:
	move $v0, $s2  # set return value to pad counter
	jr $ra  # return

inc_pad_counter:
	addi $s2, $s2, 1  # pad counter++
	addi $s0, $s0, -1  # iter--
	
	j calc_pad_size_loop  # repeat

# ------------------------------------------------------------
# a0 contains input length address, a1 contains pad char count
# ------------------------------------------------------------	
calc_heap_size:
	lw $t0, 0($a0)  # input length
	addi $t1, $zero, 3  # output block size
	
	srl $t0, $t0, 2  # number of blocks
	addi $t0, $t0, -1  # subtract 1 block because final block needs pad checks
	mult $t0, $t1  # convert to number of output characters
	mflo $t0
	
	sub $t1, $t1, $a1  # subtract block size by number of pad characters
	
	add $v0, $t0, $t1  # set return to adjusted char count
	
	jr $ra  # return
	
	


