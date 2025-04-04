// memory-mapped I/O addresses
#define GPIO_SWs 0x80001400
#define GPIO_LEDs 0x80001404
#define GPIO_INOUT 0x80001408

#define GPIO_2 0x80001800
#define GPIO_INOUT2 0x80001808

#define SYSCON_BTNS 0x80001010

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value); }
int main ( void )
{
    WRITE_GPIO(GPIO_INOUT, 0xFFFF);
    WRITE_GPIO(GPIO_INOUT2, 0x0);
    unsigned int buttons_value = 0;
    while (1){
        buttons_value = READ_GPIO(GPIO_2);
        WRITE_GPIO(GPIO_LEDs, buttons_value);
    }
    return (0);
}

// BTN_izquierda    = LED [0]
// BTN_derecha      = LED [1]
// BTN_arriba       = LED [2]
// BTN_abajo        = LED [3]
// BTN_centro       = LED [4]