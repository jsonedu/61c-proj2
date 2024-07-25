.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    
    ble a2 x0 error_36
    ble a3 x0 error_37
    ble a4 x0 error_37
    slli a3 a3 2
    slli a4 a4 2
    add t0 x0 a0 #value at a0 index
    li t1 0 #value at a1 index
    li t2 0 #counter
    li t3 0 #product
    addi t4 x0 0 #dot product

loop_start:
    lw t0 0(a0) #load value from a0
    lw t1 0(a1) #load value from a1
    
    mul t3 t0 t1 #store product into #product
    add t4 t4 t3 #add #product to #dot product
    
    addi t2 t2 1 #increment counter
    add a0 a0 a3 #increment a0 by a3
    add a1 a1 a4 #increment a1 by a4
    blt t2 a2 loop_start #loop if counter<num_elems 

loop_end:
    add a0 x0 t4
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4

    jr ra
error_36:
    li a0 36
    j exit
error_37:
    li a0 37
    j exit
    