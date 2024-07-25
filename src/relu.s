.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    
    addi t0 x0 1
    addi t1 x0 0 #initialize counter/index
    blt a1 t0 invalid_input
    
    add t2 x0 a0 #initialize to check value
loop_start:
    lw t2 0(a0)
    bge t2 x0 loop_continue#if value greater than 0, don't change it
    sw x0 0(a0) #change if value less than 0

loop_continue:
    addi t1 t1 1
    bge t1 a1 loop_end
    addi a0 a0 4
    j loop_start
loop_end:
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4

    jr ra
invalid_input:
    li a0 36
    j exit