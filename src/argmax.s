.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    li t0 0 #index
    li t1 0 #greatest value
    li t2 0 #value at index
    li t3 0 #index for greatest value
    bgt a1 x0 loop_start #begin loop if len>0
    li a0 36
    j exit

loop_start:
    lw t2 0(a0)
    ble t2 t1 loop_continue #skip if value<=greatest
    add t1 x0 t2 #store greatest
    add t3 x0 t0 #store index

loop_continue:
    addi a0 a0 4 #increment array pointer
    addi t0 t0 1 #increment index
    bge t0 a1 loop_end #loop if index<len
    j loop_start
loop_end:
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4
    add a0 x0 t3 #store return value
    
    jr ra
