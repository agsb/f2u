Details.md

# Specifics

## For ATmega8 MCU, 

- a using Opitboot for flashing and boot;
- a internal clock of 8MHz;
- a uart at 9600, 8-N-1, asynchronous;
- a timer at 1ms with 16 bits counter  ~ 65 s;
- a watch dog at ~ 2.0 s;
- a pseudo 16bit random generator; 
- a adapted djb hash generator for 16bits;
- all 8bits and 16bits math from AVR200 manual;
    
> need explain update/flush flash memory using a sram buffer

## For Forth,

- all dictionary in flash;
- all constants in flash;
- all values and variables in sram;
- eeprom preserves constants;
- a cell is 16 bits;
- little endian, low byte at low address;
- a char is ASCII 7 bits, one byte at SRAM, one cell at stacks.
- maximum word lenght is 15;
- four bits flags (IMMEDIATE, COMPILE_ONLY, HIDEN, TOGGLE) per word;
- word names are padded with space (0x20)
- numbers are signed two-complement;
- all stacks are 18 words (cells);
- terminal input buffer is 72 bytes, flash page buffer is 64 bytes, buffer for numeric picture is 16 bytes;
- all buffers ends in \0;
- one interrupt as timer0;
- still interrupts can't be nested, SREG breaks;
  
## Forth non conforming,

- primitive (Leaf) routine does not do any calls. 
- compound (Twig) routines could do any calls.
- index routines counts downwards until 0, ever, exact as C: for (n=NNNN; n != 0 ; n--) { ~~~ }
- no bounds check, none.
- compare bytes: COMPARE return FALSE or TRUE, only;
- move bytes: only MOVE done, (still no CMOVE upwards, no CMOVE> downwards);
- word names lenght can be 1 to 15, padded with space (0x20);

## Details
    
- All references are done using of indirect LD and ST with Z, Y, X, 16 bits registers;   
- All primitive words finish with a rjmp _link, so the (inner + primitives) must be less than +2k words;
- Uses address pointer is Z (r31:r30) for lpm/spm (flash), lds (sram), sts (sram) instructions
- The return stack pointer is Y (r29:r28) for forth return stack;
- The parameter stack pointer is X (r27:r26) for forth data stack;
- A working register is W (r25:r24) for forth as acumulator register;
- A temporary register T (r23:r22);
- A temporary register N (r21:r20);
- A instruction register IP (r19:r18);

## Registers Use

- reserved r0:r1, used as generic scratch for internal routines (mul, div, etc)
- reserved r2 as generic _work_ 
- reserved r3 as always _zero_, keep by timer0 interrupt ;)
- registers r4 reserver for keep _SREG_, inside interrupts
- register r5 reserved for adjustable prescaler of timer0
- registers r6:r7 reserved for keep 1ms clock ticks counter
- registers r8::r17 are free
- Not using of SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
- Only using IJMP to primitives else use indirect push and pull for references address;

## Memory Use

- flash memory from $000 to $FFF ($0000 to $1FFF bytes), splits in read-write flash RWW($000 to $BFF) and no-read-rwrite- flash NRWW ($C00 to $FFF).

- sram memory from $060 to $45F (1024 bytes)

## ISO Standarts

Must conform with:

- ISO/IEC 646, ISO 7-bit coded character set for information interchange.

- ISO/IEC 9899, language C standart, http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf. Joke ;)
## Bootstrap fuses

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