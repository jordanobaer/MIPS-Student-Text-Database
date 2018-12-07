#main function. The user can select, insert,update from the database.

.data
	input: .space 50	#max characters for input string is 50
	hello_string: .asciiz "Welcome to the student database. The student information is located in the file: students.txt\0"
	select_string: .asciiz "What option do you want to perform in the database?\nAt this point just input one of the commands that are in upper case, for example if you want to add a person, enter:ADD \0"
	file_name: .asciiz "students.txt\0"
	student_input: .asciiz "Please enter the student information in order (e-mail, first and last name and UID)in one line\0"
	option_string:.asciiz "ADD:Add a student\nSHOW:Show file content\nSEARCH:Search for a person in the file\nREMOVE:Remove a person\nUPDATE:Update student information\nQUIT:Quit"

	file_buffer: .space 1000	#space for the content inside the file
	file_buffer2: .space 1000
	
	#search for name in file data:
	search_string: .asciiz "What is the e-mail of the person you are looking for in the file?"
	delete_name_string: .asciiz "What is the e-mail of the person you want to delete from the file?"
	update_name_string: .asciiz "What is the e-mail of the person you want to update from the file?"
	new_line_string: .asciiz "Enter the new line for that person (e-mail, first and last name and UID):"
	found_string: .asciiz "This person is in the file"
	removed_string: .asciiz "This person was removed from the file"
	added_string: .asciiz "This person was added to the file"
	not_found_string: .asciiz "This person is not in the file"
	search_name: .space 20	#space for the name that the user is searching for in the file
	new_line: .space 50	#space for the new line of a person
	search_email : .space 20 #space for the e-mail of the person
	
	ADD_string: .asciiz "ADD"
	SHOW_string: .asciiz "SHOW"
	SEARCH_string: .asciiz "SEARCH"
	REMOVE_string: .asciiz "REMOVE"
	UPDATE_string: .asciiz "UPDATE"
	user_command: .space 20
	
	#s0 = input string
	#s1 = file descriptor
	#s2 = file buffer
	#s3 = user option input
.text
	la $a0, hello_string
	li $v0, 4
	syscall		#print hello string
	
main_loop:
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, select_string
	li $v0, 4
	syscall		#print select string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, option_string
	li $v0, 4
	syscall		#print select string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	jal commands
	
	#li $v0, 5	#read integer
	#syscall
	
	
	addi $t1, $zero, 1
	addi $t2, $zero, 2
	addi $t3, $zero, 3
	addi $t4, $zero, 4
	addi $t5, $zero, 5
	
	add $s3, $v0, $zero 	#move input to $s3
	beq $s3, $t1, add_student
	beq $s3, $t2, show_file
	beq $s3, $t3, find_name
	beq $s3, $t4, delete_person
	beq $s3, $t5, update_line
	j Exit
	
	


###############################################################
#add a student to the end of the file		
add_student:	
	
	la $a0, student_input
	li $v0, 4
	syscall		#print student string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, input
	li $a1, 50	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	add $s0, $a0, $zero	#store the input string in s0

	#open file
	li $v0, 13    #open file
	la $a0, file_name #load file name
	li $a1, 9   #Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0  # mode
	syscall 
	move $s1, $v0 #save the file descriptor (needed to close the file)
	
	#write to file
	li   $v0, 15       # system call for write to file
 	move $a0, $s1      # file descriptor 
  	add $a1, $s0, $zero   # move user input to s0
  	
  	

#calculate the buffer length
	add $t1, $zero, $zero 	#t1 = i = 0
loop1: 
	add $t0, $s0, $t1			
	lb $t0, 0($t0)
	addi $t1, $t1, 1
	bne $t0, $zero, loop1 
    	
  	addi $t1, $t1, -1
  	add $a2, $t1, $zero      # buffer length = i
  	syscall            	# write to file
  	
  	la $a0, added_string
	li $v0, 4
	syscall		#print added string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line

  	# Close the file 
  	li   $v0, 16       # system call for close file
  	move $a0, $s1      # file descriptor to close
  	syscall            # close file
	j main_loop
###############################################################		
#Show the file content
show_file:
	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 0		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#clear the file_buffer
	
	la $t1, file_buffer	#t1 = buffer
	add $t2, $zero, $zero	#t2 = counter = 0
	addi $t3, $zero, 1000	#t3 = 1000
	
	#clear buffer before reading it
clear_buffer:
	sb $zero, 0($t1)	#filebuffer = 0
	addi $t1,$t1,1		#buffer++
	addi $t2, $t2,1		#counter++
	slt $t4, $t2, $t3	#counter < 1000
	bne $t4, $zero, clear_buffer 
	
	
	#read from file
	li $v0, 14		#read file
	move $a0, $s1		#load file descriptor
	la $a1, file_buffer	#address of input buffer
	li $a2, 1000		#max number of characters to read
	syscall
	
	#print file
	li $v0, 4	#print string
	la $a0, file_buffer	#address of string
	syscall

	# Close the file 
  	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	j main_loop
###############################################################	
#Search for a name in the file	
find_name:

	la $a0, search_string
	li $v0, 4
	syscall			#print search string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, search_name
	li $a1, 50	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	add $t0, $a0, $zero	#store the input string in t0
	

	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 0		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#read from file
	li $v0, 14		#read file
	move $a0, $s1		#load file descriptor
	la $a1, file_buffer	#address of input buffer
	li $a2, 1000		#max number of characters to read
	syscall
	
	la $t0, search_name	#to = name
	la $t1, file_buffer	#t1 = &file_content
	add $t2, $zero, $zero 	#t2 = i
	add $t5, $zero, $zero 	#counter
	addi $t6, $zero, 1000	#file max size
	
	li $t9, 10	#t9 = 10, 10 =  "\n"
	add $t8, $t1, $zero
search_loop:
	add $t5, $t5, 1		#counter++
	slt $t7, $t5, $t6	#t7 = counter < 1000
	beq $t7, $zero, not_found 
	
	add $t3, $t0, $t2	#t3 = &email[i]
	lb $t4, 0($t1)		#t4 = filebuffer[i]
	lb $t3, 0($t3)		#t3 = email[i]
	addi $t2, $t2,1		#i++
	addi $t1, $t1, 1	#&file_buffer++
	beq $t3, $t9, found	#name[i] = '\n', it's found
	beq $t3, $t4, search_loop #if file_buffer[i] = email[i]	 

reset_i:
	add $t2, $zero,$zero	#i = 0;
	add $t8, $t1, $zero	#the start of the person's line
	j search_loop		#return to search loop

found:
addi $t7, $zero, 1 	#found = 1;
	
	
	la $a0, found_string
	li $v0, 4
	syscall		#print found string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	
print_name_loop:
		
	
	lb $t4, 0($t8)
	
	#print char
	la $a0, ($t4)
	li $v0 11
	syscall
	addi $t8, $t8, 1		
	bne $t4, $t9,  print_name_loop #if line = "\n" close file
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	j close_file
	
not_found:
	add $t7, $zero, $zero	#found = 0
	
	la $a0, not_found_string
	li $v0, 4
	syscall		#print student string
	
	j close_file
	
close_file:
				
	# Close the file 
  	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	j main_loop																	
###############################################################	
#delete a person from the file
delete_person:


	la $a0, delete_name_string
	li $v0, 4
	syscall			#print delete_name_string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, search_name
	li $a1, 50	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	add $t0, $a0, $zero	#store the input string in t0
	

	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 0		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#read from file
	li $v0, 14		#read file
	move $a0, $s1		#load file descriptor
	la $a1, file_buffer	#address of input buffer
	li $a2, 1000		#max number of characters to read
	syscall
	
	la $t0, search_name	#to = name
	la $t1, file_buffer	#t1 = &file_buffer
	add $t2, $zero, $zero 	#t2 = i
	add $t5, $zero, $zero 	#counter
	addi $t6, $zero, 1000	#file max size
	
	add $t8, $t1, $zero	
	
	li $t9, 10	#t9 = 10, 10 =  "\n"
	
search_loop2:
	add $t5, $t5, 1		#counter++
	slt $t7, $t5, $t6	#t7 = counter < 1000
	beq $t7, $zero, not_found2 
	
	add $t3, $t0, $t2	#t3 = &name[i]
	lb $t4, 0($t1)		#t4 = filebuffer
	lb $t3, 0($t3)		#t3 = name
	addi $t2, $t2,1		#i++
	addi $t1, $t1, 1	#file_buffer++
	beq $t3, $t9, found2	#name[i] = '\n', it's found
	beq $t3, $t4, search_loop2 	 

reset_i2:
	add $t2, $zero,$zero	#i = 0;
	add $t8,$t1,$zero	#t8 points to the name location
	j search_loop2		#return to search loop

found2:
	addi $t7, $zero, 1 	#found = 1;
	
	
	la $a0, removed_string
	li $v0, 4
	syscall		#print found string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	#load file_buffer to file_buffer2 except for the deleted person
	la $t1, file_buffer	#t1 = file buffer
	la $t2, file_buffer2	#t2 = file buffer2
	add $t3, $zero,$zero	#t3 = 0

copy_buffer_loop:
	add $t3, $t3, 1		#counter++
	slt $t7, $t3, $t6	#t7 = counter < 1000
	beq $t7, $zero, stop_copy
	
	beq $t1 , $t8, skip_name #if the buffer is at the delete name, skip it until the next line	
	lb $t4, 0($t1)	#load from file buffer
	sb $t4, 0($t2)	#store in file_buffer2	
	addi $t1, $t1,1 #file_buffer++
	addi $t2, $t2,1 #file buffer2++
	j copy_buffer_loop
	
	skip_name:
		lb $t4, 0($t1)	#load from file buffer
		addi $t1, $t1,1	#filebuffer++
		bne $t4, $t9, skip_name	#loop until t4 = "\n"
	j copy_buffer_loop
	
stop_copy:	
	
	#print filebuffer2
	li $v0, 4	#print string
	la $a0, file_buffer2	#address of string
	syscall
	#The new file content is in file buffer2, now write this in the file
	
	#close the file
	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	
	#calculate the filebuffer2 size
	la $t1, file_buffer2
	add $t2, $zero, $zero	#t2 = size = 0

calculate_size_loop:
	lb $t4, 0($t1)	#load char
	addi $t2, $t2,1	#size++
	addi $t1, $t1, 1	#filebuffer2++
	bne $t4, $zero, calculate_size_loop
	
	lb $t4, 0($t1)
	addi $t2, $t2,1
	addi $t1, $t1, 1
	bne $t4, $zero, calculate_size_loop

	lb $t4, 0($t1)
	addi $t2, $t2,1
	addi $t1, $t1, 1
	bne $t4, $zero, calculate_size_loop
	
	
	addi $t2,$t2,-3
	
	#open the file to write on it
	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 1		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#write to file
	li   $v0, 15       # system call for write to file
 	move $a0, $s1      # file descriptor 
  	la $a1, file_buffer2
	
    	
  	add $a2, $t2, $zero  # buffer length = i
    	syscall
  	
	
	
	j close_file2
	
not_found2:
	add $t7, $zero, $zero	#found = 0
	
	la $a0, not_found_string
	li $v0, 4
	syscall		#print student string
	
	j close_file2
	
close_file2:
				
	# Close the file 
  	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	j main_loop																					
																																								
######################################################	
update_line:


	la $a0, update_name_string
	li $v0, 4
	syscall			#print update_name_string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, search_name
	li $a1, 50	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	add $t0, $a0, $zero	#store the input string in t0
	
	la $a0, new_line_string
	li $v0, 4
	syscall			#print new_line_string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	la $a0, new_line
	li $a1, 50	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	

	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 0		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#read from file
	li $v0, 14		#read file
	move $a0, $s1		#load file descriptor
	la $a1, file_buffer	#address of input buffer
	li $a2, 1000		#max number of characters to read
	syscall
	
	la $t0, search_name	#to = name
	la $t1, file_buffer	#t1 = &file_buffer
	add $t2, $zero, $zero 	#t2 = i
	add $t5, $zero, $zero 	#counter
	addi $t6, $zero, 1000	#file max size
	
	add $t8, $t1, $zero	#t8 points to beginning of file
	li $t9, 10	#t9 = 10, 10 =  "\n"
	
search_loop3:
	add $t5, $t5, 1		#counter++
	slt $t7, $t5, $t6	#t7 = counter < 1000
	beq $t7, $zero, not_found3 
	
	add $t3, $t0, $t2	#t3 = &name[i]
	lb $t4, 0($t1)		#t4 = filebuffer
	lb $t3, 0($t3)		#t3 = name
	addi $t2, $t2,1		#i++
	addi $t1, $t1, 1	#file_buffer++
	beq $t3, $t9, found3	#name[i] = '\n', it's found
	beq $t3, $t4, search_loop3 	 

reset_i3:
	add $t2, $zero,$zero	#i = 0;
	add $t8,$t1,$zero	#t8 points to the name location
	j search_loop3		#return to search loop

found3:
	addi $t7, $zero, 1 	#found = 1;
	
	
	la $a0, found_string
	li $v0, 4
	syscall		#print found string
	
	li $a0, 10		
	li $v0, 11		
	syscall		#print new line
	
	#load file_buffer to file_buffer2 except for the deleted person
	la $t1, file_buffer	#t1 = file buffer
	la $t2, file_buffer2	#t2 = file buffer2
	add $t3, $zero,$zero	#t3 = 0
copy_buffer_loop2:
	add $t3, $t3, 1		#counter++
	slt $t7, $t3, $t6	#t7 = counter < 1000
	beq $t7, $zero, stop_copy2
	
	beq $t1 , $t8, skip_name2 #if the buffer is at the delete name, skip it until the next line	
	lb $t4, 0($t1)	#load from file buffer
	sb $t4, 0($t2)	#store in file_buffer2	
	addi $t1, $t1,1 #file_buffer++
	addi $t2, $t2,1 #file buffer2++
	j copy_buffer_loop2
	
	skip_name2:
		lb $t4, 0($t1)	#load from file buffer
		addi $t1, $t1,1	#filebuffer++
		bne $t4, $t9, skip_name2	#loop until t4 = "\n"
		
		#add the new line to the file_buffer2
		la $t5, new_line	#t5 = &new line
	update:
		lb $t7, 0($t5)	#t7 = new_line
		sb $t7, 0($t2)	#file_buffer2 = new_line
		addi $t5, $t5, 1	#t5++
		addi $t2, $t2,1	#file_buffer2++
		bne $t7, $t9, update	#while not "\n"
		
		
	j copy_buffer_loop2
	
stop_copy2:	
	
	#print filebuffer2
	li $v0, 4	#print string
	la $a0, file_buffer2	#address of string
	syscall
	#The new file content is in file buffer2, now write this in the file
	
	#close the file
	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	
	#calculate the filebuffer2 size
	la $t1, file_buffer2
	add $t2, $zero, $zero	#t2 = size = 0

calculate_size_loop2:
	lb $t4, 0($t1)	#load char
	addi $t2, $t2,1	#size++
	addi $t1, $t1, 1	#filebuffer2++
	bne $t4, $zero, calculate_size_loop2
	
	lb $t4, 0($t1)
	addi $t2, $t2,1
	addi $t1, $t1, 1
	bne $t4, $zero, calculate_size_loop2

	lb $t4, 0($t1)
	addi $t2, $t2,1
	addi $t1, $t1, 1
	bne $t4, $zero, calculate_size_loop2
	
	
	addi $t2,$t2,-3
	
	#open the file to write on it
	#open file
	li $v0, 13		#open file
	la $a0, file_name	#load file name
	li $a1, 1		#Write (0 = read, 1 = write(create new file), 9 append)
	li   $a2, 0       	# mode
	syscall 
	move $s1, $v0      	# save the file descriptor (needed to close the file)
	
	#write to file
	li   $v0, 15       # system call for write to file
 	move $a0, $s1      # file descriptor 
  	la $a1, file_buffer2
	
    	
  	add $a2, $t2, $zero  # buffer length = i
    	syscall
  	
	
	
	j close_file3
	
not_found3:
	add $t7, $zero, $zero	#found = 0
	
	la $a0, not_found_string
	li $v0, 4
	syscall		#print student string
	
	j close_file3
	
close_file3:
				
	# Close the file 
  	li   $v0, 16       # system call for close file
  	add $a0, $s1, $zero	#file descriptor
  	syscall            # close file
	j main_loop																					
							
######################################################	
commands:

	addi $v0, $zero, 10	#v0 = 10
	
	#read user command
	la $a0, user_command
	li $a1, 20	#max numbers of characters in string = 50
	li $v0, 8 	#read input
	syscall
	add $t0, $a0, $zero	#store the input string in t0
	
	li $t9, 10	#t9 = 10, 10 =  "\n"
	la $t1, ADD_string
	add $t2, $t0, $zero	#t2 = &user_command 
ADD_loop:
	lb $t3, 0($t1)	#t3 = add_string[i] char
	lb $t4, 0($t2)	#t3 = user_command[i]
	addi $t1, $t1,1	 #add_string++
	addi $t2, $t2, 1 #user_command++
		
	beq $t4, $t9, ADD_found	
	beq $t3, $t4, ADD_loop
	
	
	la $t1, SHOW_string
	add $t2, $t0, $zero	#t2 = &user_command 
SHOW_loop:
	lb $t3, 0($t1)	#t3 = add_string[i] char
	lb $t4, 0($t2)	#t3 = user_command[i]
	addi $t1, $t1,1	 #add_string++
	addi $t2, $t2, 1 #user_command++
		
	beq $t4, $t9, SHOW_found	
	beq $t3, $t4, SHOW_loop	
	
	
	la $t1,SEARCH_string
	add $t2, $t0, $zero	#t2 = &user_command 
SEARCH_loop:
	lb $t3, 0($t1)	#t3 = add_string[i] char
	lb $t4, 0($t2)	#t3 = user_command[i]
	addi $t1, $t1,1	 #add_string++
	addi $t2, $t2, 1 #user_command++
		
	beq $t4, $t9, SEARCH_found	
	beq $t3, $t4, SEARCH_loop	
	
	la $t1,REMOVE_string
	add $t2, $t0, $zero	#t2 = &user_command 
REMOVE_loop:
	lb $t3, 0($t1)	#t3 = add_string[i] char
	lb $t4, 0($t2)	#t3 = user_command[i]
	addi $t1, $t1,1	 #add_string++
	addi $t2, $t2, 1 #user_command++
		
	beq $t4, $t9, REMOVE_found	
	beq $t3, $t4, REMOVE_loop	
	
	
	la $t1,UPDATE_string
	add $t2, $t0, $zero	#t2 = &user_command 
UPDATE_loop:
	lb $t3, 0($t1)	#t3 = add_string[i] char
	lb $t4, 0($t2)	#t3 = user_command[i]
	addi $t1, $t1,1	 #add_string++
	addi $t2, $t2, 1 #user_command++
		
	beq $t4, $t9, UPDATE_found	
	beq $t3, $t4, UPDATE_loop
	
nothing_found:	
	addi $v0, $zero, 10	#v0 = 10
	jr $ra
	
ADD_found:
	addi $v0, $zero,1	#v0 = 1
	jr $ra	

SHOW_found:
	addi $v0, $zero,2	#v0 = 2
	jr $ra	
	
SEARCH_found:
	addi $v0, $zero,3	#v0 = 3
	jr $ra		

REMOVE_found:
	addi $v0, $zero,4	#v0 = 4
	jr $ra

UPDATE_found:
	addi $v0, $zero,5	#v0 = 5
	jr $ra	
			
##################################################																																																																																																																																																																																																																																																																																																																																																																																																											
Exit:
