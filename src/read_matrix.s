.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -24
    sw ra 0(sp)

    #add t1 x0 a1 #address to rows
    #add t2 x0 a2 #address to columns
    
    sw a1 4(sp)
    sw a2 8(sp)

    #open file w/ read
    li a1 0
    jal fopen
    blt a0 x0 error_27
    sw a0 12(sp) #store file descriptor
    
    #get rows
    add a0 x0 a0
    lw a1 4(sp) #store in a1 pointer
    addi a2 x0 4
    jal fread
    addi a0 a0 -4
    bne a0 x0 error_29
    
    #get columns
    lw a0 12(sp) #restore a0
    lw a1 8(sp) #store in a2 pointer
    li a2 4 
    jal fread
    addi a0 a0 -4
    bne a0 x0 error_29
    
    #malloc
    lw a1 4(sp)
    lw a2 8(sp)
    lw a1 0(a1)
    lw a2 0(a2)
    mul a0 a1 a2
    slli a0 a0 2 #size=row*column*4
    sw a0 16(sp) #store number of bytes 
    jal malloc
    beq a0 x0 error_26
    
    sw a0 20(sp) #stores mallocpointer
    add a1 x0 a0
    lw a0 12(sp)
    lw a2 16(sp)
    jal fread
    lw t0 16(sp)
    bne a0 t0 error_27
    
    lw a0 12(sp)
    jal fclose
    bne a0 x0 error_28
    # Epilogue
    lw a0 20(sp)
    lw ra 0(sp)
    addi sp sp 24
    jr ra
error_27:
    li a0 27
    j exit

error_29:
    li a0 29
    j exit
    
error_26:
    li a0 26
    j exit

error_28:
    li a0 28
    j exit