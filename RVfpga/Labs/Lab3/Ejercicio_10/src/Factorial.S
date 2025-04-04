
.data   # variable definida estaticamente
N:  .word 7 # variable factorial

.text
.globl main

main:
    li t0, 1    # variable que almacena el resultado
    lw t1, N    # contador

    loop_factorial: # algoritmo de factorial de manera recursiva
        mul t0, t0, t1
        addi t1, t1, -1 # decrementa N
        bnez t1, loop_factorial # termina en N=0
        
    j fin

fin:
