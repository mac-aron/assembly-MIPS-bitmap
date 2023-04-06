# file name: AE_SCC150_coursework.asm
# 
# the following code was designed and written by Aron Eggens
# file was edited and assembled using MARS, MIPS Assembler and Runtime Simulator, an open-source software
# last edited on Feb 19, 2021

.data 			# references to store items in the next available addresses
info_menu: 		.asciiz "\nOptions:	Colours:	Direction:\n1 - CLS		1 - red		1 - north\n2 - row		2 - orange	2 - east\n3 - col		3 - yellow	3 - south\n4 - logo	4 - green	4 - west\n5 - exit	5 - blue	5 - back to options\nSelect an option: "
option: 		.byte
option_response: 	.asciiz "You selected option: "
invalid_option:		.asciiz "You did not select a valid option.\n"
colour:			.byte 
cls_response: 		.asciiz "You selected CLS. Select colour: "
invalid_colour:		.asciiz "You selected a value outside the given range.\n"
row_response: 		.asciiz "You selected row. Enter latitude: "
latitude:		.byte
col_response:		.asciiz "You selected column. Enter longitude: "
longitude: 		.byte
logo_response: 		.asciiz "You selected logo.\n"
direction_prompt:	.asciiz "Enter direction or back to options: "
lenght_prompt:		.asciiz "Enter lenght: "
logo_direction:		.byte
logo_lenght:		.byte
exit_response: 		.asciiz "You exited."

.text 				
j main			# jump uncoditionally to main

main:			# label
j select_menu		# jump unconditionally to select_menu	

select_menu:				# label
	addi $v0, $zero, 4		# load syscall argument to print string
	la $a0, info_menu		# load address of info_menu in $a0
	syscall				# issue a system call

	la $a0, option 			# load address of option in $a0
	li $v0, 5			# load syscall argument to read integer
	syscall				# issue a system call
	add $t1, $v0, $zero		# copy the user input into $a0 (option)

    	beq $t1, 1, cls			# branch to redirect to the appropriate option
    	beq $t1, 2, row
    	beq $t1, 3, col
    	beq $t1, 4, logo
    	beq $t1, 5, exit
    	bgt $t2, 5, option_error	# if user inputs a value greater than 5, display an error message
	blt $t2, 1, option_error	# if user inputs a value less than 1, display an error message
    	
    	option_error:				# label
    		li $v0, 4			# load syscall argument to print string
		la $a0, invalid_option		# load address of invalid_option in $a0
		syscall				# issue a system call
		j select_menu			# jump to the select_menu
	
cls:
	li $v0, 4			# load syscall argument to print string
	la $a0, cls_response		# load address of cls_option in $a0
	syscall				# issue a system call

	la $a0, colour 			# load address of colour in $a0
	li $v0, 5			# load syscall argument to read integer
	syscall				# issue a system call
	add $t2, $v0, $zero		# copy the user input into $t2
	
	beq $t2, 1, red			# if $t2 = 1, select red
	beq $t2, 2, orange		# if $t2 = 2, select orange
	beq $t2, 3, yellow		# if $t2 = 3, select yellow
	beq $t2, 4, green		# if $t2 = 4, select green
	beq $t2, 5, blue		# if $t2 = 5, select blue
	bgt $t2, 5, colour_error	# if $t2 > 5, display colour_error message
	blt $t2, 1, colour_error	# if $t2 < 5, display colour_error message
	
	red:	li $t3, 0xFF0000 	# red
		j execute
	orange:	li $t3, 0xFFA500 	# orange
		j execute
	yellow:	li $t3, 0xFFFF00 	# yellow
		j execute
	green: 	li $t3, 0x008000 	# green
		j execute		
	blue:	li $t3, 0x0000FF 	# blue
		j execute
	
	execute:
		lui $s0,0x1004 			# bitmap display base address in $s0
		addi $t0,$s0,0 			#initialise $t0 to base address, will count
		lui $s1,0x100C 			#end of screen area in $s1
		
		draw_cls: 				# label
			sw $t3,0($t0) 			# store colour $t3 in current target address
			addi $t0,$t0,4 			# increment $t0 by one word
			bne $t0,$s1,draw_cls		# if haven’t reached the target yet, go back to draw_cls
	
		j select_menu				# after the loop exits, jump back to select_menu
	
	colour_error:				# label
		li $v0, 4			# load syscall argument to print string
		la $a0, invalid_colour		# load address of invalid_colour in $a0
		syscall				# issue a system call
		j select_menu			# jump back to the select_menu
	
row:				# label
	li $a0, 0		# flush registers
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t9, 0
	
	li $v0, 4		# load syscall argument to print string
	la $a0, row_response	# load address of row_response in $a0
	syscall			# issue a system call
	
	la $a0, latitude 	# load address of latitude in $a0
	li $v0, 5		# load syscall argument to read integer
	syscall			# issue a system call
	
	add $t3, $v0, $zero	# copy the user input into $t3
	
	li $t9, 0xFFFFFF 	# store white colour in $t9
	li $t1, 0x10040000 	# bitmap display base address stored in $t1
	
	mul $t3, $t3, 2048	# multiply the user input by 2048 (4*512)
	
	addu $t5, $t1, $t3	# add the base address to the $t3, this defines the starting point
		
	draw_pixel_row:					# label
		sw $t9, 0($t5) 				# store colour $t9 in current target address
		addi $t5, $t5, 4			# increment $t5 by one word
		addi $t4, $t4, 1			# loop counter
		bne $t4, 512, draw_pixel_row		# if haven’t reached the target yet, go back to draw_pixel_row
	
	j select_menu		# jump back to the select_menu

col:				# label
	li $a0, 0		# flush registers
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t9, 0
	
	li $v0, 4		# load syscall argument to print string
	la $a0, col_response	# load address of col_response in $a0
	syscall			# issue a system call

	la $a0, longitude 	# load address of longitude in $a0
	li $v0, 5		# load syscall argument to read integer
	syscall			# issue a system call
	add $t2, $v0, $zero	# copy the user input into $t2 (option)
	
	li $t9, 0xFFFFFF 	# store white colour in $t9	
	li $t1, 0x10040000 	# bitmap display base address in $t1
	
	starting_point_col:				# label, use an addition loop as a way to multiply the user input by 4
		addi $t3, $t3, 4			# add 4 to $t3
		addi $t4, $t4, 1			# loop counter
		bne  $t4, $t2, starting_point_col	# if haven't reached the target yet, go back to starting_point_col
	
	addu $t5, $t3, $t1	# add the base address to the $t3, this defines the starting point

	draw_pixel_col: 				# label
		sw $t9, 0($t5) 				# store colour $t9 in current target address
		addi $t5, $t5, 2048 			# increment $t5 by one line (4*512)
		addi $t0, $t0, 1			# loop counter
		bne $t0, 512, draw_pixel_col		# if haven’t reached the target yet, go back to draw_pixel_col

	j select_menu		#jump back to select_menu

logo:				# label
	li $a0, 0		# flush registers
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t9, 0
		
	addi $v0, $zero, 4	# load syscall argument to print string
	la $a0, logo_response	# load address of logo_response in $a0
	syscall			# issue a system call
	
	li $t9, 0xFFFFFF 	# store white colour in $t9
	li $t1, 0x10040000	# bitmap display base address in $t1
	
	draw:			# label
		li $t0, 0				# flush register $t0, counter
		
		addi $v0, $zero, 4			# load syscall argument to print string
		la $a0, direction_prompt		# load address of direction_prompt in $a0
		syscall					# issue a system call
		
		la $a0, logo_direction 			# load address of logo_direction in $a0
		li $v0, 5				# read integer
		syscall					# issue a system call
		addi $t3, $v0, 0			# load direction in $t3
		
		beq $t3, 5, select_menu			# if $t3 = 5, exit to the main menu
		
		addi $v0, $zero, 4			# load syscall argument to print string
		la $a0, lenght_prompt			# load address of lenght_prompt in $a0
		syscall					# issue a system call
	
		la $a0, logo_lenght 			# load address of option in $a0
		li $v0, 5				# load syscall argument to read integer
		syscall					# issue a system call
		addi $t2, $v0, 0			# load lenght in $t1
		
		beq $t3, 1, north			# branch to redirect to the appropriate direction
    		beq $t3, 2, east
    		beq $t3, 3, south
    		beq $t3, 4, west
    		bgt $t3, 5, option_error		# if user inputs a value greater than 5, display an error message
		blt $t3, 1, option_error		# if user inputs a value less than 1, display an error message
		
    		north:						# label
			sw $t9, 0($t1)				# store colour $t9 in current target address
			sub $t1, $t1, 2048			# increment $t1 by one line (4*512), subtraction to go left
			addi $t0, $t0, 1			# loop counter
			bne $t0, $t2, north			# if haven’t reached the target yet, go back to north
			j draw					# jump back to draw

		east:						#label
			sw $t9, 0($t1) 				#store colour $t9 in current target address
			addi $t1, $t1, 4			# increment $t1 by one word
			addi $t0, $t0, 1			# counter loop
			bne $t0, $t2, east			# if haven’t reached the target yet, go back to east
			j draw					# jump back to draw
		
		south:						# label
			sw $t9, 0($t1)				# store colour $t9 in current target address
			addi $t1, $t1, 2048			# increment $t1 by one line (4*512), addition to go right
			addi $t0, $t0, 1			# loop counter
			bne $t0, $t2, south			# if haven’t reached the target yet, go back to south
			j draw					# jump back to draw
		
		west:
			sw $t9, 0($t1) 				#store colour $t9 in current target address
			sub $t1, $t1, 4				# increment $t1 by one word
			addi $t0, $t0, 1			# counter loop
			bne $t0, $t2, west			# if haven’t reached the target yet, go back to west
			j draw					# jump back to draw

exit:	
	nop 			# all machine code set to zero
	
	li $v0, 4		# load syscall argument to print string
	la $a0, exit_response	# load address of exit_response in $a0
	syscall			# issue system call
	
	li $v0, 10		# load syscall argument to exit (terminate execution)
	syscall			# issue system call
	
	
	
# end of AE_SCC150_coursework.asm
