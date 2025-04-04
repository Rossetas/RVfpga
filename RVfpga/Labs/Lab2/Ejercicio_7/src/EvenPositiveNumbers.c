#if defined(D_NEXYS_A7)
 #include <bsp_printf.h>
 #include <bsp_mem_map.h>
 #include <bsp_version.h>
#else
 PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>

#define N 12

/* Prototipo de funciones*/

void proceso();

int main(void)
{ 
    proceso();

    return 0;
}

void proceso(){

    int array_A[N]={0,1,2,7,-8,4,5,12,11,-2,6,3};
    int array_B[N];
    int j=0; // contador

    // Initialize UART
    uartInit();

    printfNexys("Array A [");
    for(int i=0; i<N; i++){
        printfNexys("%d", array_A[i]);
    }
    printfNexys("]");

    for(int i=0; i<N; i++){
        if((array_A[i] % 2 == 0) && (array_A[i] > 0)){
            array_B[j] = array_A[i];
            j++;
        }
    }

    printfNexys("\nArray B [");
    for (int i=0; i<j; i++)
    {
        printfNexys("%d", array_B[i]);
    }
    printfNexys("]");

    printfNexys("\nNumero de elementos en B = %d", j);
    
}