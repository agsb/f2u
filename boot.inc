;----------------------------------------------------------------------
;
; code segment, flash
;
.section .text
; .org 0x00000
.global main
main:

;----------------------------------------------------------------------
;
; interrup vector table
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
;    timer0 prescale using 64,  default for 8 MHz
;
;   miliseconds
;
;    count as 61, about 1008,07 Hz
;    count as 62, about  992,07 Hz, 
;
;    counter cotinues while inside ? 
;   without these instructions ?
;
TIM0_OVF:
;    save flags and stop interrups
    in R5, __SREG__
    cli
;    reset watch dog
    wdr
;    get counter
    lds R3, TIMER
    lds R2, TIMER+1
;    increase counter
    eor    R4, R4
    inc R4
    add R2, R4
    dec R4
    adc R2, R4
;    put counter
    sts TIMER, R3
    sts TIMER+1, R2
;    adjusts counter
;    out TCNT0H, R2
;    out TCNT0L, R3

;    load flags and return
    out __SREG__, R5
    sei
    reti

;----------------------------------------------------------------------
; watch dog
;    WDTCSR = bit (WDIE) | bit (WDP2) | bit (WDP1);    // set WDIE, and 1 second delay
;
#define WDIE    6
#define WDP2    2
#define WDP1    1
#define WDE     3
#define WDCE    4

; reset WDT
    wdr
;
;  define watch dog counter
;    ??? code
;
; write logical one to WDCE and WDE
;    in wrk_low, WDTCR
;    ori wrk_low, (1<<WDCE)|(1<<WDE)
;    out WDTCR, wrk_low    
; turn off wd
;    ldi wrk_low, (0<<WDE)
;    out WDTRC, wrk_low
; set WDIE, and 1 second delay
;    ori wrk_low, (1<<WDIE)|(1<<WDP2)|(1<<WDP1)
;    out WDTCR, wrk_low

; Enable interrupts
    sei

;----------------------------------------------------------------------
; 
RESET:
; clear interrupts
    cli
; init _zero_as zero
    eor _zero_, _zero_; exclusive or, xor
    out __SREG__, _zero_; clear sreg
; init real sp at end of sram
    ldi wrk_high, hi8(SPP_TOP)
    out __SP_H__, wrk_high
    ldi wrk_low, lo8(SPP_TOP)
    out __SP_L__, wrk_low
; eneble interrupts
    sei
    rjmp BYE

