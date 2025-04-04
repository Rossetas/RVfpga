
#define GPIO_SWs    0x80001400
#define GPIO_LEDs   0x80001404
#define GPIO_INOUT  0x80001408

#define READ_GPIO(dir) (*(volatile unsigned *)dir)
#define WRITE_GPIO(dir, value) { (*(volatile unsigned *)dir) = (value); }

/*** blue ***/ 
#define RPTC_CNTR_blue  0x80001240
#define RPTC_HRC_blue   0x80001244
#define RPTC_LRC_blue   0x80001248
#define RPTC_CTRL_blue  0x8000124C

/*** green ***/ 
#define RPTC_CNTR_green 0x80001280
#define RPTC_HRC_green  0x80001284
#define RPTC_LRC_green  0x80001288
#define RPTC_CTRL_green 0x8000128C

/*** red ***/ 
#define RPTC_CNTR_red   0x800012C0
#define RPTC_HRC_red    0x800012C4
#define RPTC_LRC_red    0x800012C8
#define RPTC_CTRL_red   0x800012CC

int main ( void )
{

    int En_Value=0xFFFF, switches_value, switches_value_pwm;
    int value = 0xFFFFF, ajuste = 0x2710;
    WRITE_GPIO(GPIO_INOUT, En_Value);
    
    // restart temporizadores
    WRITE_GPIO(RPTC_CTRL_blue, (0x80));
    WRITE_GPIO(RPTC_CTRL_green, (0x80));
    WRITE_GPIO(RPTC_CTRL_red, (0x80));
    // set initial value
    WRITE_GPIO(RPTC_LRC_blue, value);
    WRITE_GPIO(RPTC_LRC_green, value);
    WRITE_GPIO(RPTC_LRC_red, value);
    // enable pwm
    WRITE_GPIO(RPTC_CTRL_blue, (0x0001));
    WRITE_GPIO(RPTC_CTRL_green, (0x0001));
    WRITE_GPIO(RPTC_CTRL_red, (0x0001));
    
    while (1) {

        switches_value = READ_GPIO(GPIO_SWs);
        switches_value = switches_value >> 16;
        WRITE_GPIO(GPIO_LEDs, switches_value);

        switches_value_pwm = READ_GPIO(GPIO_SWs);
        switches_value_pwm = (switches_value_pwm >> 16);

        WRITE_GPIO(RPTC_HRC_blue, value - ((switches_value_pwm & 0x1F)*ajuste));
        WRITE_GPIO(RPTC_HRC_green, value - (((switches_value_pwm >> 5) & 0x1F)*ajuste));
        WRITE_GPIO(RPTC_HRC_red, value - (((switches_value_pwm >> 10)& 0x1F)*ajuste));

    }

    return (0);
}
