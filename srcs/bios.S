
/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions"
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *
 */

;----------------------------------------------------------------------
; review for atmega328
;   10/2022 @agsb

;----------------------------------------------------------------------
;
; code segment, flash
;
.section .text
.org 0x000
.global boot
boot:

;---------------------------------------------------------------------
; from avr manual, do not change 
; reserved I/O Memory address
;
__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d

/* USART */
UBRRL = 0x09
UCSRC = 0x20
UCSRB = 0x0a
UCSRA = 0x0b

/* Watch dog */
WDTCR = 0x21

/* timer0 */
TCNT0 = 0x32
TCCR0 = 0x33
TIMSK = 0x39

/* SPMCR */
SPMCR = 0x37

/* SPM BITS */
SPMIE = 7
RWWSB = 6
/* bit 5 reserved */
RWWSRE = 4
BLBSET = 3
PGWRT = 2
PGERS = 1
SPMEN = 0

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
    clr r3
    out __SREG__, r3 ; clear sreg
; init real sp at end of sram
    ldi r25, hi8(SRAM_END)
    out __SP_H__, r25
    ldi r24, lo8(SRAM_END)
    out __SP_L__, r24
; enable interrupts
    sei
    rjmp BOOT

;----------------------------------------------------------------------
;
;   do not use r0 and r1 are scratch registers used in spm, mul, des, etc
;
;   generic:
;   r2 , how knows ?
;   r3 , always zero
;   r4 , offset to prescale
;      
;   for timer0:
;   r5 , saved SREG
;   r6 , counter each 1ms low byte
;   r7 , counter each 1ms high byte
;
;   timer0 prescale 
;   for 8 MHz, prescale 64, offset 131, results about 1 ms
;   64 * 125 = 8000 ; 
;   256 - 125 = 131 ; offset for miliseconds
;
;   ticks counts till 65 seconds
;
; interrupt routine
TIM0_OVF:
; save flags
    in r2, __SREG__
; disable interrups
    cli
; increase counter and also clear 
    clc
; do not use r0 or r1 elsewhere
    clr r3
    inc r3
    add ticks_low, r3
    dec r3
    adc ticks_high, r3
; offset counter 256 - 125 = 131
; but was 10 clocks till out, 
; then 131 + 10 = 141
OFFSETCNT = 141
    out TCNT0, r4
; reset watch dog
    wdr
; load flags and return
    out __SREG__, r2
; enable interrups
    sei
    reti

;----------------------------------------------------------------------
/*

OSCAL calibration,
from atmel 2555 note:
for atmega8 theorical for 25oC at 5V, value is 168.
for optiboot, value is 143 as sample better for 38400 bauds, maybe less for 40oC
CFLAGS += '-DMAX_TIME_COUNT=F_CPU>>4' '-DOSC_CAL=142' '-DNUM_LED_FLASHES=2' -DBAUD_RATE=38400
*/

;----------------------------------------------------------------------
; hook to init hardware
BOOT:
   cli

;----------------------------------------------------------------------
; init timer0, with internal clock 8MHz, from gcc public code, io ports as constants
;
; preset of timer0, with internal clock 8MHz ; cycle 64 ; offset 131
; timer cycle * offset / clock = 8k/8M = 1ms
;
TIMER0_SET:
; enable pre-escaler
    in r16, TCCR0
    ori r16, (1 << 1) | (1 << 0)
    out TCCR0, r16
; offset counter, so it counts 125 clocks inside the interrup routines
    ldi r16, OFFSETCNT
; preserve offset
    mov r4, r16
    out TCNT0, r16
; enable counter
    in r16, TIMSK
    ori r16, (1 << 0) 
    out TIMSK, r16

;----------------------------------------------------------------------
; init watch dog, from avr-gcc public code, io ports as constants
;
; write logical one to WDCE and WDE, set WDP2, WDP1, WDP0 to ~ 2.0 s
;
WATCHDOG_SET:
    in r16, WDTCR
    ori r16, (1 << 4) | (1 << 3)
    ori r16, (1 << 2) | (1 << 1) | (1 << 0)
    out WDTCR, r16

;----------------------------------------------------------------------
; init usart, from avr-gcc public code
;
;   defaults to 9600, 8N1, no control
;
USART_SET:
    clr wrk_low
    out UCSRC, wrk_low
    ldi wrk_low, lo8(52)
    out UBRRL, wrk_low
    in wrk_low, UCSRB
    ori wrk_low, lo8(24)
    out UCSRB, wrk_low
    ldi wrk_low, lo8(-114)
    out UCSRC, wrk_low
    in wrk_low, UCSRC
    ori wrk_low,lo8(64)
    out UCSRC, wrk_low

;----------------------------------------------------------------------
; enable interrupts
GOOD:
    sei
    rjmp COLD 

#ifdef EEPS

;----------------------------------------------------------------------
;
;   Assembly Code Example, from AVR manual
;
EEPROM_write:
; Wait for completion of previous write
    sbic EECR, EEPE
    rjmp EEPROM_write
; Set up address (r18:r17) in address register
    out EEARH, r25
    out EEARL, r24
; Write data (r16) to Data Register
    out EEDR, r22
; Write logical one to EEMPE
    sbi EECR, EEMPE
; Start eeprom write by setting EEPE
    sbi EECR, EEPE
    ret

EEPROM_read:
; Wait for completion of previous write
    sbic EECR, EEPE
    rjmp EEPROM_read
; Set up address (r18:r17) in address register
    out EEARH, r25
    out EEARL, r24
; Start eeprom read by writing EERE
    sbi EECR, EERE
; Read data from Data Register
    in r22, EEDR
    ret

#endif

.equ bios_end, .
