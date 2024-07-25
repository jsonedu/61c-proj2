.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    ble a1 x0 error_38 #heightA
    ble a2 x0 error_38 #widthA
    ble a4 x0 error_38 #heightB
    ble a5 x0 error_38 #widthB
    bne a2 a4 error_38
    # Prologue
    addi sp sp -4
    sw ra 0(sp)

    add t0 x0 a0 #set t0 to a0
    add t1 x0 a1 #temp heightA
    li t2 0 #counter for A
    add t3 x0 a3 #set t3 to a3
    add t4 x0 a4 #height counter m1
    slli t4 t4 2
    li t5 0 #width counter up to a5
    add t6 x0 a6 
    addi sp sp -8
    sw t3 0(sp)
    sw a5 4(sp)
    
outer_loop_start:
   
inner_loop_start:
    #save overwritten registers
    addi sp sp -32
    sw t0 0(sp) #a0
    sw t1 4(sp) #
    sw t2 8(sp) #
    sw t3 12(sp) #a3
    sw t4 16(sp) #increment value
    sw t5 20(sp) #
    sw t6 24(sp) #
    sw a4 28(sp)
    
    #load arguments for dot
    add a0 x0 t0)
    add a1 x0 t3) #load 2nd param with m1
    add a2 x0 a4
    li a3 1 #load m0 stride
    add a4 x0 a5 #load m1 stride (width of m1)
    jal dot 
    
    #restore t registers
    lw t0 0(sp)
    lw t1 4(sp) 
    lw t2 8(sp)
    lw t3 12(sp)
    lw t4 16(sp)
    lw t5 20(sp)
    lw t6 24(sp)
    lw a4 28(sp)
    addi sp sp 32
    #insert dot into output
    lw a5 4(sp)
    sw a0 0(t6)
    addi t6 t6 4 #increment output array
    addi t3 t3 4 #increment m1 (a3)
    addi t5 t5 1
    blt t5 a5 inner_loop_start
inner_loop_end:
    #reset inner counters 
    lw t3 0(sp)
    li t5 0
    #increment m0 and its counter
    add t0 t0 t4
    #loop if m0counter<len
    addi t2 t2 1
    blt t2 t1 outer_loop_start
outer_loop_end:
    addi sp sp 8
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4

    jr ra
error_38:
    li a0 38
    j exit