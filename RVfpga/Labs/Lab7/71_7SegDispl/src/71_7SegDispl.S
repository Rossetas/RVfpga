#define SegEn_ADDR    0x80001038
#define SegDig_ADDR   0x8000103C

.globl main
main:

    li t1, SegEn_ADDR
    li t6, 0xFC
    sb t6, 0(t1)						# Enable the 7SegDisplays

    li t1, SegDig_ADDR
    li t6, 0x71
    sw t6, 0(t1)						# Write the 7SegDisplays

next:	beq zero, zero, next

.end

/*
main:
    // Inicializar I2C:
    call i2cInit
    
    // Inicializar 7SegDis:
    li t1, SegEn_ADDR
    li t6, 0xFC // Habilitar los 4 displays de 7 segmentos
    sb t6, 0(t1)

    li t1, SegDig_ADDR

loop:
    // Obtener lecturas de temperatura
    call i2cRxTemp

    // Escribir los valores en los displays de 7 segmentos
    sw a0, 0(t1) // Escribir el byte MSB en los displays
    sw a1, 4(t1) // Escribir el byte LSB en los displays

    j loop // Repetir el bucle continuamente
.end

*/