;----------------------------------------------------------------------
;
; code segment, flash
;
.section .text
.org 0x000
.global boot
boot:
;----------------------------------------------------------------------
;
; classic interrup vector table
;
;----------------------------------------------------------------------

    rjmp RESET ; Reset Handler
    reti ; rjmp EXT_INT0 ; IRQ0 Handler
    reti ; rjmp EXT_INT1 ; IRQ1 Handler
    reti ; rjmp TIM2_COMP ; Timer2 Compare Handler
    reti ; rjmp TIM2_OVF ; Timer2 Overflow Handler
    reti ; rjmp TIM1_CAPT ; Timer1 Capture Handler
    reti ; rjmp TIM1_COMPA ; Timer1 CompareA Handler
    reti ; rjmp TIM1_COMPB ; Timer1 CompareB Handler
    reti ; rjmp TIM1_OVF ; Timer1 Overflow Handler
    rjmp TIM0_OVF ; Timer0 Overflow Handler
    reti ; rjmp SPI_STC ; SPI Transfer Complete Handler
    reti ; rjmp USART_RXC ; USART RX Complete Handler
    reti ; rjmp USART_UDRE ; ((0x0C) + 0x20) Empty Handler
    reti ; rjmp USART_TXC ; USART TX Complete Handler
    reti ; rjmp ADC ; ADC Conversion Complete Handler
    reti ; rjmp EE_RDY ; EEPROM Ready Handler
    reti ; rjmp ANA_COMP ; Analog Comparator Handler
    reti ; rjmp TWSI ; Two-wire Serial Interface Handler
    reti ; rjmp SPM_RDY ; Store Program Memory Ready Handler;

;----------------------------------------------------------------------
; 
RESET:
; clear interrupts
    cli
; init _zero_ as zero
    clr _zero_ ; exclusive or, xor
    out __SREG__, _zero_; clear sreg
; init real sp at end of sram
    ldi wrk_high, hi8(SPU_TOP)
    out __SP_H__, wrk_high
    ldi wrk_low, lo8(SPU_TOP)
    out __SP_L__, wrk_low
; enable interrupts
    sei
    rjmp BOOT

;----------------------------------------------------------------------
;
;   timer0 prescale 
;    for 8 MHz, prescale 64, offset 131, results about 1 ms
;    64 * 125 = 8000 ; 
;    256 - 125 = 131 ; offset
;   miliseconds
;   r3:r2	counter each 1ms
;	r4		offset to prescale
;	r5		save SREG
;
TIM0_OVF:
;    save flags
    in r5, __SREG__
;    disable interrups
    cli
;    increase counter and also clear R1
	clc
    clr r1
    inc r1
    add r2, r1
    dec r1
    adc r3, r1
;    offset counter 256 - 125 = 131
;    but was 10 clocks till out, 
;    then 131 + 10 = 141
    out 0x32, r4
;    reset watch dog
    wdr
;    load flags and return
    out __SREG__, r5
;    enable interrups
    sei
    reti
/*
;----------------------------------------------------------------------
;792486AA–AVR–02/2013ATmega8(L)Note:1.   See “About Code Examples” on page 8
;
; from atmeg8 datasheet
;
#define EEWE    1
#define EEMWE   2
#define EERE    0

EEPROM_write:
; zzz from avr manual just copy
; disable interrupts
    cli
EEPROM_write_wait:
; Wait for completion of previous write
    sbic EECR, EEWE
    rjmp EEPROM_write_wait    
; Set up address (r18:r17) in address register
    out EEARH, r18
    out EEARL, r17
; Write data (r16) to data register
    out EEDR, r16
; Write logical one to EEMWE
    sbi EECR, EEMWE
; Start eeprom write by setting EEWE
    sbi EECR, EEWE
; enable interrupts
    sei
    ret

EEPROM_read:
; zzz from avr manual just copy
; disable interrupts
    cli
EEPROM_read_wait:
; Wait for completion of previous write
    sbic EECR, EEWE
    rjmp EEPROM_read_wait
; Set up address (r18:r17) in address register
    out EEARH, r18
    out EEARL, r17
; Start eeprom read by writing EERE
    sbi EECR, EERE
; Read data from data register
    in r16, EEDR
; enable interrupts
    sei
    ret
*/

;----------------------------------------------------------------------
BOOT:
; disable interrupts
    cli

; clear timer0 counter
	clr r2
	clr r3

;----------------------------------------------------------------------
; init timer0, with internal clock 8MHz, from gcc public code, io ports as constants
;
; preset of timer0, with internal clock 8MHz ; cycle   64 ; offset 131
; timer cycle * offset / clock = 8k/8M = 1ms
;
TIMER0_SET:
; enable pre-escaler
    in r16, 0x33
    ori r16, (1 << CS01) | (1 << CS00)
    out 0x33, r16
; offset counter, so it counts 125 clocks inside the interrup routines
	ldi r16, 141
; preserve offset
	mov r4, r16
    out 0x32, r16
; enable counter
    in r16, 0x39
    ori r16, (1 << TOIE0) 
    out 0x39, r16

;----------------------------------------------------------------------
; init watch dog, from avr-gcc public code, io ports as constants
;
; write logical one to WDCE and WDE, set WDP2, WDP1, WDP0 to ~ 2.0 s
;
WATCHDOG_SET:
	in r16, 0x21
    ori r16, (1 << WDCE) | (1 << WDE)
    ori r16, (1 << WDP2) | (1 << WDP1) | (1 << WDP0)
    out 0x21, r16

;----------------------------------------------------------------------
; init usart, from avr-gcc public code, io ports as constants
;
;    defaults to 9600, 8N1, no control
;
USART_SET:
    clr wrk_low
    out 0x20, wrk_low
    ldi wrk_low, lo8(52)
    out 0x9, wrk_low
    in wrk_low, 0xa
    ori wrk_low, lo8(24)
    out 0xa, wrk_low
    ldi wrk_low, lo8(-114)
    out 0x20, wrk_low
    in wrk_low, 0x20
    ori wrk_low,lo8(64)
    out 0x20, wrk_low

;----------------------------------------------------------------------
; enable interrupts
    sei
	rjmp COLD 

