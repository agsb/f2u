from https://www.engbedded.com/conffuse/

BOOTRST, Flash boot size=256 words Boot address= $0F00
EESAVE, preserve eeprom
SPIEN, serial prrogram downloading SPI enable
SUT_CKSEL, Int Osc, 8MHz; startup time 6CK + 64ms
BODEN, Brown-out detector VCC=2,7V

high 0xD4
low  0xA4 (0xA0 for external clock, 16Mhz)

AVRDUDE:
-U hfuse:w:0xd4:m -U lfuse:w:0xa4:m 
