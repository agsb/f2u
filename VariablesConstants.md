VariablesConstants.md

## variables in eeprom

## Variables in sram

    SEED:   (seed for random generator)
    TURN:   (pointer to turn-key routine)
    DP:     (dictionary pointer in flash memory)
    UP:     (list pointer in static ram)
    EP:     (list pointer in) eprom)
    LATEST: (pointer to last word in flash memory)
    HLD:    (cursor of transient buffer to format numbers, 16 bytes)
    PAD:    (cursor of buffer for flush flash pages)
    TIB:    (terminal input buffer)
    INTO:   ( >IN)
    BASE:   (numeric radix to use in conversion)
    STATE:  (current state for interpreter)

## Constants address in sram

    VERSION (version of this)
    SP0     (top real stack pointer)
    PS0     (top of parameter stack)
    RP0     (top of return stack)
    TIB0    (start of terminal input buffer)
    PAD0    (start of scratch buffer)
    HLD0    (start of number conversion buffer)



