#define GPIO_LEDs 0x80001404
#define DELAY 2500000

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value)                 \
    {                                          \
        (*(volatile unsigned *)dir) = (value); \
    }

void delay()
{
    // Funcion que genera delay para apreciar el cambio de los leds.
    volatile int j;
    for (int i = 0; i <= DELAY; i++)
    {
        j++;
    }
}

int REG_LEDs = 0x0001, state = 0, counter = 0, MOVES = 15;

int main(void)
{
    while (1)
    {
        //-------------------------------------------------------
        if (state == 0)
        {
            // Estado que desplaza a la izquierda.
            WRITE_GPIO(GPIO_LEDs, REG_LEDs);
            delay();
            REG_LEDs = REG_LEDs << 1;
            counter++;

            if (counter == MOVES)
            {
                state++;
            }
        }
        //-------------------------------------------------------
        else if (state == 1)
        {
            // Estado que desplaza a la derecha.
            WRITE_GPIO(GPIO_LEDs, REG_LEDs);
            delay();
            REG_LEDs = REG_LEDs >> 1;
            counter--;

            if (counter == 0)
            {
                state = 2;
            }
        }
        //-------------------------------------------------------
        else if (state == 2)
        {
            // Estado de moidificacion de parametros.
            REG_LEDs = 2 * REG_LEDs + 1;
            MOVES--;
            state = 0;

            // Reiniciar el sistema.
            if (REG_LEDs == 0xFFFF)
            {
                REG_LEDs = 0x0001;
                state = 0;
                counter = 0;
                MOVES = 15;
            }
        }
        //-------------------------------------------------------
    } // While.
    return (0);
}
