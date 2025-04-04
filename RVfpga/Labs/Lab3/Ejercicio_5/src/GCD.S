
.data   # variables definidas estaticamente
value1: .word 156
value2: .word 120

.text
.globl main

main:
    lw a0, value1
    lw a1, value2
    # variable solo con proposito de visualizacion
    add t1, zero, a0    # t1 guarda el primer valor
    add t2, zero, a1    # t2 guarda el segundo valor

    loop_euclides:  # algoritmo de euclides
        beqz a1, fin
        rem a2, a0, a1
        mv a0, a1
        mv a1, a2
        j loop_euclides

fin:
    add t0, a0, zero    # t0 guarda el resultado MCD
