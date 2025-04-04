# Register addresses for SPI Peripheral

#define SPCR 0x80001100
#define SPSR 0x80001108
#define SPDR 0x80001110
#define SPER 0x80001118
#define SPCS 0x80001120

# SPCR: Registro de control
# SPSR: Registro de estado
# SPDR: Registro de datos
# SPER: Registro de extensiones
# SPCS: Registro CS

// Display 7 segmentos
#define SegEn_ADDR     0x80001038
#define SegDig_ADDR    0x8000103C

.globl main

.equ N, 500000  # contador delay      

.data

.text

main:   # MAIN ###########################

    # variable para la func delay
    li s5, N                # valor de referencia del contador del delay

    li s1, SegDig_ADDR      # carga direccion del Display 7 seg
    li t1, SegEn_ADDR       # habilitar 7 segmentos
    li t2, 0x24             # 00100100, valor para habilitar los display a utilizar
    sb t2, 0(t1)            # habilitar el 7SegDisplays

    jal spiInit             # modulo SPI
    jal spiCSDown           # ##### START
    # ESCRITURA DE REGISTRO
    li a0, 0x0A             # ##### INSTRUCTION - 0000 1010
    jal spiSendGetData
    li a0, 0x02             # ##### 8-BIT ADDRESS - PART_ID 
    jal spiSendGetData
    li a0, 0x2D             # ##### DATA BYTE - POWER_CTL
    jal spiSendGetData

    jal spiCSUp             # ##### END

    jal print_data

print_data:

    add t5, zero, zero      # int i = 0

    # LECTURA DE REGISTRO

    # Eje X
    jal spiCSDown           # inicio
    li a0, 0x0B             # instruccion - 0000 1011
    jal spiSendGetData
    li a0, 0x08             # address XDATA
    jal spiSendGetData
    jal spiSendGetData
    jal spiCSUp             # fin
    or s2, zero, a1         # se guarda lectura en el registro

    # Eje Y
    jal spiCSDown           # inicio
    li a0, 0x0B             # instruccion - 0000 1011
    jal spiSendGetData
    li a0, 0x09             # address YDATA
    jal spiSendGetData
    jal spiSendGetData
    jal spiCSUp             # fin
    or s3, zero, a1         # se guarda lectura en el registro

    # Eje Z
    jal spiCSDown           # inicio
    li a0, 0x0B             # instruccion - 0000 1011  
    jal spiSendGetData
    li a0, 0x0A              # address ZDATA
    jal spiSendGetData
    jal spiSendGetData
    jal spiCSUp             # fin
    or s4, zero, a1         # se guarda lectura en el registro

    # mascara para obtener los 8 bits mas significativos
    andi s2, s2, 0xFF
    andi s3, s3, 0xFF
    andi s4, s4, 0xFF

    # desplazamiento lecturas X y Y
    slli s2, s2, 0x18       # 24 posiciones - lectura X
    slli s3, s3, 0xC        # 12 posiciones - lectura Y
    slli s4, s4, 0          # 0  posiciones - lectura Z

    # combinar valores de las lecturas de los registros
    or s2, s2, s2           # X
    or s2, s2, s3           # Y
    or s2, s2, s4           # Z

    sw s2, 0(s1)            # escribir la salida en el registro asignado (s1 = SegDig_ADDR) 
    jal delay               # DELAY
    j print_data            # se repite el loop

delay:
    addi t5, t5, 1      # contador ++
    blt t5, s5, delay   # condicional de salto
ret

# Function: Initialize SPI peripheral
# call: by call ra, spiInit
# inputs: None
# outputs: None
# destroys: t0, t1

spiInit: # spiInit: Inicializa controlador SPI
    li t1, SPCR # control register
    li t0, 0x53 # 01010011 no ints, core enabled, reserved, controller, cpol=0, cha=0, clock divisor 11 for 4096 
    sb t0, 0(t1)
    li t1, SPER # extension register
    li t0, 0x02 # int count 00 (7:6), clock divisor 10 (1:0) for 4096 
    sb t0, 0(t1)
ret

# Function: Pull CS Line to either high or low - Provides quick calls spiCSUp and spiCSDown
# call: by call ra, spiCS
# inputs: CS status in a0 (0 is low, 1 is high)
# outputs: None
# destroys: t0

spiCS: # spiCS: Configura señal CS según valor pasado en a0.
    li t0, SPCS # CS register
    sb a0, 0(t0) # Send CS status
ret

spiCSUp: # spiCSUp: Configura señal CS en alto.
    li a0, 0x00
    j spiCS

spiCSDown:  # spiCSDown: Configura señal CS en bajo.
    li a0, 0xFF
    j spiCS

# Function: Send byte through SPI and get the peripheral data back
# call: by call ra, spiSendGetData
# inputs: data byte to send in a0
# outputs: received data byte in a1
# destroys: t0, t1

spiSendGetData: # spiSendGetData: Transfiere un byte de datos por el bus.
    internalSpiClearIF:     # internal clear interrupt flag
        li t1, SPSR         # status register
        lb t0, 0(t1)        # clear SPIF by writing a 1 to bit 7
        ori t0,t0,0x80
        sb t0, 0(t1)
    internalSpiActualSend:
        li t0, SPDR         # data register
        sb a0, 0(t0)        # send the byte contained in a0 to spi
    internalSpiTestIF:
        li t1, SPSR         # status register
        lb t0, 0(t1)
        andi t0, t0, 0x80
        li t1, 0x80
        bne t0,t1,internalSpiTestIF     # loop while SPSR.bit7 == 0. (transmission in progress)
    internalSpiReadData:
        li t0, SPDR             # data register
        lb a1, 0(t0)            # read the message from SPI
ret

.end