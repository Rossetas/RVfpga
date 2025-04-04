// memory-mapped I/O addresses
#define GPIO_SWs    0x80001400 // interruptores
#define GPIO_LEDs   0x80001404 // LEDs
/*Los valores de los interruptores están en la mitad del 
registro correspondiente a los bits más significativos y los LEDs en los bits menos 
significativos.*/
#define GPIO_INOUT  0x80001408

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value);}

/* Prototipo de funciones*/
void proceso();

int main ( void )
{
    proceso();

    return(0);
}


void proceso(){

    int En_Value=0xFFFF; // menos significativos - leds
    //int En_Value=0x0000FFFF; // menos significativos - leds
    /* Define los 16 pines GPIO más significativos (que están conectados a los interruptores) 
    como entradas poniendo la mitad superior del registro GPIO_INOUT a 0 y define los 16 
    pines GPIO menos significativos (que están conectados a los LEDs) como salidas poniendo 
    la mitad inferior del registro GPIO_INOUT a 1*/ 
    int switches_value; 
    int value1, value2, sum;

    WRITE_GPIO(GPIO_INOUT, En_Value);

    while (1) {

        switches_value = READ_GPIO(GPIO_SWs);   // read value on switches
        switches_value = switches_value >> 16;  // shift into lower 16 bits

        // mascara AND que extrae los 4 bits menos significativos
        value1 = switches_value & 0x000F; // menos significativo
        // mascara AND que extrae los 4 bits mas significativos
        value2 = switches_value & 0xF000; // mas significativo

        value2 = value2 >> 12; // para que la suma se realice en los bits menos significativos de los leds

        /*alternativamente se puede configurar para que se muestra en distintas posiciones*/

        //value1 = value1 << 12; //de esta forma el resultado se muestra en los bits mas significativos de los leds pero sin acarreo

        sum = value1 + value2;
        
        WRITE_GPIO(GPIO_LEDs, sum);  // display switch value on LEDs
    }
}