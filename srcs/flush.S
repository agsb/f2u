

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

/*

routines for flush flash memory

SPM_PAGE, page size
page_old = 0;

void flush (int value, int address) {

// define flash page and position

    int pos = address AND (SPM_PAGE - 1);
    int page = address AND ~(SPM_PAGE - 1);

    if ( page != page_old ) {
            if (page_old) save_page(page_old);
            load_page(page);
            page_old = page;
            }

    buffer[pos] = lo8(value)
    pos += 1;
    buffer[pos] = hi8(value)
}

: FLUSH
    
    PAGE_OLD @ DUP PAGE @
    = INVERT IF 
        IF SAVE_PAGE THEN
        LOAD_PAGE 
        PAGE @ PAGE_OLD !
        THEN
     
*/
;
;   to flash (w a -- )
;

;----------------------------------------------------------------------
;
;   load a flash memory page (fa sa -- )
;   copy one flash page from flash address fa to sram address sa
;
HEADER "(load_flash)", "LDFLASH"
    NOOP

    ; destin
    pspull nos_low, nos_high

    ; origin
    pspull zpm_low, zpm_high

    ; preserve stack
    rspush psp_low, psp_high

    movw psp_low, nos_low

    ; make round down pagesize, pagemask is ~pagesize
    ; andi zpm_high, hi8(pagemask) ; not need if pagesize < 256
    andi zpm_low, lo8(pagemask)

    ; adjust address for lpm
    lsr zpm_low
    rol zpm_high

    ; how many bytes
    lds wrk_low, SPM_PAGE

1:
    lpm _work_, Z+
    st X+, _work_
    dec wrk_low
    brne 1b

    rspull psp_low, psp_high
    POON

;----------------------------------------------------------------------
;
;   save a flash memory page (sa fa -- )
;   copy one flash page from sram address sa to flash address fa
;   registers exposed are used for optiboot compiled with gcc
;
HEADER "(save_flash)", "SVFLASH"
    NOOP

    ; from sram
    pspull nos_low, nos_high

    ; into flash
    pspull r24, r25

    ; save psp 
    rspush psp_low, psp_high

    movw psp_low, nos_low

    ; mask to match correct address
    ; andi r25, hi8(pagemask) ; not need if pagesize < 256
    andi r24, lo8(pagemask)

    ; save address
    rspush r24, r25

    ; erase page
    ; r0:r1 is ignored, ATmega8L datasheet, pg 209
    ldi r22, (1<<PGERS) | (1<<SPMEN)
    rcall _does_spm

    ; how many bytes, less than 256!
    ldi r23, SPM_PAGE

    ; copy page, word by word
2:
    ; fill page flash from sram
    ld r20, X+
    ld r21, X+
    ldi r22, (1<<SPMEN)
    rcall _does_spm
    adiw zpm_low, 2

    ; count down
    dec r23
    dec r23
    brne 2b

    ; load address
    rspull r24, r25

    ; write page
    ; r0:r1 is ignored, ATmega8L datasheet, pg 209
    ldi r22, (1<<PGWRT) | (1<<SPMEN)
    rcall _does_spm

    ; clean house
    rspull psp_low, psp_high
    POON

;----------------------------------------------------------------------
;
; wrapper around optiboot code
;

#define OPTI_DO_SPM 0x1fb0

_does_spm:
    in _sreg_, __SREG__
    cli
    rcall OPTI_DO_SPM
    out __SREG__, _sreg_
    ret

;----------------------------------------------------------------------
/* from optiboot version 8.2 listing, extra comments added
        ;
        ; the code for spm must reside in the NRWW flash
        ;
        ; make TARGET=Atmega8 AVR_FREQ=8000000L BAUD_RATE=9600 LED_START_FLASHES=5 TIMEOUT=2
        ;
        ; static void do_spm(uint16_t address, uint8_t command, uint16_t data)
        ; r24:r25, r22:r23, r20:r21
        ;
        ; Do spm stuff
        ;
        ; do_spm is 1fb0
    1fb0:       fc 01           movw    r30, r24
    1fb2:       0a 01           movw    r0, r20
    1fb4:       67 bf           out     0x37, r22       ; 55
    1fb6:       e8 95           spm
        ;
        ;       keep r1 as zero
        ;
    1fb8:       11 24           eor     r1, r1
        ;
        ; static void boot_spm_busy_wait()
        ;
        ;       loop while not done
    1fba:       07 b6           in      r0, 0x37        ; 55
    1fbc:       00 fc           sbrc    r0, 0
    1fbe:       fd cf           rjmp    .-6             ; 0x1fba <do_spm+0xa>
        ;
        ;       if ( (command & (_BV(PGWRT)|_BV(PGERS))) && (data == 0) )
        ;
    1fc0:       66 70           andi    r22, 0x06       ; 6
    1fc2:       29 f0           breq    .+10            ; 0x1fce <do_spm+0x1e>
    1fc4:       45 2b           or      r20, r21
    1fc6:       19 f4           brne    .+6             ; 0x1fce <do_spm+0x1e>
    ;
        ;       static void boot_rww_enable_short()
        ;
    1fc8:       81 e1           ldi     r24, 0x11       ; 17
    1fca:       87 bf           out     0x37, r24       ; 55
    1fcc:       e8 95           spm
        ;
        ;       return
        ;
    1fce:       08 95           ret
*/



