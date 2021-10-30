

/*

routines for flush flash memory

SPM_PAGE, page size
page_old = 0;
mark = 0;

void flush (int value, int address) {

    int pos = address AND (SPM_PAGE - 1)
    int page = address AND ~(SPM_PAGE - 1)

    if ( page != page_old ) {
            if (mark == 1) save_page(page_old);
            mark = 0;
            }

    PAGE @ PAGE_OLD @ 
    = INVERT IF 
        MARK ONE = IF 
            SAVE_PAGE 
            THEN
        0 MARK ! 
        THEN
    MARK 0 = IF
        PAGE @ PAGE_OLD !
        LOAD_PAGE 
        ONE MARK !
        THEN    
     
    if (mark == 0) {
            load_page(page);
            page_old = page;
            mark = 1;
            }

    buffer[pos] = lo8(value)
    pos += 1;
    buffer[pos] = hi8(value)

}

*/
;
;   to flash (w a -- )
;

VARIABLE MARK
VARIABLE PAGE

HEADER "(flush)", "TOFLASH"
    
    NOOP

    pspull tos_low, tos_high
    pspull nds_low, nds_high
    
    movw wrk_low, tos_low
    andi wrk_low, pagesize

    cp wrk_low, page_old
    brne
    POON

;----------------------------------------------------------------------
;
;  load a flash memory page (a -- )
;  into FIB
HEADER "(load_flash)", "LDFLASH"
    NOOP
    ; preserve stack
    rspush psp_low, psp_high

    ; origin
    pspull zpm_low, zpm_high

    ; make round down pagesize, pagemask is ~pagesize
    andi zpm_low, lo8(pagemask)
    ; andi zpm_high, hi8(pagemask) ; not need if pagesize < 256

    ; destin
    ldi psp_low, lo8(FIB)
    ldi psp_high, hi8(FIB)
        
    ; how many bytes
    lds wrk_low, SPM_PAGESIZE

    ; adjust address for lpm
    lsr zpm_low
    rol zpm_high
1:
    lpm _work_, Z+
    st X+, _work_
    dec wrk_low
    brne 1b

    rspull psp_low, psp_high
    POON

;----------------------------------------------------------------------
;
;  save a flash memory page (a -- )
;  from FIB
;   registers exposed are used for optiboot compiled with gcc
;
HEADER "(save_flash)", "SVFLASH"
    NOOP

    ; save psp for index
    rspush psp_low, psp_high

    ; to flash page
    pspull r24, r25

    ; mask to match correct address
    ; andi r25, hi8(pagemask) ; not need if pagesize < 256
    andi r24, lo8(pagemask)

    ; save address
    rspush r24, r25

    ; erase page
    ; r0:r1 is ignored, ATmega8L datasheet, pg 209
    ldi r22, (1<<PGERS) | (1<<SPMEN)
    rcall _does_spm

    ; from sram buffer
    ldi psp_low, lo8(FIB)
    ldi psp_high, hi8(FIB)

    ; how many bytes
    ldi r23, lo8(SPM_PAGESIZE)

    ; copy page
20:
    ; fill page flash from sram
    ld r20, X+
    ld r21, X+
    ldi r22, (1<<SPMEN)
    rcall _does_spm
    adiw zpm_low, 2

    ; count down
    dec r23
    dec r23
    brne 20b

    ; load address
    rspull r24, r25

    ; write page
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
        sei
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



