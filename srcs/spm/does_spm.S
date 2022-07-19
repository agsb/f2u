
static void does_spm( void ) {
    // easy way, no stack overflow :)
    //
    // r0,r1   used by spm, sram page address
    // r30,r31 used by spm, flash page address
    //
    // r20,r21  address in sram
    // r22,r23  command and sreg stor
    //
    //  read out to page buffer === 0x01
    //  erase out flash page === 0x03
    //  write data out to flash page === 0x05

    //      0x37 === (_SFR_IO_ADDR(__SPM_REG))
    //      0x06
    //      0x11 === (1<<RWWSRE) | (1<<SPMEN)
    //
    // Does not check for eeprom writes
    //
    asm volatile (
        "   movw r0, r20\n"
        "   in r23, SREG\n"
        "   cli\n"
        "   out 0x37, r22\n"
        "   spm\n"
        // wait spm ends
        "1: in r0, 0x37\n" 
        "   sbrc r0, 0\n"
        "   rjmp 1b\n"
        // check if need rewrite
        "   andi r22, 0x06\n"
        "   breq 2f\n"
        "   or r20, r21\n"
        "   brne 2f\n"
        // enable write
        "   ldi r1, 0x11\n"
        "   out 0x37, r1\n" 
        "   spm\n"
        "2: out SREG, r23\n"
        "   ret\n"
        );
    }

