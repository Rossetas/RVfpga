//=========================================================
//==================Direccionamineto.======================
// Display 7segments:
#define Segmen_Digits0   0x80001038
#define Segmen_Digits1   0x80001039
#define Segmen_Digits2   0x8000103A
#define Segmen_Digits3   0x8000103B
#define Segmen_Digits4   0x8000103C
#define Segmen_Digits5   0x8000103D
#define Segmen_Digits6   0x8000103E
#define Segmen_Digits7   0x8000103F

// LEDs-Switches-Botones:
#define GPIO_SWs         0x80001400
#define GPIO_LEDs        0x80001404
#define GPIO_INOUT       0x80001408
#define GPIO_BTTNS       0x80001800 // Agregar dirección para los botone.
// Parametros:
#define DELAY 5000000
//=========================================================
//  Procesos de lectura y escritura:
#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value)                 \
    {                                          \
        (*(volatile unsigned *)dir) = (value); \
    }
// 7 segments:
#define WRITE_7Seg(dir, value) { (*(volatile unsigned *)dir) = (value); }
//=========================================================
void delay()
{
    // Funcion que genera delay para apreciar el cambio de los leds.
    volatile int j;
    for (int i = 0; i <= DELAY; i++)
    {
        j++;
    }
}
//=========================================================
//=========================Main.===========================
int main(void)
{
    // ----------------------------------------------------
    // Entrada al sistema, el LED 1 permanece ensendido:
    WRITE_GPIO(GPIO_LEDs, 1);
    int DATA_BTTNS = 0;
    int state = 0;
    int RESET = 0;
    // ----------------------------------------------------
    while (1)
    {
        // Estado main, esperando señal de botones:
        int En_Value = 0xFFFF;

        WRITE_GPIO(GPIO_INOUT, En_Value);

        DATA_BTTNS = READ_GPIO(GPIO_BTTNS);

        RESET = READ_GPIO(GPIO_SWs);
        RESET = RESET >> 16;
        // ------------------------------------------------
        if (state == 0)
        {
            // Estado general de lectura y escritura en LEDs de los BTTNS.
            WRITE_GPIO(GPIO_LEDs, 0xF00F);

            if (DATA_BTTNS == 1)
            {
                // Al ctivar los botones, se enciende el LED relacionado.
                for (int i = 0; i < 1000; ++i)
                    {
                    WRITE_GPIO(GPIO_LEDs, i); // Escribir en la dirección GPIO_LEDs
                }

                // Leer datos de direcciones de memoria consecutivas
                int sum = 0;
                for (int i = 0; i < 1000; ++i)
                    {
                    sum += READ_GPIO(GPIO_BTTNS + i); // Leer de direcciones consecutivas
                }
                WRITE_7Seg(Segmen_Digits7, sum);

                WRITE_GPIO(GPIO_LEDs, DATA_BTTNS);
                delay();
                delay();
            }
        }
        //-----------------------------------------------
    }

    return 0;
}
//=========================================================
//=========================================================