#define Segment_Digits0 0x80001038
#define Segment_Digits1 0x80001039
#define Segment_Digits2 0x8000103A
#define Segment_Digits3 0x8000103B
#define Segment_Digits4 0x8000103C
#define Segment_Digits5 0x8000103D
#define Segment_Digits6 0x8000103E
#define Segment_Digits7 0x8000103F

#define WRITE_7Seg(dir, value) { (*(volatile unsigned *)dir) = (value); }

int main ( void )
{
    WRITE_7Seg(Segment_Digits0, 0x4F);      // I
    WRITE_7Seg(Segment_Digits1, 0x48);      // H
    WRITE_7Seg(Segment_Digits2, 0xFF);
    WRITE_7Seg(Segment_Digits3, 0x44);      // Y
    WRITE_7Seg(Segment_Digits4, 0x08);      // A
    WRITE_7Seg(Segment_Digits5, 0x24);      // S
    WRITE_7Seg(Segment_Digits6, 0xFF);
    WRITE_7Seg(Segment_Digits7, 0x4F);      // I

    return (0);
}