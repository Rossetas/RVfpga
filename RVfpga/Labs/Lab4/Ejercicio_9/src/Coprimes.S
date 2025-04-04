# a partir del ejemplo de la guia se toma como referencia la estructura para el programa

.globl main

.equ M, 6    # constante M con valor de 6, representa el numero de ternas

.data        # se define el vector de entrada D
D: .word 3,5,0,6,18,0,15,45,0,13,10,0,24,3,0,24,35,0 

.text

check_coprime:          # funcion check_coprime
    add sp, sp, -16     # reserva espacio en la pila para guardar registros
    sw ra, 0(sp)        # guarda el valor de ra en la pila, almacena la direccion de retorno
    mv s1, a0           # registro para la posicion
    mv s2, a1           # registro para almacenar la direccion de D[i]
    # constantes a usar
    addi s3, zero, 0    # registro para el residuo
    addi s4, zero, 1    # registro para value 1
    addi s5, zero, 3    # registro para value 2
    addi s6, zero, 4    # registro para el salto de 4 bytes
    # otras constantes dentro de la funcion
    mul s7, s5, s1      # (3*pos)
    addi s8, s7, 1      # [(3*pos)+1]
    addi s9, s7, 2      # [(3*pos)+2]
    mul s7, s7, s6
    mul s8, s8, s6
    mul s9, s9, s6
    add s10, s2, s7     # direccion de D[3*pos]
    add s11, s2, s8     # direccion de D[(3*pos)+1]
    lw a2, 0(s10)       # a2 = D[3*pos]
    lw a3, 0(s11)       # a3 = D[(3*pos)+1]
    jal GCD             # llamada a la funcion GCD (algoritmo de Euclides)
    bne s3, s4, else    # condicional (residuo != 1), salta al else
    add t0, s2, s9      # direccion de D[(3*pos)+2]
    addi t1, zero, 2    
    sw t1, 0(t0)        # D[(3*pos)+2] = 2
    j return_main       
    else:               #
    add t0, s2, s9      # direccion de D[(3*pos)+2]
    sw s4, 0(t0)        # D[(3*pos)+2] = 1
    
    return_main:        # salta al main, para la siguiente terna
    lw ra, 0(sp) 
    addi sp, sp, 16
    ret                 # BREAKPOINT

    GCD:                # algoritmo de euclides
    mv t2, a2
    mv t3, a3

    loop_GCD:
        beqz t3, end_loop 
        rem t4, t2, t3
        mv t2, t3
        mv t3, t4
        j loop_GCD

    end_loop:
        mv s3, t2
        ret 

main:   # funcion main del programa
    addi a0, zero, 0    # indice del array D
    addi s0, zero, M    # s0 = (M)
    la a1, D            # carga la direccion de D[] en a1

    loop_main: # loop encargado de recorrer el array D
        bge a0, s0, end # condicional de (0 a (M-1))
        jal check_coprime   # llamada a la funcion check_coprime
        addi a0, a0, 1
        j loop_main

    end:

.end