// ========================================================
// ------------------- Direccionamiento -------------------
// ========================================================
# -----I2C Module: -----
#define PRERLO  	    0x80001600		// RW - Controlador base address
#define PRERHI  	    0x80001604		// RW
#define CTR     	    0x80001608		// RW
#define TXR     	    0x8000160C		// W
#define	RXR 		    0x8000160C      // R
#define	CR  		    0x80001610		// W
#define	SR  		    0x80001610		// R
# -----7 SegDisp: -----
#define SegEn_ADDR      0x80001038    // AN[0000_0000]
#define SegDig_ADDR     0x8000103C    // Digits_Reg[]
// ========================================================
// -------- Funciones para utilizar modulo I2C ------------
// ========================================================
# Function: Initialize I2C controller peripheral
# call:  by call ra, i2cInit 
# inputs: None
# outputs: None
# destroys: t0, t1
# -----------------------------------------------------------------------------------------------------------
i2cInit:
    li t1, PRERLO       # SCL prescale register. ADT7420 can work from 0 to 400 kHz.
    li t0, 0x1F         # 50MHz/(5*200kHz)-1 = 49 = 0031h 
    sb t0, 0(t1)        # write prescale register lo
    li t1, PRERHI       # SCL prescale register. ADT7420 can work from 0 to 400 kHz.
	li t0, 0x00         # 50MHz/(5*200kHz)-1 = 49 = 0031h 
    sb t0, 0(t1)        # write prescale register hi
    li t1, CTR          # Load Control register address
    li t0, 0x80
    sb t0, 0(t1)        # write control register to enable I2C core
    ret
# -----------------------------------------------------------------------------------------------------------

# Function: Test controller transfer in progress flag 
# call:  by call ra, i2cTestTIP
# inputs: None
# outputs: None
# destroys: t0, t1
# -----------------------------------------------------------------------------------------------------------
i2cTestTIP:
    add sp, sp, -16
    sw ra, 0(sp)
    li t1, SR	        # Load Status register address
internalI2CtestTIP:
	lb t0, 0(t1)        # Load from SR
	andi t0, t0, 0x02   # test TIP bit 1
	li t2, 0x02
	beq t0, t2, internalI2CtestTIP	# loop until TIP (trasfer in progress) bit deasserts
    lw ra, 0(sp)
    add sp, sp, 16
	ret
# -----------------------------------------------------------------------------------------------------------

# Function: Test controller ACK flag (ACK == 0) 
# call:  by call ra, i2cTestACK
# inputs: None
# outputs: None
# destroys: t0, t1
# -----------------------------------------------------------------------------------------------------------
i2cTestACK:
    add sp, sp, -16
    sw ra, 0(sp)
    li t1, SR	 # Load Status register address
internalI2CtestACK:
	lb t0, 0(t1) # Load from SR
	andi t0, t0, 0x80 # test ACK bit 7
	li t2, 0x80
	beq t0, t2, internalI2CtestACK	# loop until ACK bit deasserts 
    #TODO actually, if ACK=1 (NACK) this is an error condition and stop bit should be sent
    lw ra, 0(sp)
    add sp, sp, 16
	ret
# -----------------------------------------------------------------------------------------------------------

# Function: receive two bytes of Temperature data from the ADT7420 device  
# call:  by call ra, i2cRxTemp
# inputs: None
# outputs: TempLSB in a0 and TempMSB in a1 
# destroys: t0, t1
# -----------------------------------------------------------------------------------------------------------
i2cRxTemp:
    # save registers on the stack
    add sp, sp, -16
    sw ra, 0(sp)

	li t1, TXR   # Load Transmit register address
	li t0, 0x97  # Slave address 0x4B + read bit (1)
	sb t0, 0(t1) # Store to TXR
	li t1, CR	 # Load command register address
	li t0, 0x90  #  set START bit 7, set WR bit 4
	sb t0, 0(t1) # store to CR which initiates transaction primary->secondary

	jal i2cTestTIP # Wait until transaction finished
	jal i2cTestACK # Test for secodary agent ACK

	# Initiate secondary device read to address 00 (set by default in device)
	li t1, CR	 # Load Command register address
	li t0, 0x20  #  set RD bit 5
    sb t0, 0(t1) # store to CR which initiates transaction primary->secondary
	
    jal i2cTestTIP

	li t1, RXR		# Load receive registers address
	lb a0, 0(t1)	# store Receive register in a0 (this should be Temp MSB)

	# Initiate secondary device read to address 02 (set by default in device)
	li t1, CR	 # Load Command register address
	li t0, 0x20  # set RD bit 5
    sb t0, 0(t1) # store to CR which initiates transaction primary->secondary

	jal i2cTestTIP

	li t1, RXR		# Load receive registers address
	lb a1, 0(t1)	# store Receive register in a1 (this should be Temp LSB)

	# generate stop bit, no ack to finish transaction
	li t1, CR	 # Load Command register address
	li t0, 0x48  # set STOP bit 6 and NACK by master bit 3
    sb t0, 0(t1) # store to CR which finishes transaction primary->secondary

    # restore registers on the stack
    lw ra, 0(sp)
    add sp, sp, 16
	
    ret
# -----------------------------------------------------------------------------------------------------------
// =========Delay()=========
delay:
    li t0, 500000                      // DELAY =500 000
 loop_delay:
  // Loop para decrementar el contador:
    addi t0, t0, -1                     
    bnez t0, loop_delay
    ret
// =========================

.globl main
main:
 // =========================
 // ----- Inicializar: -----
    // Inicializar I2C:
    call i2cInit
    // Inicializar 7SegDis:
    li t1, SegEn_ADDR
    li t6, 0x00                         // AN [0000_0000]
    sb t6, 0(t1)
 // =========================
 LOOP:
    // (bucle i2cRxTemp + escritura en 7SegDigs)
    // ----- Generamos a0 y a1: -----
    call i2cRxTemp                      // Gnerammos registros de temperatura a0,a1

    // --------------------
    # Limpiar los registros:
    li  t0, 0xFF
    and a0, a0, t0                      // Limpiar el bit de signo en a0
    and a1, a1, t0                      // Limpiar el bit de signo en a1
    // --------------------
    # Combinar los registros en uno solo:
    sll a0, a0, 8                      // Hacer espacio para a1
    or  a0, a0, a1                     // Combinar a0 y a1 en un solo registro

    srl a0, a0, 3                       // Eliminar ultimos 3bits de a1
    // --------------------
    
    // si se desea ver la variacion de temperatura comentar la siguiente linea
    srl a0, a0, 4                      // Dividir entre 16 para obtener el valor decimal.

    // ----- Print en Displays: -----
    li  t1, SegDig_ADDR              
    sw  a0, 0(t1)						// Write 7SegDisplays [a0]
    // ------------------------------
    call delay

    j LOOP
 .end
