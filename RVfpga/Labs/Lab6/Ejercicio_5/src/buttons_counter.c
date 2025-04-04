// Lab06 - Ejercicio 5

// memory-mapped I/O addresses
#define GPIO_SWs 0x80001400
#define GPIO_LEDs 0x80001404
#define GPIO_INOUT 0x80001408

#define GPIO_BTTNS 0x80001800
#define GPIO_INOUT_BUTTONS 0x80001808

#define SYSCON_BTNS 0x80001010

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value); }

#define DELAY 10000000
#define DELAY_Fast 3000000

/*Prototipo de funciones*/
void proceso();
void delay ();
void fast_delay();

int main ( void )
{
    proceso ();

    return (0);
}

void proceso () {

    WRITE_GPIO(GPIO_INOUT, 0xFFFF);
    WRITE_GPIO(GPIO_INOUT_BUTTONS, 0x0);

    int counter = 0;
    unsigned int button_down = 0, button_center = 0;
    unsigned int buttons_value = 0;
    
    while (1)
    {
        buttons_value = READ_GPIO(GPIO_BTTNS);
        button_down = buttons_value & 0x8;
        button_center = buttons_value & 0x10;
        counter = counter+1;
        delay();
        WRITE_GPIO(GPIO_LEDs, counter);
        delay();

        if(button_down){
            counter = 0;
            proceso();
        }
        else if(button_center){

            while (1)
            {
                buttons_value = READ_GPIO(GPIO_BTTNS);
                button_down = buttons_value & 0x8;

                counter = counter+1;
                fast_delay();
                WRITE_GPIO(GPIO_LEDs, counter);
                fast_delay();

                if(button_down){
                    counter = 0;
                    proceso();
                }
                
            }
            
        }
    }
}
/* ---------------------------------------------- */

void delay()
{
    volatile int j;
    for (int i = 0; i <= DELAY; i++)
    {
        j++;
    }
}
/* ---------------------------------------------- */
void fast_delay()
{
    volatile int j;
    for (int i = 0; i <= DELAY_Fast; i++)
    {
        j++;
    }
}
/* ---------------------------------------------- */
