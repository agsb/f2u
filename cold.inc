;----------------------------------------------------------------------
; init instruction pointer and etc
;
HEADER "BYE", "BYE"
    NOOP
    rjmp RESET
    POON

;----------------------------------------------------------------------
;
HEADER "COLD", "COLD"
    NOOP

; disable interrupts
    cli

; clear scratchs
    clr r0
    clr r1

; clear timer0 counter
    clr r2
    clr r3

; define timer0 offset
    ldi r16, 141
    mov r4, r16

; enable interrupts
    sei

; restart return stack
    ldi rsp_low, lo8(RSP_TOP)
    ldi rsp_high, hi8(RSP_TOP)

    sts _wRSP0+0, rsp_low
    sts _wRSP0+1, rsp_high

; restart parameter stack
    ldi psp_low, lo8(PSP_TOP)
    ldi psp_high, hi8(PSP_TOP)

    sts _wPSP0+0, psp_low
    sts _wPSP0+1, psp_high

; preload to WARM
    ldi ips_low, lo8(WARM)
    ldi ips_high, hi8(WARM)
    rspush ips_low, ips_high
    POON


