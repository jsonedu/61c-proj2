.globl write_matrix
.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================

write_matrix:

    # Prologue
    addi sp sp -20
    sw ra 0(sp)
    sw a1 4(sp)
    
    sw a3 8(sp)
    sw a2 12(sp)
    
    #sw a2 8(sp)
    #sw a3 12(sp)
    #1.fopen a0 a1
    li a1 1
    jal fopen
    sw a0 16(sp)
    blt a0 x0 error_27
    
    #2-3.fwrite a0 a1 a2 a3
    lw a0 16(sp)
    lw a2 12(sp)
    lw a3 8(sp)
    
    addi sp sp -8
    sw a2 0(sp)
    sw a3 4(sp)
    add a1 x0 sp
    li a2 2
    li a3 4
    jal fwrite
    addi sp sp 8
    addi a0 a0 -2
    bne a0 x0 error_30
    
    
    lw a0 16(sp)
    lw a1 4(sp)
    #li a1 0x10000050
    lw a2 12(sp)
    lw a3 8(sp)
    mul a2 a2 a3
    sw a2 8(sp) #num elems=a2*a3
    addi a2 a2 0
    li a3 4 #4 bytes each
    jal fwrite
    lw a2 8(sp)
    bne a0 a2 error_30

    #4. fclose a0
    lw a0 16(sp)
    jal fclose
    bne a0 x0 error_28
    # Epilogue
    lw ra 0(sp)
    addi sp sp 20
    jr ra

    error_27:
        li a0 27
        j exit

    error_30:
        li a0 30
        j exit

    error_28:
        li a0 28
        j exit