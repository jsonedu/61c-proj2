.globl classify
.data
row0: .word 1
col0: .word 1
row1: .word 1
col1: .word 1
inR: .word 1
inC: .word 1
.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi sp sp -40
    sw ra 0(sp) 
    sw a1 4(sp)
    sw a2 8(sp)
    sw a0 36(sp)
    #jal randomizeCallerSavedRegs #debug pls delete
    lw a0 36(sp)
    addi a0 a0 -5
    bne a0 x0 error_31
    # Read pretrained m0
    lw a1 4(sp)
    lw a0 4(a1)
    la a1 row0
    la a2 col0
    #jal randomizeCalleeSavedRegs
    jal read_matrix #read m0
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    sw a0 12(sp) 
    # Read pretrained m1
    lw a1 4(sp)
    lw a0 8(a1)
    la a1 row1
    la a2 col1
    #jal randomizeCalleeSavedRegs
    jal read_matrix #read m1
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    sw a0 16(sp)
    
    # Read input matrix
    lw a1 4(sp)
    lw a0 12(a1)
    la a1 inR
    la a2 inC
    #jal randomizeCalleeSavedRegs
    jal read_matrix #read input
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    sw a0 20(sp)
    # Compute h = matmul(m0, input)
    #but malloc first before that
    la t0 row0
    la t1 inC
    lw t0 0(t0)
    lw t1 0(t1)
    mul a0 t0 t1
    slli a0 a0 2 #====================================
    #jal randomizeCalleeSavedRegs
    jal malloc #make space for h
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    beq a0 x0 error_26
    sw a0 24(sp) #save h address
    
    lw a0 12(sp)
    
    la t0 row0
    lw a1 0(t0)
    la t0 col0
    lw a2 0(t0)
    
    lw a3 20(sp)
    la t0 inR
    lw a4 0(t0)
    la t0 inC
    lw a5 0(t0)
    lw a6 24(sp) #matmul outputs to h
    #jal randomizeCalleeSavedRegs
    jal matmul ##matmul(m0, input)
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    
    # Compute h = relu(h)
    lw a0 24(sp) #relu outputs to h
    la t0 row0
    lw t0 0(t0)
    la t1 inC
    lw t1 0(t1)
    mul a1 t0 t1
    #jal randomizeCalleeSavedRegs
    jal relu #this is a relu
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    
    # Compute o = matmul(m1, h)
    la t0 row1
    la t1 inC
    lw t0 0(t0)
    lw t1 0(t1)
    mul a0 t0 t1
    slli a0 a0 2 #================================
    #jal randomizeCalleeSavedRegs
    jal malloc #make space for o
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    beq a0 x0 error_26
    sw a0 28(sp) #save o address
    
    #lw a1 8(sp)
    lw a0 16(sp) #address of m1
    la t0 row1
    lw a1 0(t0)
    la t0 col1
    lw a2 0(t0)
    
    lw a3 24(sp) #address of h
    la t0 row0
    lw a4 0(t0)
    la t0 inC
    lw a5 0(t0)
    lw a6 28(sp) #load result matrix from stack (o)
    #jal randomizeCalleeSavedRegs
    jal matmul #matmul(m1,h)
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    # Write output matrix o
    lw a1 4(sp)
    lw a0 16(a1) #filename
    lw a1 28(sp) #pointer to o
    la t0 row1
    lw a2 0(t0) 
    la t0 inC
    lw a3 0(t0)
    #jal randomizeCalleeSavedRegs
    jal write_matrix #this saves output o to the actual output matrix
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    
    # Compute and return argmax(o)
    lw a0 28(sp)
    la t0 row0
    lw t0 0(t0)
    la t1 inC
    lw t1 0(t1)
    mul a1 t0 t1
    #jal randomizeCalleeSavedRegs
    jal argmax #get the best index
    #jal checkCalleeSavedRegs
    #jal randomizeCallerSavedRegsBesidesA0
    sw a0 32(sp)
    # If enabled, print argmax(o) and newline
    lw a2 8(sp)
    bne a2 x0 fin
    jal print_int
    li a0 '\n'
    jal print_char
fin:
    lw a0 12(sp)
    jal free
    lw a0 16(sp)
    jal free
    lw a0 20(sp)
    jal free
    lw a0 24(sp)
    jal free
    lw a0 28(sp)
    jal free

    lw a0 32(sp)
    lw ra 0(sp)
    addi sp sp 40
    jr ra
error_26:
    li a0 26
    j exit
error_31:
    li a0 31
    j exit