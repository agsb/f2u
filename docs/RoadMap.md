RoadMap.md

# RoadMap

Topics for routines that must exists

# BIOS

```
_reset

_usart_send

_usart_receive

_i2c_send

_i2c_receive

_spi_send

_spi_receive

_e2prom_page_load

_e2prom_page_save

_flash_page_load

_flash_page_save

_gpio_write

_gpio_read

_clock_setup

_watchdog_setup

_clock_tick

_watchdog_tick

_boot_setup

_rest_setup
```
# Forth insides

Those must exist for Forth REPL work
```
 COLD
 WARM
 BYE
 QUIT
 WORD
 ACCEPT
 PARSE
 FIND
 COMPILE
 EXECUTE
 POSTPONE
 ABORT
 EVAL
 WORD?
 NUMBER?
```` 
# functional routines

- _accept*   fills terminal input buffer until a CR/CC, also process comments and control convertions

- _word*   takes a word from terminal input buffer

- _parse*  parses contents of terminal input buffer

- _find*   search dictionary for a word

- _number? verify and converts a number to a value and push into parameter stack

- _word? verify and search a word and push the reference into parameter stack

