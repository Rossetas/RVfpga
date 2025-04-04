#define GPIO_SWs    0x80001400
#define GPIO_LEDs   0x80001404
#define GPIO_INOUT  0x80001408
#define GPIO_BTTNS  0X80001800

.globl main
main:

li x28, 0xFFFF
li x29, GPIO_INOUT
sw x28, 0(x29)                  # Write the Enable Register
#----------------------------------------------------
#Archivo de ejemplo modificado para detecter los botos
#----------------------------------------------------
next:
    li  a1, GPIO_BTTNS          # Read a la dirección de los botones(wb_intercon.v).
    lw  t0, 0(a1)

    li  a0, GPIO_LEDs
    //srl t0, t0, 16            # No es necesario el desplazamineto.
    sw  t0, 0(a0)               # Write the LEDs

    beq zero, zero, next
.end
