# add your own tests for the full machine here!
# feel free to take inspiration from all.s and/or lwbr.s

.data
# your test data goes here
a: .word 0 1 2 4 8 16
array:	.word	1	255	1024

.text
main:
	# your test code goes here
	addi	$6, $0, 100					# $6  =   100 (0x64)	
	addi	$7, $6, 155					# $7  =   255 (0xff)
	add	$8, $6, $6						# $8  =   200 (0xc8)
	sub	$9, $7, $8						# $9  =    55 (0x37)
	sub	$10, $8, $7						# $10 =   -55 (0xffffffc9)
	add	$11, $8, $6						# $11 =   300 (0x12c)
	and	$12, $11, $7					# $12 =    44 (0x2c)
	or	$13, $10, $7					# $13 =    -1 (0xffffffff)
	xori	$14, $7, 0x5555 			# $14 = 21930 (0x55aa)
	sub	$15, $7, $13					# $15 =   256 (0x100)
	add	$16, $6, $13					# $16 =    99 (0x63)
	nor	$17, $15, $7					# $17 =  -512 (0xfffffe00)
	add	$18, $17, $15					# $18 =  -256 (0xffffff00)
	ori	$19, $7, 0xAAAA 				# $19 = 43775 (0xaaff)
