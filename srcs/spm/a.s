   1               		.file	"optiboot_flash.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__tmp_reg__ = 0
   6               	__zero_reg__ = 1
   9               		.text
  10               	.Ltext0:
 116               	.global	optiboot_version
 117               		.section	.version,"a",@progbits
 120               	optiboot_version:
 121 0000 0007      		.word	1792
 122               		.section	.init8,"ax",@progbits
 124               	.global	pre_main
 126               	pre_main:
 127               		.stabd	46,0,0
   1:optiboot_flash.c **** #define FUNC_READ 1
   2:optiboot_flash.c **** #define FUNC_WRITE 1
   3:optiboot_flash.c **** /**********************************************************/
   4:optiboot_flash.c **** /* MCUdude's Optiboot bootloader for Arduino              */
   5:optiboot_flash.c **** /*                                                        */
   6:optiboot_flash.c **** /* Based on majekw's Optiboot fork.                       */
   7:optiboot_flash.c **** /* http://github.com/majekw/optiboot                      */
   8:optiboot_flash.c **** /*                                                        */
   9:optiboot_flash.c **** /* It is the intent that changes not relevant to the      */
  10:optiboot_flash.c **** /* Arduino production envionment get moved from the       */
  11:optiboot_flash.c **** /* optiboot project to the arduino project in "lumps."    */
  12:optiboot_flash.c **** /*                                                        */
  13:optiboot_flash.c **** /* Heavily optimised bootloader that is faster and        */
  14:optiboot_flash.c **** /* smaller than the Arduino standard bootloader           */
  15:optiboot_flash.c **** /*                                                        */
  16:optiboot_flash.c **** /* Enhancements:                                          */
  17:optiboot_flash.c **** /*   Fits in 512 bytes, saving 1.5K of code space         */
  18:optiboot_flash.c **** /*   Higher baud rate speeds up programming               */
  19:optiboot_flash.c **** /*   Written almost entirely in C                         */
  20:optiboot_flash.c **** /*   Customisable timeout with accurate timeconstant      */
  21:optiboot_flash.c **** /*   Optional virtual UART. No hardware UART required.    */
  22:optiboot_flash.c **** /*   Optional virtual boot partition for devices without. */
  23:optiboot_flash.c **** /*   Supports "write to flash" in application!            */
  24:optiboot_flash.c **** /*                                                        */
  25:optiboot_flash.c **** /* What you lose:                                         */
  26:optiboot_flash.c **** /*   Implements a skeleton STK500 protocol which is       */
  27:optiboot_flash.c **** /*   missing several features including EEPROM            */
  28:optiboot_flash.c **** /*   programming and non-page-aligned writes              */
  29:optiboot_flash.c **** /*   High baud rate breaks compatibility with standard    */
  30:optiboot_flash.c **** /*   Arduino flash settings                               */
  31:optiboot_flash.c **** /*                                                        */
  32:optiboot_flash.c **** /*                                                        */
  33:optiboot_flash.c **** /* Supported microcontrollers:                            */
  34:optiboot_flash.c **** /* See https://github.com/MCUdude/optiboot_flash          */
  35:optiboot_flash.c **** /*                                                        */                                       
  36:optiboot_flash.c **** /* Assumptions:                                           */
  37:optiboot_flash.c **** /*   The code makes several assumptions that reduce the   */
  38:optiboot_flash.c **** /*   code size. They are all true after a hardware reset, */
  39:optiboot_flash.c **** /*   but may not be true if the bootloader is called by   */
  40:optiboot_flash.c **** /*   other means or on other hardware.                    */
  41:optiboot_flash.c **** /*     No interrupts can occur                            */
  42:optiboot_flash.c **** /*     UART and Timer 1 are set to their reset state      */
  43:optiboot_flash.c **** /*     SP points to RAMEND                                */
  44:optiboot_flash.c **** /*                                                        */
  45:optiboot_flash.c **** /* Code builds on code, libraries and optimisations from: */
  46:optiboot_flash.c **** /*   stk500boot.c          by Jason P. Kyle               */
  47:optiboot_flash.c **** /*   Arduino bootloader    http://arduino.cc              */
  48:optiboot_flash.c **** /*   Spiff's 1K bootloader http://spiffie.org/know/arduino_1k_bootloader/bootloader.shtml */
  49:optiboot_flash.c **** /*   avr-libc project      http://nongnu.org/avr-libc     */
  50:optiboot_flash.c **** /*   Adaboot               http://www.ladyada.net/library/arduino/bootloader.html */
  51:optiboot_flash.c **** /*   AVR305                Atmel Application Note         */
  52:optiboot_flash.c **** /*                                                        */
  53:optiboot_flash.c **** /*                                                        */
  54:optiboot_flash.c **** /* Copyright 2013-2015 by Bill Westfield.                 */
  55:optiboot_flash.c **** /* Copyright 2010 by Peter Knight.                        */
  56:optiboot_flash.c **** /*                                                        */
  57:optiboot_flash.c **** /* This program is free software; you can redistribute it */
  58:optiboot_flash.c **** /* and/or modify it under the terms of the GNU General    */
  59:optiboot_flash.c **** /* Public License as published by the Free Software       */
  60:optiboot_flash.c **** /* Foundation; either version 2 of the License, or        */
  61:optiboot_flash.c **** /* (at your option) any later version.                    */
  62:optiboot_flash.c **** /*                                                        */
  63:optiboot_flash.c **** /* This program is distributed in the hope that it will   */
  64:optiboot_flash.c **** /* be useful, but WITHOUT ANY WARRANTY; without even the  */
  65:optiboot_flash.c **** /* implied warranty of MERCHANTABILITY or FITNESS FOR A   */
  66:optiboot_flash.c **** /* PARTICULAR PURPOSE.  See the GNU General Public        */
  67:optiboot_flash.c **** /* License for more details.                              */
  68:optiboot_flash.c **** /*                                                        */
  69:optiboot_flash.c **** /* You should have received a copy of the GNU General     */
  70:optiboot_flash.c **** /* Public License along with this program; if not, write  */
  71:optiboot_flash.c **** /* to the Free Software Foundation, Inc.,                 */
  72:optiboot_flash.c **** /* 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA */
  73:optiboot_flash.c **** /*                                                        */
  74:optiboot_flash.c **** /* Licence can be viewed at                               */
  75:optiboot_flash.c **** /* http://www.fsf.org/licenses/gpl.txt                    */
  76:optiboot_flash.c **** /*                                                        */
  77:optiboot_flash.c **** /**********************************************************/
  78:optiboot_flash.c **** 
  79:optiboot_flash.c **** 
  80:optiboot_flash.c **** /**********************************************************/
  81:optiboot_flash.c **** /*                                                        */
  82:optiboot_flash.c **** /* Optional defines:                                      */
  83:optiboot_flash.c **** /*                                                        */
  84:optiboot_flash.c **** /**********************************************************/
  85:optiboot_flash.c **** /*                                                        */
  86:optiboot_flash.c **** /*                                                        */
  87:optiboot_flash.c **** /* BAUD_RATE:                                             */
  88:optiboot_flash.c **** /* Set bootloader baud rate.                              */
  89:optiboot_flash.c **** /*                                                        */
  90:optiboot_flash.c **** /* SOFT_UART:                                             */
  91:optiboot_flash.c **** /* Use AVR305 soft-UART instead of hardware UART.         */
  92:optiboot_flash.c **** /*                                                        */
  93:optiboot_flash.c **** /* LED_START_FLASHES:                                     */
  94:optiboot_flash.c **** /* Number of LED flashes on bootup.                       */
  95:optiboot_flash.c **** /*                                                        */
  96:optiboot_flash.c **** /* LED_DATA_FLASH:                                        */
  97:optiboot_flash.c **** /* Flash LED when transferring data. For boards without   */
  98:optiboot_flash.c **** /* TX or RX LEDs, or for people who like blinky lights.   */
  99:optiboot_flash.c **** /*                                                        */
 100:optiboot_flash.c **** /* UART:                                                  */
 101:optiboot_flash.c **** /* UART number (0..n) for devices with more than          */
 102:optiboot_flash.c **** /* one hardware uart (644P, 1284P, etc)                   */
 103:optiboot_flash.c **** /*                                                        */
 104:optiboot_flash.c **** /* TIMEOUT_MS:                                            */
 105:optiboot_flash.c **** /* Bootloader timeout period, in milliseconds.            */
 106:optiboot_flash.c **** /* 500,1000,2000,4000,8000 supported.                     */
 107:optiboot_flash.c **** /*                                                        */
 108:optiboot_flash.c **** /* SUPPORT_EEPROM:                                        */
 109:optiboot_flash.c **** /* Support reading and writing from EEPROM. This is not   */
 110:optiboot_flash.c **** /* used by Arduino, so off by default.                    */
 111:optiboot_flash.c **** /*                                                        */
 112:optiboot_flash.c **** /* COPY_FLASH_PAGES:                                      */
 113:optiboot_flash.c **** /* Adds function to copy flash pages. The function is     */
 114:optiboot_flash.c **** /* intended to be called by the application.              */
 115:optiboot_flash.c **** /*                                                        */
 116:optiboot_flash.c **** /**********************************************************/
 117:optiboot_flash.c **** 
 118:optiboot_flash.c **** /**********************************************************/
 119:optiboot_flash.c **** /* Version Numbers!                                       */
 120:optiboot_flash.c **** /*                                                        */
 121:optiboot_flash.c **** /* Arduino Optiboot now includes this Version number in   */
 122:optiboot_flash.c **** /* the source and object code.                            */
 123:optiboot_flash.c **** /*                                                        */
 124:optiboot_flash.c **** /* Version 3 was released as zip from the optiboot        */
 125:optiboot_flash.c **** /*  repository and was distributed with Arduino 0022.     */
 126:optiboot_flash.c **** /* Version 4 starts with the arduino repository commit    */
 127:optiboot_flash.c **** /*  that brought the arduino repository up-to-date with   */
 128:optiboot_flash.c **** /*  the optiboot source tree changes since v3.            */
 129:optiboot_flash.c **** /* Version 5 was created at the time of the new Makefile  */
 130:optiboot_flash.c **** /*  structure (Mar, 2013), even though no binaries changed*/
 131:optiboot_flash.c **** /* It would be good if versions implemented outside the   */
 132:optiboot_flash.c **** /*  official repository used an out-of-seqeunce version   */
 133:optiboot_flash.c **** /*  number (like 104.6 if based on based on 4.5) to       */
 134:optiboot_flash.c **** /*  prevent collisions.                                   */
 135:optiboot_flash.c **** /*                                                        */
 136:optiboot_flash.c **** /**********************************************************/
 137:optiboot_flash.c **** 
 138:optiboot_flash.c **** /**********************************************************/
 139:optiboot_flash.c **** /* Edit History:                                          */
 140:optiboot_flash.c **** /*                                                        */
 141:optiboot_flash.c **** /* July 2018                                              */
 142:optiboot_flash.c **** /* 7.0  WestfW (with much input from others)              */
 143:optiboot_flash.c **** /*    Fix MCUSR treatement as per much discussion,        */
 144:optiboot_flash.c **** /*    Patches by MarkG55, majekw.                         */ 
 145:optiboot_flash.c **** /*    Preserve value for the application,                 */
 146:optiboot_flash.c **** /*    as much as possible.                                */
 147:optiboot_flash.c **** /*    See https://github.com/Optiboot/optiboot/issues/97  */
 148:optiboot_flash.c **** /*    Optimize a bit by implementing a union for the      */
 149:optiboot_flash.c **** /*    various 16bit address values used (based on         */
 150:optiboot_flash.c **** /*    observation by "aweatherguy", but different.)       */
 151:optiboot_flash.c **** /*    Slightly optimize math in VIRTUAL_BOOT code         */
 152:optiboot_flash.c **** /*    Add some virboot targets, fix some fuses.           */
 153:optiboot_flash.c **** /*    Implement LED_START_ON; less code than flashes      */
 154:optiboot_flash.c **** /*                                                        */
 155:optiboot_flash.c **** /* Aug 2014                                               */
 156:optiboot_flash.c **** /* 6.2 WestfW: make size of length variables dependent    */
 157:optiboot_flash.c **** /*              on the SPM_PAGESIZE.  This saves space    */
 158:optiboot_flash.c **** /*              on the chips where it's most important.   */
 159:optiboot_flash.c **** /* 6.1 WestfW: Fix OPTIBOOT_CUSTOMVER (send it!)          */
 160:optiboot_flash.c **** /*             Make no-wait mod less picky about          */
 161:optiboot_flash.c **** /*               skipping the bootloader.                 */
 162:optiboot_flash.c **** /*             Remove some dead code                      */
 163:optiboot_flash.c **** /*                                                        */
 164:optiboot_flash.c **** /* Jun 2014                                               */
 165:optiboot_flash.c **** /* 6.0 WestfW: Modularize memory read/write functions     */
 166:optiboot_flash.c **** /*             Remove serial/flash overlap                */
 167:optiboot_flash.c **** /*              (and all references to NRWWSTART/etc)     */
 168:optiboot_flash.c **** /*             Correctly handle pagesize > 255bytes       */
 169:optiboot_flash.c **** /*             Add EEPROM support in BIGBOOT (1284)       */
 170:optiboot_flash.c **** /*             EEPROM write on small chips now causes err */
 171:optiboot_flash.c **** /*             Split Makefile into smaller pieces         */
 172:optiboot_flash.c **** /*             Add Wicked devices Wildfire                */
 173:optiboot_flash.c **** /*         Move UART=n conditionals into pin_defs.h       */
 174:optiboot_flash.c **** /*         Remove LUDICOUS_SPEED option                   */
 175:optiboot_flash.c **** /*         Replace inline assembler for .version          */
 176:optiboot_flash.c **** /*              and add OPTIBOOT_CUSTOMVER for user code  */
 177:optiboot_flash.c **** /*             Fix LED value for Bobuino (Makefile)       */
 178:optiboot_flash.c **** /*             Make all functions explicitly inline or    */
 179:optiboot_flash.c **** /*              noinline, so we fit when using gcc4.8     */
 180:optiboot_flash.c **** /*             Change optimization options for gcc4.8     */
 181:optiboot_flash.c **** /*             Make ENV=arduino work in 1.5.x trees.      */
 182:optiboot_flash.c **** /*                                                        */
 183:optiboot_flash.c **** /* May 2014                                               */
 184:optiboot_flash.c **** /* 5.0 WestfW: Add support for 1Mbps UART                 */
 185:optiboot_flash.c **** /*                                                        */
 186:optiboot_flash.c **** /* Mar 2013                                               */
 187:optiboot_flash.c **** /* 5.0 WestfW: Major Makefile restructuring.              */
 188:optiboot_flash.c **** /*             See Makefile and pin_defs.h                */
 189:optiboot_flash.c **** /*             (no binary changes)                        */
 190:optiboot_flash.c **** /* 4.6 WestfW/Pito: Add ATmega32 support                  */
 191:optiboot_flash.c **** /* 4.6 WestfW/radoni: Don't set LED_PIN as an output if   */
 192:optiboot_flash.c **** /*                    not used. (LED_START_FLASHES = 0)   */
 193:optiboot_flash.c **** /*                                                        */
 194:optiboot_flash.c **** /* Jan 2013                                               */
 195:optiboot_flash.c **** /* 4.6 WestfW/dkinzer: use autoincrement lpm for read     */
 196:optiboot_flash.c **** /* 4.6 WestfW/dkinzer: pass reset cause to app in R2      */
 197:optiboot_flash.c **** /*                                                        */
 198:optiboot_flash.c **** /* Mar 2012                                               */
 199:optiboot_flash.c **** /* 4.5 WestfW: add infrastructure for non-zero UARTS.     */
 200:optiboot_flash.c **** /* 4.5 WestfW: fix SIGNATURE_2 for m644 (bad in avr-libc) */
 201:optiboot_flash.c **** /*                                                        */
 202:optiboot_flash.c **** /* Jan 2012:                                              */
 203:optiboot_flash.c **** /* 4.5 WestfW: fix NRWW value for m1284.                  */
 204:optiboot_flash.c **** /* 4.4 WestfW: use attribute OS_main instead of naked for */
 205:optiboot_flash.c **** /*             main().  This allows optimizations that we */
 206:optiboot_flash.c **** /*             count on, which are prohibited in naked    */
 207:optiboot_flash.c **** /*             functions due to PR42240.  (keeps us less  */
 208:optiboot_flash.c **** /*             than 512 bytes when compiler is gcc4.5     */
 209:optiboot_flash.c **** /*             (code from 4.3.2 remains the same.)        */
 210:optiboot_flash.c **** /* 4.4 WestfW and Maniacbug:  Add m1284 support.  This    */
 211:optiboot_flash.c **** /*             does not change the 328 binary, so the     */
 212:optiboot_flash.c **** /*             version number didn't change either. (?)   */
 213:optiboot_flash.c **** /*                                                        */
 214:optiboot_flash.c **** /* June 2011:                                             */
 215:optiboot_flash.c **** /* 4.4 WestfW: remove automatic soft_uart detect (didn't  */
 216:optiboot_flash.c **** /*             know what it was doing or why.)  Added a   */
 217:optiboot_flash.c **** /*             check of the calculated BRG value instead. */
 218:optiboot_flash.c **** /*             Version stays 4.4; existing binaries are   */
 219:optiboot_flash.c **** /*             not changed.                               */
 220:optiboot_flash.c **** /* 4.4 WestfW: add initialization of address to keep      */
 221:optiboot_flash.c **** /*             the compiler happy.  Change SC'ed targets. */
 222:optiboot_flash.c **** /*             Return the SW version via READ PARAM       */
 223:optiboot_flash.c **** /* 4.3 WestfW: catch framing errors in getch(), so that   */
 224:optiboot_flash.c **** /*             AVRISP works without HW kludges.           */
 225:optiboot_flash.c **** /*  http://code.google.com/p/arduino/issues/detail?id=368n*/
 226:optiboot_flash.c **** /* 4.2 WestfW: reduce code size, fix timeouts, change     */
 227:optiboot_flash.c **** /*             verifySpace to use WDT instead of appstart */
 228:optiboot_flash.c **** /* 4.1 WestfW: put version number in binary.              */
 229:optiboot_flash.c **** /**********************************************************/
 230:optiboot_flash.c **** 
 231:optiboot_flash.c **** #define OPTIBOOT_MAJVER 7
 232:optiboot_flash.c **** #define OPTIBOOT_MINVER 0
 233:optiboot_flash.c **** 
 234:optiboot_flash.c **** /*
 235:optiboot_flash.c ****  * OPTIBOOT_CUSTOMVER should be defined (by the makefile) for custom edits
 236:optiboot_flash.c ****  * of optiboot.  That way you don't wind up with very different code that
 237:optiboot_flash.c ****  * matches the version number of a "released" optiboot.
 238:optiboot_flash.c ****  */
 239:optiboot_flash.c **** 
 240:optiboot_flash.c **** #if !defined(OPTIBOOT_CUSTOMVER)
 241:optiboot_flash.c **** #define OPTIBOOT_CUSTOMVER 0
 242:optiboot_flash.c **** #endif
 243:optiboot_flash.c **** 
 244:optiboot_flash.c **** unsigned const int __attribute__((section(".version"))) 
 245:optiboot_flash.c **** optiboot_version = 256*(OPTIBOOT_MAJVER + OPTIBOOT_CUSTOMVER) + OPTIBOOT_MINVER;
 246:optiboot_flash.c **** 
 247:optiboot_flash.c **** 
 248:optiboot_flash.c **** #include <inttypes.h>
 249:optiboot_flash.c **** #include <avr/io.h>
 250:optiboot_flash.c **** #include <avr/pgmspace.h>
 251:optiboot_flash.c **** #include <avr/eeprom.h>
 252:optiboot_flash.c **** 
 253:optiboot_flash.c **** #include "boot.h"
 254:optiboot_flash.c **** #include "pin_defs.h"
 255:optiboot_flash.c **** #include "stk500.h"
 256:optiboot_flash.c **** 
 257:optiboot_flash.c **** /*
 258:optiboot_flash.c ****  * optiboot uses several "address" variables that are sometimes byte pointers,
 259:optiboot_flash.c ****  * sometimes word pointers. sometimes 16bit quantities, and sometimes built
 260:optiboot_flash.c ****  * up from 8bit input characters.  avr-gcc is not great at optimizing the
 261:optiboot_flash.c ****  * assembly of larger words from bytes, but we can use the usual union to
 262:optiboot_flash.c ****  * do this manually.  Expanding it a little, we can also get rid of casts.
 263:optiboot_flash.c ****  */
 264:optiboot_flash.c ****  typedef union 
 265:optiboot_flash.c ****  {
 266:optiboot_flash.c ****   uint8_t  *bptr;
 267:optiboot_flash.c ****   uint16_t *wptr;
 268:optiboot_flash.c ****   uint16_t word;
 269:optiboot_flash.c ****   uint8_t bytes[2];
 270:optiboot_flash.c ****  } addr16_t;
 271:optiboot_flash.c **** 
 272:optiboot_flash.c **** #ifndef LED_START_FLASHES
 273:optiboot_flash.c **** #define LED_START_FLASHES 0
 274:optiboot_flash.c **** #endif
 275:optiboot_flash.c **** 
 276:optiboot_flash.c **** /* set the UART baud rate defaults */
 277:optiboot_flash.c **** #ifndef BAUD_RATE
 278:optiboot_flash.c **** #if F_CPU >= 8000000L
 279:optiboot_flash.c **** #define BAUD_RATE   115200L // Highest rate Avrdude win32 will support
 280:optiboot_flash.c **** #elif F_CPU >= 1000000L
 281:optiboot_flash.c **** #define BAUD_RATE   9600L   // 19200 also supported, but with significant error
 282:optiboot_flash.c **** #elif F_CPU >= 128000L
 283:optiboot_flash.c **** #define BAUD_RATE   4800L   // Good for 128kHz internal RC
 284:optiboot_flash.c **** #else
 285:optiboot_flash.c **** #define BAUD_RATE 1200L     // Good even at 32768Hz
 286:optiboot_flash.c **** #endif
 287:optiboot_flash.c **** #endif
 288:optiboot_flash.c **** 
 289:optiboot_flash.c **** #ifndef UART
 290:optiboot_flash.c **** #define UART 0
 291:optiboot_flash.c **** #endif
 292:optiboot_flash.c **** 
 293:optiboot_flash.c **** #ifdef SINGLESPEED // U2X = 0
 294:optiboot_flash.c **** /* Single speed option */
 295:optiboot_flash.c **** #define BAUD_SETTING (( (F_CPU + BAUD_RATE * 8L) / ((BAUD_RATE * 16L))) - 1 )
 296:optiboot_flash.c **** #define BAUD_ACTUAL (F_CPU/(16 * ((BAUD_SETTING)+1)))
 297:optiboot_flash.c **** #else
 298:optiboot_flash.c ****  /* Normal U2X usage */
 299:optiboot_flash.c **** #define BAUD_SETTING (( (F_CPU + BAUD_RATE * 4L) / ((BAUD_RATE * 8L))) - 1 )
 300:optiboot_flash.c **** #define BAUD_ACTUAL (F_CPU/(8 * ((BAUD_SETTING)+1)))
 301:optiboot_flash.c **** #endif
 302:optiboot_flash.c **** #if BAUD_ACTUAL <= BAUD_RATE
 303:optiboot_flash.c **** #define BAUD_ERROR (( 100*(BAUD_RATE - BAUD_ACTUAL) ) / BAUD_RATE)
 304:optiboot_flash.c **** #if BAUD_ERROR >= 5
 305:optiboot_flash.c **** #error BAUD_RATE error greater than -5%
 306:optiboot_flash.c **** #elif BAUD_ERROR >= 2
 307:optiboot_flash.c **** #warning BAUD_RATE error greater than -2%
 308:optiboot_flash.c **** #endif
 309:optiboot_flash.c **** #else
 310:optiboot_flash.c **** #define BAUD_ERROR (( 100*(BAUD_ACTUAL - BAUD_RATE) ) / BAUD_RATE)
 311:optiboot_flash.c **** #if BAUD_ERROR >= 5
 312:optiboot_flash.c **** #error BAUD_RATE error greater than 5%
 313:optiboot_flash.c **** #elif BAUD_ERROR >= 2
 314:optiboot_flash.c **** #warning BAUD_RATE error greater than 2%
 315:optiboot_flash.c **** #endif
 316:optiboot_flash.c **** #endif
 317:optiboot_flash.c **** 
 318:optiboot_flash.c **** #if BAUD_SETTING > 250
 319:optiboot_flash.c **** #error Unachievable baud rate (too slow) BAUD_RATE 
 320:optiboot_flash.c **** #endif // baud rate slow check
 321:optiboot_flash.c **** #if (BAUD_SETTING - 1) < 3
 322:optiboot_flash.c **** #if BAUD_ERROR != 0 // permit high bitrates (ie 1Mbps@16MHz) if error is zero
 323:optiboot_flash.c **** #error Unachievable baud rate (too fast) BAUD_RATE 
 324:optiboot_flash.c **** #endif
 325:optiboot_flash.c **** #endif // baud rate fast check
 326:optiboot_flash.c **** 
 327:optiboot_flash.c **** /* Watchdog settings */
 328:optiboot_flash.c **** #define WATCHDOG_OFF    (0)
 329:optiboot_flash.c **** #define WATCHDOG_16MS   (_BV(WDE))
 330:optiboot_flash.c **** #define WATCHDOG_32MS   (_BV(WDP0) | _BV(WDE))
 331:optiboot_flash.c **** #define WATCHDOG_64MS   (_BV(WDP1) | _BV(WDE))
 332:optiboot_flash.c **** #define WATCHDOG_125MS  (_BV(WDP1) | _BV(WDP0) | _BV(WDE))
 333:optiboot_flash.c **** #define WATCHDOG_250MS  (_BV(WDP2) | _BV(WDE))
 334:optiboot_flash.c **** #define WATCHDOG_500MS  (_BV(WDP2) | _BV(WDP0) | _BV(WDE))
 335:optiboot_flash.c **** #define WATCHDOG_1S     (_BV(WDP2) | _BV(WDP1) | _BV(WDE))
 336:optiboot_flash.c **** #define WATCHDOG_2S     (_BV(WDP2) | _BV(WDP1) | _BV(WDP0) | _BV(WDE))
 337:optiboot_flash.c **** #ifndef __AVR_ATmega8__
 338:optiboot_flash.c **** #define WATCHDOG_4S     (_BV(WDP3) | _BV(WDE))
 339:optiboot_flash.c **** #define WATCHDOG_8S     (_BV(WDP3) | _BV(WDP0) | _BV(WDE))
 340:optiboot_flash.c **** #endif
 341:optiboot_flash.c **** 
 342:optiboot_flash.c **** 
 343:optiboot_flash.c **** /*
 344:optiboot_flash.c ****  * We can never load flash with more than 1 page at a time, so we can save
 345:optiboot_flash.c ****  * some code space on parts with smaller pagesize by using a smaller int.
 346:optiboot_flash.c ****  */
 347:optiboot_flash.c **** #if SPM_PAGESIZE > 255
 348:optiboot_flash.c **** typedef uint16_t pagelen_t ;
 349:optiboot_flash.c **** #define GETLENGTH(len) len = getch()<<8; len |= getch()
 350:optiboot_flash.c **** #else
 351:optiboot_flash.c **** typedef uint8_t pagelen_t;
 352:optiboot_flash.c **** #define GETLENGTH(len) (void) getch() /* skip high byte */; len = getch()
 353:optiboot_flash.c **** #endif
 354:optiboot_flash.c **** 
 355:optiboot_flash.c **** 
 356:optiboot_flash.c **** /* Function Prototypes
 357:optiboot_flash.c ****  * The main() function is in init9, which removes the interrupt vector table
 358:optiboot_flash.c ****  * we don't need. It is also 'OS_main', which means the compiler does not
 359:optiboot_flash.c ****  * generate any entry or exit code itself (but unlike 'naked', it doesn't
 360:optiboot_flash.c ****  * supress some compile-time options we want.)
 361:optiboot_flash.c ****  */
 362:optiboot_flash.c **** 
 363:optiboot_flash.c **** void pre_main(void) __attribute__ ((naked)) __attribute__ ((section (".init8")));
 364:optiboot_flash.c **** int main(void) __attribute__ ((OS_main)) __attribute__ ((section (".init9")));
 365:optiboot_flash.c **** 
 366:optiboot_flash.c **** void __attribute__((noinline)) putch(char);
 367:optiboot_flash.c **** uint8_t __attribute__((noinline)) getch(void);
 368:optiboot_flash.c **** void __attribute__((noinline)) verifySpace();
 369:optiboot_flash.c **** void __attribute__((noinline)) watchdogConfig(uint8_t x);
 370:optiboot_flash.c **** 
 371:optiboot_flash.c **** static void getNch(uint8_t);
 372:optiboot_flash.c **** #if LED_START_FLASHES > 0
 373:optiboot_flash.c **** static inline void flash_led(uint8_t);
 374:optiboot_flash.c **** #endif
 375:optiboot_flash.c **** static inline void watchdogReset();
 376:optiboot_flash.c **** static inline void writebuffer(int8_t memtype, addr16_t mybuff,
 377:optiboot_flash.c ****              addr16_t address, pagelen_t len);
 378:optiboot_flash.c **** static inline void read_mem(uint8_t memtype,
 379:optiboot_flash.c ****           addr16_t, pagelen_t len);
 380:optiboot_flash.c **** static void __attribute__((noinline)) do_spm(uint16_t address, uint8_t command, uint16_t data);
 381:optiboot_flash.c **** 
 382:optiboot_flash.c **** #ifdef SOFT_UART
 383:optiboot_flash.c **** void uartDelay() __attribute__ ((naked));
 384:optiboot_flash.c **** #endif
 385:optiboot_flash.c **** //void appStart(uint8_t rstFlags) __attribute__ ((naked));
 386:optiboot_flash.c **** 
 387:optiboot_flash.c **** /*
 388:optiboot_flash.c ****  * RAMSTART should be self-explanatory.  It's bigger on parts with a
 389:optiboot_flash.c ****  * lot of peripheral registers.  Let 0x100 be the default
 390:optiboot_flash.c ****  * Note that RAMSTART (for optiboot) need not be exactly at the start of RAM.
 391:optiboot_flash.c ****  */
 392:optiboot_flash.c **** #if !defined(RAMSTART)  // newer versions of gcc avr-libc define RAMSTART
 393:optiboot_flash.c **** #define RAMSTART 0x100
 394:optiboot_flash.c **** #if defined (__AVR_ATmega644P__)
 395:optiboot_flash.c **** // correct for a bug in avr-libc
 396:optiboot_flash.c **** #undef SIGNATURE_2
 397:optiboot_flash.c **** #define SIGNATURE_2 0x0A
 398:optiboot_flash.c **** #elif defined(__AVR_ATmega1280__) || defined(__AVR_ATmega1281__) || defined(__AVR_ATmega2560__) || 
 399:optiboot_flash.c **** #undef RAMSTART
 400:optiboot_flash.c **** #define RAMSTART (0x200)
 401:optiboot_flash.c **** #endif
 402:optiboot_flash.c **** #endif
 403:optiboot_flash.c **** 
 404:optiboot_flash.c **** /* C zero initialises all global variables. However, that requires */
 405:optiboot_flash.c **** /* These definitions are NOT zero initialised, but that doesn't matter */
 406:optiboot_flash.c **** /* This allows us to drop the zero init code, saving us memory */
 407:optiboot_flash.c **** static addr16_t buff = {(uint8_t *)(RAMSTART)};
 408:optiboot_flash.c **** 
 409:optiboot_flash.c **** /* Virtual boot partition support */
 410:optiboot_flash.c **** #ifdef VIRTUAL_BOOT_PARTITION
 411:optiboot_flash.c **** #define rstVect0_sav (*(uint8_t*)(RAMSTART+SPM_PAGESIZE*2+4))
 412:optiboot_flash.c **** #define rstVect1_sav (*(uint8_t*)(RAMSTART+SPM_PAGESIZE*2+5))
 413:optiboot_flash.c **** #define saveVect0_sav (*(uint8_t*)(RAMSTART+SPM_PAGESIZE*2+6))
 414:optiboot_flash.c **** #define saveVect1_sav (*(uint8_t*)(RAMSTART+SPM_PAGESIZE*2+7))
 415:optiboot_flash.c **** // Vector to save original reset jump:
 416:optiboot_flash.c **** //   SPM Ready is least probably used, so it's default
 417:optiboot_flash.c **** //   if not, use old way WDT_vect_num,
 418:optiboot_flash.c **** //   or simply set custom save_vect_num in Makefile using vector name
 419:optiboot_flash.c **** //   or even raw number.
 420:optiboot_flash.c **** #if !defined (save_vect_num)
 421:optiboot_flash.c **** #if defined (SPM_RDY_vect_num)
 422:optiboot_flash.c **** #define save_vect_num (SPM_RDY_vect_num)
 423:optiboot_flash.c **** #elif defined (SPM_READY_vect_num)
 424:optiboot_flash.c **** #define save_vect_num (SPM_READY_vect_num)
 425:optiboot_flash.c **** #elif defined (WDT_vect_num)
 426:optiboot_flash.c **** #define save_vect_num (WDT_vect_num)
 427:optiboot_flash.c **** #else
 428:optiboot_flash.c **** #error Cant find SPM or WDT interrupt vector for this CPU
 429:optiboot_flash.c **** #endif
 430:optiboot_flash.c **** #endif //save_vect_num
 431:optiboot_flash.c **** // check if it's on the same page (code assumes that)
 432:optiboot_flash.c **** #if (SPM_PAGESIZE <= save_vect_num)
 433:optiboot_flash.c **** #error Save vector not in the same page as reset!
 434:optiboot_flash.c **** #endif
 435:optiboot_flash.c **** #if FLASHEND > 8192
 436:optiboot_flash.c **** // AVRs with more than 8k of flash have 4-byte vectors, and use jmp.
 437:optiboot_flash.c **** //  We save only 16 bits of address, so devices with more than 128KB
 438:optiboot_flash.c **** //  may behave wrong for upper part of address space.
 439:optiboot_flash.c **** #define rstVect0 2
 440:optiboot_flash.c **** #define rstVect1 3
 441:optiboot_flash.c **** #define saveVect0 (save_vect_num*4+2)
 442:optiboot_flash.c **** #define saveVect1 (save_vect_num*4+3)
 443:optiboot_flash.c **** #define appstart_vec (save_vect_num*2)
 444:optiboot_flash.c **** #else
 445:optiboot_flash.c **** // AVRs with up to 8k of flash have 2-byte vectors, and use rjmp.
 446:optiboot_flash.c **** #define rstVect0 0
 447:optiboot_flash.c **** #define rstVect1 1
 448:optiboot_flash.c **** #define saveVect0 (save_vect_num*2)
 449:optiboot_flash.c **** #define saveVect1 (save_vect_num*2+1)
 450:optiboot_flash.c **** #define appstart_vec (save_vect_num)
 451:optiboot_flash.c **** #endif
 452:optiboot_flash.c **** #else
 453:optiboot_flash.c **** #define appstart_vec (0)
 454:optiboot_flash.c **** #endif // VIRTUAL_BOOT_PARTITION
 455:optiboot_flash.c **** 
 456:optiboot_flash.c **** /* everything that needs to run VERY early */
 457:optiboot_flash.c **** void pre_main(void) {
 129               	.LM0:
 130               	.LFBB1:
 131               	/* prologue: naked */
 132               	/* frame size = 0 */
 133               	/* stack size = 0 */
 134               	.L__stack_usage = 0
 458:optiboot_flash.c ****   // Allow convenient way of calling do_spm function - jump table,
 459:optiboot_flash.c ****   //   so entry to this function will always be here, indepedent of compilation,
 460:optiboot_flash.c ****   //   features etc
 461:optiboot_flash.c ****   asm volatile (
 136               	.LM1:
 137               	/* #APP */
 138               	 ;  461 "optiboot_flash.c" 1
 139 0000 00C0      		 rjmp 1f
 140 0002 00C0      	 rjmp do_spm
 141               	1:
 142               	
 143               	 ;  0 "" 2
 462:optiboot_flash.c ****     " rjmp 1f\n"
 463:optiboot_flash.c ****     " rjmp do_spm\n"
 464:optiboot_flash.c **** #ifdef COPY_FLASH_PAGES
 465:optiboot_flash.c ****     " rjmp copy_flash_pages\n"
 466:optiboot_flash.c **** #endif
 467:optiboot_flash.c ****     "1:\n"
 468:optiboot_flash.c ****   );
 469:optiboot_flash.c **** }
 145               	.LM2:
 146               	/* #NOAPP */
 147 0004 0000      		nop
 148               	/* epilogue start */
 150               	.Lscope1:
 152               		.stabd	78,0,0
 153               		.section	.init9,"ax",@progbits
 155               	.global	main
 157               	main:
 158               		.stabd	46,0,0
 470:optiboot_flash.c **** 
 471:optiboot_flash.c **** 
 472:optiboot_flash.c **** /* main program starts here */
 473:optiboot_flash.c **** int main(void) {
 160               	.LM3:
 161               	.LFBB2:
 162 0000 CDB7      		in r28,__SP_L__
 163 0002 DEB7      		in r29,__SP_H__
 164 0004 2797      		sbiw r28,7
 165 0006 DEBF      		out __SP_H__,r29
 166 0008 CDBF      		out __SP_L__,r28
 167               	/* prologue: function */
 168               	/* frame size = 7 */
 169               	/* stack size = 7 */
 170               	.L__stack_usage = 7
 474:optiboot_flash.c ****   uint8_t ch;
 475:optiboot_flash.c **** 
 476:optiboot_flash.c ****   /*
 477:optiboot_flash.c ****    * Making these local and in registers prevents the need for initializing
 478:optiboot_flash.c ****    * them, and also saves space because code no longer stores to memory.
 479:optiboot_flash.c ****    * (initializing address keeps the compiler happy, but isn't really
 480:optiboot_flash.c ****    *  necessary, and uses 4 bytes of flash.)
 481:optiboot_flash.c ****    */
 482:optiboot_flash.c ****   register addr16_t address;
 483:optiboot_flash.c ****   register pagelen_t  length;
 484:optiboot_flash.c **** 
 485:optiboot_flash.c ****   // After the zero init loop, this is the first code to run.
 486:optiboot_flash.c ****   //
 487:optiboot_flash.c ****   // This code makes the following assumptions:
 488:optiboot_flash.c ****   //  No interrupts will execute
 489:optiboot_flash.c ****   //  SP points to RAMEND
 490:optiboot_flash.c ****   //  r1 contains zero
 491:optiboot_flash.c ****   //
 492:optiboot_flash.c ****   // If not, uncomment the following instructions:
 493:optiboot_flash.c ****   // cli();
 494:optiboot_flash.c ****   asm volatile ("clr __zero_reg__");
 172               	.LM4:
 173               	/* #APP */
 174               	 ;  494 "optiboot_flash.c" 1
 175 000a 1124      		clr __zero_reg__
 176               	 ;  0 "" 2
 495:optiboot_flash.c **** #if defined(__AVR_ATmega8__) || defined(__AVR_ATmega8515__) || defined(__AVR_ATmega8535__)   \
 496:optiboot_flash.c **** || defined (__AVR_ATmega16__) || defined (__AVR_ATmega32__) || defined (__AVR_ATmega64__)    \
 497:optiboot_flash.c **** || defined (__AVR_ATmega128__) || defined (__AVR_ATmega162__) || defined (__AVR_AT90CAN32__) \
 498:optiboot_flash.c **** || defined (__AVR_AT90CAN64__) || defined (__AVR_AT90CAN128__)
 499:optiboot_flash.c ****   SP=RAMEND;  // This is done by hardware reset
 500:optiboot_flash.c **** #endif
 501:optiboot_flash.c **** 
 502:optiboot_flash.c ****   /*
 503:optiboot_flash.c ****    * Protect as much from MCUSR as possible for application
 504:optiboot_flash.c ****    * and still skip bootloader if not necessary
 505:optiboot_flash.c ****    * 
 506:optiboot_flash.c ****    * Code by MarkG55
 507:optiboot_flash.c ****    * see discusion in https://github.com/Optiboot/optiboot/issues/97
 508:optiboot_flash.c ****    */
 509:optiboot_flash.c ****    
 510:optiboot_flash.c **** // Fix ATmega128 avr-libc bug
 511:optiboot_flash.c **** #if defined(__AVR_ATmega128__)
 512:optiboot_flash.c **** 	ch = MCUCSR;
 513:optiboot_flash.c **** #else
 514:optiboot_flash.c **** 	ch = MCUSR;
 178               	.LM5:
 179               	/* #NOAPP */
 180 000c 84E5      		ldi r24,lo8(84)
 181 000e 90E0      		ldi r25,0
 182 0010 FC01      		movw r30,r24
 183 0012 8081      		ld r24,Z
 184 0014 8B83      		std Y+3,r24
 515:optiboot_flash.c **** #endif
 516:optiboot_flash.c **** 
 517:optiboot_flash.c **** // This is necessary on targets that where the CLKPR has been set in user application
 518:optiboot_flash.c **** #if defined(CLKPR) && F_CPU != 1000000L
 519:optiboot_flash.c ****   CLKPR = 0x80; // Enable the clock prescaler
 186               	.LM6:
 187 0016 81E6      		ldi r24,lo8(97)
 188 0018 90E0      		ldi r25,0
 189 001a 20E8      		ldi r18,lo8(-128)
 190 001c FC01      		movw r30,r24
 191 001e 2083      		st Z,r18
 520:optiboot_flash.c ****   CLKPR = 0x00; // Set prescaler to 1
 193               	.LM7:
 194 0020 81E6      		ldi r24,lo8(97)
 195 0022 90E0      		ldi r25,0
 196 0024 FC01      		movw r30,r24
 197 0026 1082      		st Z,__zero_reg__
 521:optiboot_flash.c **** #endif
 522:optiboot_flash.c **** 
 523:optiboot_flash.c ****   // Skip all logic and run bootloader if MCUSR is cleared (application request)
 524:optiboot_flash.c ****   if (ch != 0) {
 199               	.LM8:
 200 0028 8B81      		ldd r24,Y+3
 201 002a 8823      		tst r24
 202 002c 01F0      		breq .L3
 525:optiboot_flash.c ****     /*
 526:optiboot_flash.c ****      * To run the boot loader, External Reset Flag must be set.
 527:optiboot_flash.c ****      * If not, we could make shortcut and jump directly to application code.
 528:optiboot_flash.c ****      * Also WDRF set with EXTRF is a result of Optiboot timeout, so we
 529:optiboot_flash.c ****      * shouldn't run bootloader in loop :-) That's why:
 530:optiboot_flash.c ****      *  1. application is running if WDRF is cleared
 531:optiboot_flash.c ****      *  2. we clear WDRF if it's set with EXTRF to avoid loops
 532:optiboot_flash.c ****      * One problematic scenario: broken application code sets watchdog timer 
 533:optiboot_flash.c ****      * without clearing MCUSR before and triggers it quickly. But it's
 534:optiboot_flash.c ****      * recoverable by power-on with pushed reset button.
 535:optiboot_flash.c ****      */
 536:optiboot_flash.c ****     if ((ch & (_BV(WDRF) | _BV(EXTRF))) != _BV(EXTRF)) { 
 204               	.LM9:
 205 002e 8B81      		ldd r24,Y+3
 206 0030 882F      		mov r24,r24
 207 0032 90E0      		ldi r25,0
 208 0034 8A70      		andi r24,10
 209 0036 9927      		clr r25
 210 0038 0297      		sbiw r24,2
 211 003a 01F0      		breq .L3
 537:optiboot_flash.c ****       if (ch & _BV(EXTRF)) {
 213               	.LM10:
 214 003c 8B81      		ldd r24,Y+3
 215 003e 882F      		mov r24,r24
 216 0040 90E0      		ldi r25,0
 217 0042 8270      		andi r24,2
 218 0044 9927      		clr r25
 219 0046 892B      		or r24,r25
 220 0048 01F0      		breq .L4
 538:optiboot_flash.c ****         /*
 539:optiboot_flash.c ****          * Clear WDRF because it was most probably set by wdr in bootloader.
 540:optiboot_flash.c ****          * It's also needed to avoid loop by broken application which could
 541:optiboot_flash.c ****          * prevent entering bootloader.
 542:optiboot_flash.c ****          * '&' operation is skipped to spare few bytes as bits in MCUSR
 543:optiboot_flash.c ****          * can only be cleared.
 544:optiboot_flash.c ****          */
 545:optiboot_flash.c **** 
 546:optiboot_flash.c **** // Fix ATmega128 avr-libc bug
 547:optiboot_flash.c **** #if defined(__AVR_ATmega128__)
 548:optiboot_flash.c **** 	      MCUCSR = ~(_BV(WDRF));  
 549:optiboot_flash.c **** #else
 550:optiboot_flash.c **** 	      MCUSR = ~(_BV(WDRF));  
 222               	.LM11:
 223 004a 84E5      		ldi r24,lo8(84)
 224 004c 90E0      		ldi r25,0
 225 004e 27EF      		ldi r18,lo8(-9)
 226 0050 FC01      		movw r30,r24
 227 0052 2083      		st Z,r18
 228               	.L4:
 551:optiboot_flash.c **** #endif 
 552:optiboot_flash.c ****       }
 553:optiboot_flash.c ****       /* 
 554:optiboot_flash.c ****        * save the reset flags in the designated register
 555:optiboot_flash.c ****        * This can be saved in a main program by putting code in .init0 (which
 556:optiboot_flash.c ****        * executes before normal c init code) to save R2 to a global variable.
 557:optiboot_flash.c ****        */
 558:optiboot_flash.c ****       __asm__ __volatile__ ("mov r2, %0\n" :: "r" (ch));
 230               	.LM12:
 231 0054 8B81      		ldd r24,Y+3
 232               	/* #APP */
 233               	 ;  558 "optiboot_flash.c" 1
 234 0056 282E      		mov r2, r24
 235               	
 236               	 ;  0 "" 2
 559:optiboot_flash.c **** 
 560:optiboot_flash.c ****       // Turn off watchdog
 561:optiboot_flash.c ****       watchdogConfig(WATCHDOG_OFF);
 238               	.LM13:
 239               	/* #NOAPP */
 240 0058 80E0      		ldi r24,0
 241 005a 0E94 0000 		call watchdogConfig
 562:optiboot_flash.c ****       // Note that appstart_vec is defined so that this works with either
 563:optiboot_flash.c ****       // real or virtual boot partitions.
 564:optiboot_flash.c ****        __asm__ __volatile__ (
 243               	.LM14:
 244               	/* #APP */
 245               	 ;  564 "optiboot_flash.c" 1
 246 005e 00C0      		rjmp optiboot_version+2
 247               	
 248               	 ;  0 "" 2
 249               	/* #NOAPP */
 250               	.L3:
 565:optiboot_flash.c ****       // Jump to 'save' or RST vector
 566:optiboot_flash.c ****  #ifdef VIRTUAL_BOOT_PARTITION
 567:optiboot_flash.c ****       // full code version for virtual boot partition
 568:optiboot_flash.c ****       "ldi r30,%[rstvec]\n"
 569:optiboot_flash.c ****       "clr r31\n"
 570:optiboot_flash.c ****       "ijmp\n"::[rstvec] "M"(appstart_vec)
 571:optiboot_flash.c ****  #else
 572:optiboot_flash.c ****  #ifdef RAMPZ
 573:optiboot_flash.c ****       // use absolute jump for devices with lot of flash
 574:optiboot_flash.c ****       "jmp 0\n"::
 575:optiboot_flash.c ****  #else
 576:optiboot_flash.c ****       // use rjmp to go around end of flash to address 0
 577:optiboot_flash.c ****       // it uses fact that optiboot_version constant is 2 bytes before end of flash
 578:optiboot_flash.c ****       "rjmp optiboot_version+2\n"
 579:optiboot_flash.c ****  #endif //RAMPZ
 580:optiboot_flash.c ****  #endif //VIRTUAL_BOOT_PARTITION
 581:optiboot_flash.c ****     );
 582:optiboot_flash.c ****     }
 583:optiboot_flash.c ****   }
 584:optiboot_flash.c ****   
 585:optiboot_flash.c **** #if LED_START_FLASHES > 0
 586:optiboot_flash.c ****   // Set up Timer 1 for timeout counter
 587:optiboot_flash.c ****   TCCR1B = _BV(CS12) | _BV(CS10); // div 1024
 252               	.LM15:
 253 0060 81E8      		ldi r24,lo8(-127)
 254 0062 90E0      		ldi r25,0
 255 0064 25E0      		ldi r18,lo8(5)
 256 0066 FC01      		movw r30,r24
 257 0068 2083      		st Z,r18
 588:optiboot_flash.c **** #endif
 589:optiboot_flash.c **** 
 590:optiboot_flash.c **** #ifndef SOFT_UART
 591:optiboot_flash.c **** // ATmega8/8515/8535/16/32 only has one UART port
 592:optiboot_flash.c **** #if defined(__AVR_ATmega8__) || defined (__AVR_ATmega8515__) || defined (__AVR_ATmega8535__) \
 593:optiboot_flash.c **** || defined (__AVR_ATmega16__) || defined (__AVR_ATmega32__)
 594:optiboot_flash.c **** #ifndef SINGLESPEED
 595:optiboot_flash.c ****    UCSRA = _BV(U2X); // Double speed mode USART
 596:optiboot_flash.c **** #endif
 597:optiboot_flash.c ****   UCSRB = _BV(RXEN) | _BV(TXEN);  // enable Rx & Tx
 598:optiboot_flash.c ****   UCSRC = _BV(URSEL) | _BV(UCSZ1) | _BV(UCSZ0);  // config USART; 8N1
 599:optiboot_flash.c ****   UBRRL = (uint8_t)BAUD_SETTING;
 600:optiboot_flash.c **** #else
 601:optiboot_flash.c **** #ifndef SINGLESPEED
 602:optiboot_flash.c ****    UART_SRA = _BV(U2X0); // Double speed mode USART0
 259               	.LM16:
 260 006a 80EC      		ldi r24,lo8(-64)
 261 006c 90E0      		ldi r25,0
 262 006e 22E0      		ldi r18,lo8(2)
 263 0070 FC01      		movw r30,r24
 264 0072 2083      		st Z,r18
 603:optiboot_flash.c ****  #endif  
 604:optiboot_flash.c ****   UART_SRB = _BV(RXEN0) | _BV(TXEN0);
 266               	.LM17:
 267 0074 81EC      		ldi r24,lo8(-63)
 268 0076 90E0      		ldi r25,0
 269 0078 28E1      		ldi r18,lo8(24)
 270 007a FC01      		movw r30,r24
 271 007c 2083      		st Z,r18
 605:optiboot_flash.c ****   UART_SRL = (uint8_t)BAUD_SETTING;
 273               	.LM18:
 274 007e 84EC      		ldi r24,lo8(-60)
 275 0080 90E0      		ldi r25,0
 276 0082 20E1      		ldi r18,lo8(16)
 277 0084 FC01      		movw r30,r24
 278 0086 2083      		st Z,r18
 606:optiboot_flash.c **** #if defined(__AVR_ATmega162__) 
 607:optiboot_flash.c ****     UART_SRC = _BV(URSEL0) | _BV(UCSZ00) | _BV(UCSZ01);
 608:optiboot_flash.c **** #else
 609:optiboot_flash.c ****     UART_SRC = _BV(UCSZ00) | _BV(UCSZ01);
 280               	.LM19:
 281 0088 82EC      		ldi r24,lo8(-62)
 282 008a 90E0      		ldi r25,0
 283 008c 26E0      		ldi r18,lo8(6)
 284 008e FC01      		movw r30,r24
 285 0090 2083      		st Z,r18
 610:optiboot_flash.c **** #endif
 611:optiboot_flash.c **** #endif
 612:optiboot_flash.c **** #endif
 613:optiboot_flash.c **** 
 614:optiboot_flash.c ****   // Set up watchdog to trigger after 1s
 615:optiboot_flash.c ****   watchdogConfig(WATCHDOG_1S);
 287               	.LM20:
 288 0092 8EE0      		ldi r24,lo8(14)
 289 0094 0E94 0000 		call watchdogConfig
 616:optiboot_flash.c **** 
 617:optiboot_flash.c **** #if (LED_START_FLASHES > 0) || defined(LED_DATA_FLASH) || defined(LED_START_ON)
 618:optiboot_flash.c ****   /* Set LED pin as output */
 619:optiboot_flash.c ****   LED_DDR |= _BV(LED);
 291               	.LM21:
 292 0098 84E2      		ldi r24,lo8(36)
 293 009a 90E0      		ldi r25,0
 294 009c 24E2      		ldi r18,lo8(36)
 295 009e 30E0      		ldi r19,0
 296 00a0 F901      		movw r30,r18
 297 00a2 2081      		ld r18,Z
 298 00a4 2062      		ori r18,lo8(32)
 299 00a6 FC01      		movw r30,r24
 300 00a8 2083      		st Z,r18
 620:optiboot_flash.c **** #endif
 621:optiboot_flash.c **** 
 622:optiboot_flash.c **** #ifdef SOFT_UART
 623:optiboot_flash.c ****   /* Set TX pin as output */
 624:optiboot_flash.c ****   UART_DDR |= _BV(UART_TX_BIT);
 625:optiboot_flash.c **** #endif
 626:optiboot_flash.c **** 
 627:optiboot_flash.c **** #if LED_START_FLASHES > 0
 628:optiboot_flash.c ****   /* Flash onboard LED to signal entering of bootloader */
 629:optiboot_flash.c ****   flash_led(LED_START_FLASHES * 2);
 302               	.LM22:
 303 00aa 84E0      		ldi r24,lo8(4)
 304 00ac 0E94 0000 		call flash_led
 305               	.L19:
 630:optiboot_flash.c **** #elif defined(LED_START_ON)
 631:optiboot_flash.c ****   /* Turn on LED to indicate starting bootloader (less code!) */
 632:optiboot_flash.c ****   LED_PORT |= _BV(LED);
 633:optiboot_flash.c **** #endif
 634:optiboot_flash.c **** 
 635:optiboot_flash.c ****   /* Forever loop: exits by causing WDT reset */
 636:optiboot_flash.c ****   for (;;) {
 637:optiboot_flash.c ****     /* get character from UART */
 638:optiboot_flash.c ****     ch = getch();
 307               	.LM23:
 308 00b0 0E94 0000 		call getch
 309 00b4 8B83      		std Y+3,r24
 639:optiboot_flash.c **** 
 640:optiboot_flash.c ****     if(ch == STK_GET_PARAMETER) {
 311               	.LM24:
 312 00b6 8B81      		ldd r24,Y+3
 313 00b8 8134      		cpi r24,lo8(65)
 314 00ba 01F4      		brne .L5
 315               	.LBB2:
 641:optiboot_flash.c ****       unsigned char which = getch();
 317               	.LM25:
 318 00bc 0E94 0000 		call getch
 319 00c0 8C83      		std Y+4,r24
 642:optiboot_flash.c ****       verifySpace();
 321               	.LM26:
 322 00c2 0E94 0000 		call verifySpace
 643:optiboot_flash.c ****       /*
 644:optiboot_flash.c ****        * Send optiboot version as "SW version"
 645:optiboot_flash.c ****        * Note that the references to memory are optimized away.
 646:optiboot_flash.c ****        */
 647:optiboot_flash.c ****       if (which == STK_SW_MINOR) {
 324               	.LM27:
 325 00c6 8C81      		ldd r24,Y+4
 326 00c8 8238      		cpi r24,lo8(-126)
 327 00ca 01F4      		brne .L6
 648:optiboot_flash.c ****     putch(optiboot_version & 0xFF);
 329               	.LM28:
 330 00cc 80E0      		ldi r24,0
 331 00ce 97E0      		ldi r25,lo8(7)
 332 00d0 0E94 0000 		call putch
 333 00d4 00C0      		rjmp .L9
 334               	.L6:
 649:optiboot_flash.c ****       } else if (which == STK_SW_MAJOR) {
 336               	.LM29:
 337 00d6 8C81      		ldd r24,Y+4
 338 00d8 8138      		cpi r24,lo8(-127)
 339 00da 01F4      		brne .L8
 650:optiboot_flash.c ****     putch(optiboot_version >> 8);
 341               	.LM30:
 342 00dc 80E0      		ldi r24,0
 343 00de 97E0      		ldi r25,lo8(7)
 344 00e0 892F      		mov r24,r25
 345 00e2 9927      		clr r25
 346 00e4 0E94 0000 		call putch
 347 00e8 00C0      		rjmp .L9
 348               	.L8:
 651:optiboot_flash.c ****       } else {
 652:optiboot_flash.c ****   /*
 653:optiboot_flash.c ****    * GET PARAMETER returns a generic 0x03 reply for
 654:optiboot_flash.c ****          * other parameters - enough to keep Avrdude happy
 655:optiboot_flash.c ****    */
 656:optiboot_flash.c ****   putch(0x03);
 350               	.LM31:
 351 00ea 83E0      		ldi r24,lo8(3)
 352 00ec 0E94 0000 		call putch
 353 00f0 00C0      		rjmp .L9
 354               	.L5:
 355               	.LBE2:
 657:optiboot_flash.c ****       }
 658:optiboot_flash.c ****     }
 659:optiboot_flash.c ****     else if(ch == STK_SET_DEVICE) {
 357               	.LM32:
 358 00f2 8B81      		ldd r24,Y+3
 359 00f4 8234      		cpi r24,lo8(66)
 360 00f6 01F4      		brne .L10
 660:optiboot_flash.c ****       // SET DEVICE is ignored
 661:optiboot_flash.c ****       getNch(20);
 362               	.LM33:
 363 00f8 84E1      		ldi r24,lo8(20)
 364 00fa 0E94 0000 		call getNch
 365 00fe 00C0      		rjmp .L9
 366               	.L10:
 662:optiboot_flash.c ****     }
 663:optiboot_flash.c ****     else if(ch == STK_SET_DEVICE_EXT) {
 368               	.LM34:
 369 0100 8B81      		ldd r24,Y+3
 370 0102 8534      		cpi r24,lo8(69)
 371 0104 01F4      		brne .L11
 664:optiboot_flash.c ****       // SET DEVICE EXT is ignored
 665:optiboot_flash.c ****       getNch(5);
 373               	.LM35:
 374 0106 85E0      		ldi r24,lo8(5)
 375 0108 0E94 0000 		call getNch
 376 010c 00C0      		rjmp .L9
 377               	.L11:
 666:optiboot_flash.c ****     }
 667:optiboot_flash.c ****     else if(ch == STK_LOAD_ADDRESS) {
 379               	.LM36:
 380 010e 8B81      		ldd r24,Y+3
 381 0110 8535      		cpi r24,lo8(85)
 382 0112 01F4      		brne .L12
 668:optiboot_flash.c ****       // LOAD ADDRESS
 669:optiboot_flash.c ****       address.bytes[0] = getch();
 384               	.LM37:
 385 0114 0E94 0000 		call getch
 386 0118 E82E      		mov r14,r24
 670:optiboot_flash.c ****       address.bytes[1] = getch();
 388               	.LM38:
 389 011a 0E94 0000 		call getch
 390 011e F82E      		mov r15,r24
 671:optiboot_flash.c **** #ifdef RAMPZ
 672:optiboot_flash.c ****       // Transfer top bit to LSB in RAMPZ
 673:optiboot_flash.c ****       if (address.bytes[1] & 0x80) {
 674:optiboot_flash.c ****         RAMPZ |= 0x01;
 675:optiboot_flash.c ****       }
 676:optiboot_flash.c ****       else {
 677:optiboot_flash.c ****         RAMPZ &= 0xFE;
 678:optiboot_flash.c ****       }
 679:optiboot_flash.c **** #endif
 680:optiboot_flash.c ****       address.word *= 2; // Convert from word address to byte address
 392               	.LM39:
 393 0120 C701      		movw r24,r14
 394 0122 880F      		lsl r24
 395 0124 991F      		rol r25
 396 0126 7C01      		movw r14,r24
 681:optiboot_flash.c ****       verifySpace();
 398               	.LM40:
 399 0128 0E94 0000 		call verifySpace
 400 012c 00C0      		rjmp .L9
 401               	.L12:
 682:optiboot_flash.c ****     }
 683:optiboot_flash.c ****     else if(ch == STK_UNIVERSAL) {
 403               	.LM41:
 404 012e 8B81      		ldd r24,Y+3
 405 0130 8635      		cpi r24,lo8(86)
 406 0132 01F4      		brne .L13
 684:optiboot_flash.c **** #ifdef RAMPZ
 685:optiboot_flash.c ****       // LOAD_EXTENDED_ADDRESS is needed in STK_UNIVERSAL for addressing more than 128kB
 686:optiboot_flash.c ****       if ( AVR_OP_LOAD_EXT_ADDR == getch() ) {
 687:optiboot_flash.c ****         // get address
 688:optiboot_flash.c ****         getch();  // get '0'
 689:optiboot_flash.c ****         RAMPZ = (RAMPZ & 0x01) | ((getch() << 1) & 0xff);  // get address and put it in RAMPZ
 690:optiboot_flash.c ****         getNch(1); // get last '0'
 691:optiboot_flash.c ****         // response
 692:optiboot_flash.c ****         putch(0x00);
 693:optiboot_flash.c ****       }
 694:optiboot_flash.c ****       else {
 695:optiboot_flash.c ****         // everything else is ignored
 696:optiboot_flash.c ****         getNch(3);
 697:optiboot_flash.c ****         putch(0x00);
 698:optiboot_flash.c ****       }
 699:optiboot_flash.c **** #else
 700:optiboot_flash.c ****       // UNIVERSAL command is ignored
 701:optiboot_flash.c ****       getNch(4);
 408               	.LM42:
 409 0134 84E0      		ldi r24,lo8(4)
 410 0136 0E94 0000 		call getNch
 702:optiboot_flash.c ****       putch(0x00);
 412               	.LM43:
 413 013a 80E0      		ldi r24,0
 414 013c 0E94 0000 		call putch
 415 0140 00C0      		rjmp .L9
 416               	.L13:
 703:optiboot_flash.c **** #endif
 704:optiboot_flash.c ****     }
 705:optiboot_flash.c ****     /* Write memory, length is big endian and is in bytes */
 706:optiboot_flash.c ****     else if(ch == STK_PROG_PAGE) {
 418               	.LM44:
 419 0142 8B81      		ldd r24,Y+3
 420 0144 8436      		cpi r24,lo8(100)
 421 0146 01F4      		brne .L14
 422               	.LBB3:
 707:optiboot_flash.c ****       // PROGRAM PAGE - we support flash programming only, not EEPROM
 708:optiboot_flash.c ****       uint8_t desttype;
 709:optiboot_flash.c ****       uint8_t *bufPtr;
 710:optiboot_flash.c ****       pagelen_t savelength;
 711:optiboot_flash.c **** 
 712:optiboot_flash.c ****       GETLENGTH(length);
 424               	.LM45:
 425 0148 0E94 0000 		call getch
 426 014c 0E94 0000 		call getch
 427 0150 D82E      		mov r13,r24
 713:optiboot_flash.c ****       savelength = length;
 429               	.LM46:
 430 0152 DD82      		std Y+5,r13
 714:optiboot_flash.c ****       desttype = getch();
 432               	.LM47:
 433 0154 0E94 0000 		call getch
 434 0158 8E83      		std Y+6,r24
 715:optiboot_flash.c **** 
 716:optiboot_flash.c ****       // read a page worth of contents
 717:optiboot_flash.c ****       bufPtr = buff.bptr;
 436               	.LM48:
 437 015a 8091 0000 		lds r24,buff
 438 015e 9091 0000 		lds r25,buff+1
 439 0162 9A83      		std Y+2,r25
 440 0164 8983      		std Y+1,r24
 441               	.L15:
 718:optiboot_flash.c ****       do *bufPtr++ = getch();
 443               	.LM49:
 444 0166 0981      		ldd r16,Y+1
 445 0168 1A81      		ldd r17,Y+2
 446 016a C801      		movw r24,r16
 447 016c 0196      		adiw r24,1
 448 016e 9A83      		std Y+2,r25
 449 0170 8983      		std Y+1,r24
 450 0172 0E94 0000 		call getch
 451 0176 F801      		movw r30,r16
 452 0178 8083      		st Z,r24
 719:optiboot_flash.c ****       while (--length);
 454               	.LM50:
 455 017a DA94      		dec r13
 456 017c DD20      		tst r13
 457 017e 01F4      		brne .L15
 720:optiboot_flash.c **** 
 721:optiboot_flash.c ****       // Read command terminator, start reply
 722:optiboot_flash.c ****       verifySpace();
 459               	.LM51:
 460 0180 0E94 0000 		call verifySpace
 723:optiboot_flash.c **** 
 724:optiboot_flash.c **** #ifdef VIRTUAL_BOOT_PARTITION
 725:optiboot_flash.c **** #if FLASHEND > 8192
 726:optiboot_flash.c **** /*
 727:optiboot_flash.c ****  * AVR with 4-byte ISR Vectors and "jmp"
 728:optiboot_flash.c ****  * WARNING: this works only up to 128KB flash!
 729:optiboot_flash.c ****  */
 730:optiboot_flash.c ****       if (address.word == 0) {
 731:optiboot_flash.c ****   // This is the reset vector page. We need to live-patch the
 732:optiboot_flash.c ****   // code so the bootloader runs first.
 733:optiboot_flash.c ****   //
 734:optiboot_flash.c ****   // Save jmp targets (for "Verify")
 735:optiboot_flash.c ****   rstVect0_sav = buff.bptr[rstVect0];
 736:optiboot_flash.c ****   rstVect1_sav = buff.bptr[rstVect1];
 737:optiboot_flash.c ****   saveVect0_sav = buff.bptr[saveVect0];
 738:optiboot_flash.c ****   saveVect1_sav = buff.bptr[saveVect1];
 739:optiboot_flash.c **** 
 740:optiboot_flash.c ****         // Move RESET jmp target to 'save' vector
 741:optiboot_flash.c ****         buff.bptr[saveVect0] = rstVect0_sav;
 742:optiboot_flash.c ****         buff.bptr[saveVect1] = rstVect1_sav;
 743:optiboot_flash.c **** 
 744:optiboot_flash.c ****         // Add jump to bootloader at RESET vector
 745:optiboot_flash.c ****         // WARNING: this works as long as 'main' is in first section
 746:optiboot_flash.c ****         buff.bptr[rstVect0] = ((uint16_t)main) & 0xFF;
 747:optiboot_flash.c ****         buff.bptr[rstVect1] = ((uint16_t)main) >> 8;
 748:optiboot_flash.c ****       }
 749:optiboot_flash.c **** 
 750:optiboot_flash.c **** #else
 751:optiboot_flash.c **** /*
 752:optiboot_flash.c ****  * AVR with 2-byte ISR Vectors and rjmp
 753:optiboot_flash.c ****  */
 754:optiboot_flash.c ****       if (address.word == rstVect0) {
 755:optiboot_flash.c ****         // This is the reset vector page. We need to live-patch
 756:optiboot_flash.c ****         // the code so the bootloader runs first.
 757:optiboot_flash.c ****         //
 758:optiboot_flash.c ****         // Move RESET vector to 'save' vector
 759:optiboot_flash.c ****   // Save jmp targets (for "Verify")
 760:optiboot_flash.c ****   rstVect0_sav = buff.bptr[rstVect0];
 761:optiboot_flash.c ****   rstVect1_sav = buff.bptr[rstVect1];
 762:optiboot_flash.c ****   saveVect0_sav = buff.bptr[saveVect0];
 763:optiboot_flash.c ****   saveVect1_sav = buff.bptr[saveVect1];
 764:optiboot_flash.c **** 
 765:optiboot_flash.c ****   // Instruction is a relative jump (rjmp), so recalculate.
 766:optiboot_flash.c ****   // an RJMP instruction is 0b1100xxxx xxxxxxxx, so we should be able to
 767:optiboot_flash.c ****   // do math on the offsets without masking it off first.
 768:optiboot_flash.c ****   addr16_t vect;
 769:optiboot_flash.c ****   vect.bytes[0] = rstVect0_sav;
 770:optiboot_flash.c ****   vect.bytes[1] = rstVect1_sav;
 771:optiboot_flash.c ****   vect.word = (vect.word-save_vect_num); //substract 'save' interrupt position
 772:optiboot_flash.c ****         // Move RESET jmp target to 'save' vector
 773:optiboot_flash.c ****         buff[saveVect0] = vect & 0xff;
 774:optiboot_flash.c ****         buff[saveVect1] = (vect >> 8) | 0xc0; //
 775:optiboot_flash.c ****         // Add rjump to bootloader at RESET vector
 776:optiboot_flash.c ****         vect.word = ((uint16_t)main); // (main) is always <= 0x0FFF; no masking needed.
 777:optiboot_flash.c ****         buff.bptr[0] = vect.bytes[0]; // rjmp 0x1c00 instruction
 778:optiboot_flash.c ****   buff.bptr[1] = vect.bytes[1] | 0xC0;  // make an "rjmp"
 779:optiboot_flash.c ****       }
 780:optiboot_flash.c **** #endif // FLASHEND
 781:optiboot_flash.c **** #endif // VBP
 782:optiboot_flash.c **** 
 783:optiboot_flash.c ****       writebuffer(desttype, buff, address, savelength);
 462               	.LM52:
 463 0184 3E81      		ldd r19,Y+6
 464 0186 8091 0000 		lds r24,buff
 465 018a 9091 0000 		lds r25,buff+1
 466 018e 2D81      		ldd r18,Y+5
 467 0190 A701      		movw r20,r14
 468 0192 BC01      		movw r22,r24
 469 0194 832F      		mov r24,r19
 470 0196 0E94 0000 		call writebuffer
 471               	.LBE3:
 472 019a 00C0      		rjmp .L9
 473               	.L14:
 784:optiboot_flash.c **** 
 785:optiboot_flash.c **** 
 786:optiboot_flash.c ****     }
 787:optiboot_flash.c ****     /* Read memory block mode, length is big endian.  */
 788:optiboot_flash.c ****     else if(ch == STK_READ_PAGE) {
 475               	.LM53:
 476 019c 8B81      		ldd r24,Y+3
 477 019e 8437      		cpi r24,lo8(116)
 478 01a0 01F4      		brne .L16
 479               	.LBB4:
 789:optiboot_flash.c ****       uint8_t desttype;
 790:optiboot_flash.c ****       GETLENGTH(length);
 481               	.LM54:
 482 01a2 0E94 0000 		call getch
 483 01a6 0E94 0000 		call getch
 484 01aa D82E      		mov r13,r24
 791:optiboot_flash.c **** 
 792:optiboot_flash.c ****       desttype = getch();
 486               	.LM55:
 487 01ac 0E94 0000 		call getch
 488 01b0 8F83      		std Y+7,r24
 793:optiboot_flash.c **** 
 794:optiboot_flash.c ****       verifySpace();
 490               	.LM56:
 491 01b2 0E94 0000 		call verifySpace
 795:optiboot_flash.c **** 
 796:optiboot_flash.c ****       read_mem(desttype, address, length);
 493               	.LM57:
 494 01b6 4D2D      		mov r20,r13
 495 01b8 B701      		movw r22,r14
 496 01ba 8F81      		ldd r24,Y+7
 497 01bc 0E94 0000 		call read_mem
 498               	.LBE4:
 499 01c0 00C0      		rjmp .L9
 500               	.L16:
 797:optiboot_flash.c ****     }
 798:optiboot_flash.c **** 
 799:optiboot_flash.c ****     /* Get device signature bytes  */
 800:optiboot_flash.c ****     else if(ch == STK_READ_SIGN) {
 502               	.LM58:
 503 01c2 8B81      		ldd r24,Y+3
 504 01c4 8537      		cpi r24,lo8(117)
 505 01c6 01F4      		brne .L17
 801:optiboot_flash.c ****       // READ SIGN - return what Avrdude wants to hear
 802:optiboot_flash.c ****       verifySpace();
 507               	.LM59:
 508 01c8 0E94 0000 		call verifySpace
 803:optiboot_flash.c ****       putch(SIGNATURE_0);
 510               	.LM60:
 511 01cc 8EE1      		ldi r24,lo8(30)
 512 01ce 0E94 0000 		call putch
 804:optiboot_flash.c ****       putch(SIGNATURE_1);
 514               	.LM61:
 515 01d2 85E9      		ldi r24,lo8(-107)
 516 01d4 0E94 0000 		call putch
 805:optiboot_flash.c ****       putch(SIGNATURE_2);
 518               	.LM62:
 519 01d8 84E1      		ldi r24,lo8(20)
 520 01da 0E94 0000 		call putch
 521 01de 00C0      		rjmp .L9
 522               	.L17:
 806:optiboot_flash.c ****     }
 807:optiboot_flash.c ****     else if (ch == STK_LEAVE_PROGMODE) { /* 'Q' */
 524               	.LM63:
 525 01e0 8B81      		ldd r24,Y+3
 526 01e2 8135      		cpi r24,lo8(81)
 527 01e4 01F4      		brne .L18
 808:optiboot_flash.c ****       // Adaboot no-wait mod
 809:optiboot_flash.c ****       watchdogConfig(WATCHDOG_16MS);
 529               	.LM64:
 530 01e6 88E0      		ldi r24,lo8(8)
 531 01e8 0E94 0000 		call watchdogConfig
 810:optiboot_flash.c ****       verifySpace();
 533               	.LM65:
 534 01ec 0E94 0000 		call verifySpace
 535 01f0 00C0      		rjmp .L9
 536               	.L18:
 811:optiboot_flash.c ****     }
 812:optiboot_flash.c ****     else {
 813:optiboot_flash.c ****       // This covers the response to commands like STK_ENTER_PROGMODE
 814:optiboot_flash.c ****       verifySpace();
 538               	.LM66:
 539 01f2 0E94 0000 		call verifySpace
 540               	.L9:
 815:optiboot_flash.c ****     }
 816:optiboot_flash.c ****     putch(STK_OK);
 542               	.LM67:
 543 01f6 80E1      		ldi r24,lo8(16)
 544 01f8 0E94 0000 		call putch
 817:optiboot_flash.c ****   }
 546               	.LM68:
 547 01fc 00C0      		rjmp .L19
 565               	.Lscope2:
 567               		.stabd	78,0,0
 568               		.data
 571               	buff:
 572 0000 0001      		.word	256
 573               		.text
 576               	.global	putch
 578               	putch:
 579               		.stabd	46,0,0
 818:optiboot_flash.c **** }
 819:optiboot_flash.c **** 
 820:optiboot_flash.c **** void putch(char ch) {
 581               	.LM69:
 582               	.LFBB3:
 583 0000 CF93      		push r28
 584 0002 DF93      		push r29
 585 0004 1F92      		push __zero_reg__
 586 0006 CDB7      		in r28,__SP_L__
 587 0008 DEB7      		in r29,__SP_H__
 588               	/* prologue: function */
 589               	/* frame size = 1 */
 590               	/* stack size = 3 */
 591               	.L__stack_usage = 3
 592 000a 8983      		std Y+1,r24
 821:optiboot_flash.c **** #ifndef SOFT_UART
 822:optiboot_flash.c ****   while (!(UART_SRA & _BV(UDRE0)));
 594               	.LM70:
 595 000c 0000      		nop
 596               	.L21:
 598               	.LM71:
 599 000e 80EC      		ldi r24,lo8(-64)
 600 0010 90E0      		ldi r25,0
 601 0012 FC01      		movw r30,r24
 602 0014 8081      		ld r24,Z
 603 0016 882F      		mov r24,r24
 604 0018 90E0      		ldi r25,0
 605 001a 8072      		andi r24,32
 606 001c 9927      		clr r25
 607 001e 892B      		or r24,r25
 608 0020 01F0      		breq .L21
 823:optiboot_flash.c ****   UART_UDR = ch;
 610               	.LM72:
 611 0022 86EC      		ldi r24,lo8(-58)
 612 0024 90E0      		ldi r25,0
 613 0026 2981      		ldd r18,Y+1
 614 0028 FC01      		movw r30,r24
 615 002a 2083      		st Z,r18
 824:optiboot_flash.c **** #else
 825:optiboot_flash.c ****   __asm__ __volatile__ (
 826:optiboot_flash.c ****     "   com %[ch]\n" // ones complement, carry set
 827:optiboot_flash.c ****     "   sec\n"
 828:optiboot_flash.c ****     "1: brcc 2f\n"
 829:optiboot_flash.c ****     "   cbi %[uartPort],%[uartBit]\n"
 830:optiboot_flash.c ****     "   rjmp 3f\n"
 831:optiboot_flash.c ****     "2: sbi %[uartPort],%[uartBit]\n"
 832:optiboot_flash.c ****     "   nop\n"
 833:optiboot_flash.c ****     "3: rcall uartDelay\n"
 834:optiboot_flash.c ****     "   rcall uartDelay\n"
 835:optiboot_flash.c ****     "   lsr %[ch]\n"
 836:optiboot_flash.c ****     "   dec %[bitcnt]\n"
 837:optiboot_flash.c ****     "   brne 1b\n"
 838:optiboot_flash.c ****     :
 839:optiboot_flash.c ****     :
 840:optiboot_flash.c ****       [bitcnt] "d" (10),
 841:optiboot_flash.c ****       [ch] "r" (ch),
 842:optiboot_flash.c ****       [uartPort] "I" (_SFR_IO_ADDR(UART_PORT)),
 843:optiboot_flash.c ****       [uartBit] "I" (UART_TX_BIT)
 844:optiboot_flash.c ****     :
 845:optiboot_flash.c ****       "r25"
 846:optiboot_flash.c ****   );
 847:optiboot_flash.c **** #endif
 848:optiboot_flash.c **** }
 617               	.LM73:
 618 002c 0000      		nop
 619               	/* epilogue start */
 620 002e 0F90      		pop __tmp_reg__
 621 0030 DF91      		pop r29
 622 0032 CF91      		pop r28
 623 0034 0895      		ret
 625               	.Lscope3:
 627               		.stabd	78,0,0
 629               	.global	getch
 631               	getch:
 632               		.stabd	46,0,0
 849:optiboot_flash.c **** 
 850:optiboot_flash.c **** uint8_t getch(void) {
 634               	.LM74:
 635               	.LFBB4:
 636 0036 CF93      		push r28
 637 0038 DF93      		push r29
 638 003a 1F92      		push __zero_reg__
 639 003c CDB7      		in r28,__SP_L__
 640 003e DEB7      		in r29,__SP_H__
 641               	/* prologue: function */
 642               	/* frame size = 1 */
 643               	/* stack size = 3 */
 644               	.L__stack_usage = 3
 851:optiboot_flash.c ****   uint8_t ch;
 852:optiboot_flash.c **** 
 853:optiboot_flash.c **** #ifdef LED_DATA_FLASH
 854:optiboot_flash.c **** #if defined(__AVR_ATmega8__) || defined(__AVR_ATmega8515__) || defined(__AVR_ATmega8535__) \
 855:optiboot_flash.c **** || defined(__AVR_ATmega16__) || defined(__AVR_ATmega162__) || defined(__AVR_ATmega32__)    \
 856:optiboot_flash.c **** || defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)
 857:optiboot_flash.c ****   LED_PORT ^= _BV(LED);
 858:optiboot_flash.c **** #else
 859:optiboot_flash.c ****   LED_PIN |= _BV(LED);
 860:optiboot_flash.c **** #endif
 861:optiboot_flash.c **** #endif
 862:optiboot_flash.c **** 
 863:optiboot_flash.c **** #ifdef SOFT_UART
 864:optiboot_flash.c ****     watchdogReset();
 865:optiboot_flash.c ****   __asm__ __volatile__ (
 866:optiboot_flash.c ****     "1: sbic  %[uartPin],%[uartBit]\n"  // Wait for start edge
 867:optiboot_flash.c ****     "   rjmp  1b\n"
 868:optiboot_flash.c ****     "   rcall uartDelay\n"          // Get to middle of start bit
 869:optiboot_flash.c ****     "2: rcall uartDelay\n"              // Wait 1 bit period
 870:optiboot_flash.c ****     "   rcall uartDelay\n"              // Wait 1 bit period
 871:optiboot_flash.c ****     "   clc\n"
 872:optiboot_flash.c ****     "   sbic  %[uartPin],%[uartBit]\n"
 873:optiboot_flash.c ****     "   sec\n"
 874:optiboot_flash.c ****     "   dec   %[bitCnt]\n"
 875:optiboot_flash.c ****     "   breq  3f\n"
 876:optiboot_flash.c ****     "   ror   %[ch]\n"
 877:optiboot_flash.c ****     "   rjmp  2b\n"
 878:optiboot_flash.c ****     "3:\n"
 879:optiboot_flash.c ****     :
 880:optiboot_flash.c ****       [ch] "=r" (ch)
 881:optiboot_flash.c ****     :
 882:optiboot_flash.c ****       [bitCnt] "d" (9),
 883:optiboot_flash.c ****       [uartPin] "I" (_SFR_IO_ADDR(UART_PIN)),
 884:optiboot_flash.c ****       [uartBit] "I" (UART_RX_BIT)
 885:optiboot_flash.c ****     :
 886:optiboot_flash.c ****       "r25"
 887:optiboot_flash.c **** );
 888:optiboot_flash.c **** #else
 889:optiboot_flash.c ****   while(!(UART_SRA & _BV(RXC0)))
 646               	.LM75:
 647 0040 0000      		nop
 648               	.L23:
 650               	.LM76:
 651 0042 80EC      		ldi r24,lo8(-64)
 652 0044 90E0      		ldi r25,0
 653 0046 FC01      		movw r30,r24
 654 0048 8081      		ld r24,Z
 655 004a 8823      		tst r24
 656 004c 04F4      		brge .L23
 890:optiboot_flash.c ****     ;
 891:optiboot_flash.c ****   if (!(UART_SRA & _BV(FE0))) {
 658               	.LM77:
 659 004e 80EC      		ldi r24,lo8(-64)
 660 0050 90E0      		ldi r25,0
 661 0052 FC01      		movw r30,r24
 662 0054 8081      		ld r24,Z
 663 0056 882F      		mov r24,r24
 664 0058 90E0      		ldi r25,0
 665 005a 8071      		andi r24,16
 666 005c 9927      		clr r25
 667 005e 892B      		or r24,r25
 668 0060 01F4      		brne .L24
 892:optiboot_flash.c ****       /*
 893:optiboot_flash.c ****        * A Framing Error indicates (probably) that something is talking
 894:optiboot_flash.c ****        * to us at the wrong bit rate.  Assume that this is because it
 895:optiboot_flash.c ****        * expects to be talking to the application, and DON'T reset the
 896:optiboot_flash.c ****        * watchdog.  This should cause the bootloader to abort and run
 897:optiboot_flash.c ****        * the application "soon", if it keeps happening.  (Note that we
 898:optiboot_flash.c ****        * don't care that an invalid char is returned...)
 899:optiboot_flash.c ****        */
 900:optiboot_flash.c ****     watchdogReset();
 670               	.LM78:
 671 0062 0E94 0000 		call watchdogReset
 672               	.L24:
 901:optiboot_flash.c ****   }
 902:optiboot_flash.c **** 
 903:optiboot_flash.c ****   ch = UART_UDR;
 674               	.LM79:
 675 0066 86EC      		ldi r24,lo8(-58)
 676 0068 90E0      		ldi r25,0
 677 006a FC01      		movw r30,r24
 678 006c 8081      		ld r24,Z
 679 006e 8983      		std Y+1,r24
 904:optiboot_flash.c **** #endif
 905:optiboot_flash.c **** 
 906:optiboot_flash.c **** #ifdef LED_DATA_FLASH
 907:optiboot_flash.c **** #if defined(__AVR_ATmega8__) || defined(__AVR_ATmega8515__) || defined(__AVR_ATmega8535__) \
 908:optiboot_flash.c **** || defined(__AVR_ATmega16__) || defined(__AVR_ATmega162__) ||defined(__AVR_ATmega32__)     \
 909:optiboot_flash.c **** || defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)
 910:optiboot_flash.c ****   LED_PORT ^= _BV(LED);
 911:optiboot_flash.c **** #else
 912:optiboot_flash.c ****   LED_PIN |= _BV(LED);
 913:optiboot_flash.c **** #endif
 914:optiboot_flash.c **** #endif
 915:optiboot_flash.c **** 
 916:optiboot_flash.c ****   return ch;
 681               	.LM80:
 682 0070 8981      		ldd r24,Y+1
 683               	/* epilogue start */
 917:optiboot_flash.c **** }
 685               	.LM81:
 686 0072 0F90      		pop __tmp_reg__
 687 0074 DF91      		pop r29
 688 0076 CF91      		pop r28
 689 0078 0895      		ret
 694               	.Lscope4:
 696               		.stabd	78,0,0
 700               	getNch:
 701               		.stabd	46,0,0
 918:optiboot_flash.c **** 
 919:optiboot_flash.c **** #ifdef SOFT_UART
 920:optiboot_flash.c **** // AVR305 equation: #define UART_B_VALUE (((F_CPU/BAUD_RATE)-23)/6)
 921:optiboot_flash.c **** // Adding 3 to numerator simulates nearest rounding for more accurate baud rates
 922:optiboot_flash.c **** #define UART_B_VALUE (((F_CPU/BAUD_RATE)-20)/6)
 923:optiboot_flash.c **** #if UART_B_VALUE > 255
 924:optiboot_flash.c **** #error Baud rate too slow for soft UART
 925:optiboot_flash.c **** #endif
 926:optiboot_flash.c **** 
 927:optiboot_flash.c **** void uartDelay() {
 928:optiboot_flash.c ****   __asm__ __volatile__ (
 929:optiboot_flash.c ****     "ldi r25,%[count]\n"
 930:optiboot_flash.c ****     "1:dec r25\n"
 931:optiboot_flash.c ****     "brne 1b\n"
 932:optiboot_flash.c ****     "ret\n"
 933:optiboot_flash.c ****     ::[count] "M" (UART_B_VALUE)
 934:optiboot_flash.c ****   );
 935:optiboot_flash.c **** }
 936:optiboot_flash.c **** #endif
 937:optiboot_flash.c **** 
 938:optiboot_flash.c **** void getNch(uint8_t count) {
 703               	.LM82:
 704               	.LFBB5:
 705 007a CF93      		push r28
 706 007c DF93      		push r29
 707 007e 1F92      		push __zero_reg__
 708 0080 CDB7      		in r28,__SP_L__
 709 0082 DEB7      		in r29,__SP_H__
 710               	/* prologue: function */
 711               	/* frame size = 1 */
 712               	/* stack size = 3 */
 713               	.L__stack_usage = 3
 714 0084 8983      		std Y+1,r24
 715               	.L27:
 939:optiboot_flash.c ****   do getch(); while (--count);
 717               	.LM83:
 718 0086 0E94 0000 		call getch
 719 008a 8981      		ldd r24,Y+1
 720 008c 8150      		subi r24,lo8(-(-1))
 721 008e 8983      		std Y+1,r24
 722 0090 8981      		ldd r24,Y+1
 723 0092 8823      		tst r24
 724 0094 01F4      		brne .L27
 940:optiboot_flash.c ****   verifySpace();
 726               	.LM84:
 727 0096 0E94 0000 		call verifySpace
 941:optiboot_flash.c **** }
 729               	.LM85:
 730 009a 0000      		nop
 731               	/* epilogue start */
 732 009c 0F90      		pop __tmp_reg__
 733 009e DF91      		pop r29
 734 00a0 CF91      		pop r28
 735 00a2 0895      		ret
 737               	.Lscope5:
 739               		.stabd	78,0,0
 741               	.global	verifySpace
 743               	verifySpace:
 744               		.stabd	46,0,0
 942:optiboot_flash.c **** 
 943:optiboot_flash.c **** void verifySpace() {
 746               	.LM86:
 747               	.LFBB6:
 748 00a4 CF93      		push r28
 749 00a6 DF93      		push r29
 750 00a8 CDB7      		in r28,__SP_L__
 751 00aa DEB7      		in r29,__SP_H__
 752               	/* prologue: function */
 753               	/* frame size = 0 */
 754               	/* stack size = 2 */
 755               	.L__stack_usage = 2
 944:optiboot_flash.c ****   if (getch() != CRC_EOP) {
 757               	.LM87:
 758 00ac 0E94 0000 		call getch
 759 00b0 8032      		cpi r24,lo8(32)
 760 00b2 01F0      		breq .L29
 945:optiboot_flash.c ****     watchdogConfig(WATCHDOG_16MS);    // shorten WD timeout
 762               	.LM88:
 763 00b4 88E0      		ldi r24,lo8(8)
 764 00b6 0E94 0000 		call watchdogConfig
 765               	.L30:
 946:optiboot_flash.c ****     while (1)            // and busy-loop so that WD causes
 947:optiboot_flash.c ****       ;              //  a reset and app start.
 767               	.LM89:
 768 00ba 00C0      		rjmp .L30
 769               	.L29:
 948:optiboot_flash.c ****   }
 949:optiboot_flash.c ****   putch(STK_INSYNC);
 771               	.LM90:
 772 00bc 84E1      		ldi r24,lo8(20)
 773 00be 0E94 0000 		call putch
 950:optiboot_flash.c **** }
 775               	.LM91:
 776 00c2 0000      		nop
 777               	/* epilogue start */
 778 00c4 DF91      		pop r29
 779 00c6 CF91      		pop r28
 780 00c8 0895      		ret
 782               	.Lscope6:
 784               		.stabd	78,0,0
 788               	flash_led:
 789               		.stabd	46,0,0
 951:optiboot_flash.c **** 
 952:optiboot_flash.c **** #if LED_START_FLASHES > 0
 953:optiboot_flash.c **** void flash_led(uint8_t count) {
 791               	.LM92:
 792               	.LFBB7:
 793 00ca CF93      		push r28
 794 00cc DF93      		push r29
 795 00ce 1F92      		push __zero_reg__
 796 00d0 CDB7      		in r28,__SP_L__
 797 00d2 DEB7      		in r29,__SP_H__
 798               	/* prologue: function */
 799               	/* frame size = 1 */
 800               	/* stack size = 3 */
 801               	.L__stack_usage = 3
 802 00d4 8983      		std Y+1,r24
 803               	.L35:
 954:optiboot_flash.c ****   do {
 955:optiboot_flash.c ****     TCNT1 = -(F_CPU/(1024*16));
 805               	.LM93:
 806 00d6 84E8      		ldi r24,lo8(-124)
 807 00d8 90E0      		ldi r25,0
 808 00da 20E3      		ldi r18,lo8(48)
 809 00dc 3CEF      		ldi r19,lo8(-4)
 810 00de FC01      		movw r30,r24
 811 00e0 3183      		std Z+1,r19
 812 00e2 2083      		st Z,r18
 956:optiboot_flash.c ****     TIFR1 = _BV(TOV1);
 814               	.LM94:
 815 00e4 86E3      		ldi r24,lo8(54)
 816 00e6 90E0      		ldi r25,0
 817 00e8 21E0      		ldi r18,lo8(1)
 818 00ea FC01      		movw r30,r24
 819 00ec 2083      		st Z,r18
 957:optiboot_flash.c ****     while(!(TIFR1 & _BV(TOV1)));
 821               	.LM95:
 822 00ee 0000      		nop
 823               	.L32:
 825               	.LM96:
 826 00f0 86E3      		ldi r24,lo8(54)
 827 00f2 90E0      		ldi r25,0
 828 00f4 FC01      		movw r30,r24
 829 00f6 8081      		ld r24,Z
 830 00f8 882F      		mov r24,r24
 831 00fa 90E0      		ldi r25,0
 832 00fc 8170      		andi r24,1
 833 00fe 9927      		clr r25
 834 0100 892B      		or r24,r25
 835 0102 01F0      		breq .L32
 958:optiboot_flash.c **** #if defined(__AVR_ATmega8__) || defined(__AVR_ATmega8515__) || defined(__AVR_ATmega8535__) \
 959:optiboot_flash.c **** || defined(__AVR_ATmega16__) || defined(__AVR_ATmega162__) || defined(__AVR_ATmega32__)    \
 960:optiboot_flash.c **** || defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)
 961:optiboot_flash.c ****     LED_PORT ^= _BV(LED);
 962:optiboot_flash.c **** #else
 963:optiboot_flash.c ****     LED_PIN |= _BV(LED);
 837               	.LM97:
 838 0104 83E2      		ldi r24,lo8(35)
 839 0106 90E0      		ldi r25,0
 840 0108 23E2      		ldi r18,lo8(35)
 841 010a 30E0      		ldi r19,0
 842 010c F901      		movw r30,r18
 843 010e 2081      		ld r18,Z
 844 0110 2062      		ori r18,lo8(32)
 845 0112 FC01      		movw r30,r24
 846 0114 2083      		st Z,r18
 964:optiboot_flash.c **** #endif
 965:optiboot_flash.c ****     watchdogReset();
 848               	.LM98:
 849 0116 0E94 0000 		call watchdogReset
 966:optiboot_flash.c **** #ifndef SOFT_UART
 967:optiboot_flash.c ****      /*
 968:optiboot_flash.c ****       * While in theory, the STK500 initial commands would be buffered
 969:optiboot_flash.c ****       *  by the UART hardware, avrdude sends several attempts in rather
 970:optiboot_flash.c ****       *  quick succession, some of which will be lost and cause us to
 971:optiboot_flash.c ****       *  get out of sync.  So if we see any data; stop blinking.
 972:optiboot_flash.c ****       */
 973:optiboot_flash.c ****      if (UART_SRA & _BV(RXC0))
 851               	.LM99:
 852 011a 80EC      		ldi r24,lo8(-64)
 853 011c 90E0      		ldi r25,0
 854 011e FC01      		movw r30,r24
 855 0120 8081      		ld r24,Z
 856 0122 8823      		tst r24
 857 0124 04F0      		brlt .L36
 974:optiboot_flash.c ****        break;
 975:optiboot_flash.c **** #else
 976:optiboot_flash.c **** // This doesn't seem to work?
 977:optiboot_flash.c **** //    if ((UART_PIN & (1<<UART_RX_BIT)) == 0)
 978:optiboot_flash.c **** //      break;  // detect start bit on soft uart too.
 979:optiboot_flash.c **** #endif    
 980:optiboot_flash.c ****   } while (--count);
 859               	.LM100:
 860 0126 8981      		ldd r24,Y+1
 861 0128 8150      		subi r24,lo8(-(-1))
 862 012a 8983      		std Y+1,r24
 863 012c 8981      		ldd r24,Y+1
 864 012e 8823      		tst r24
 865 0130 01F4      		brne .L35
 981:optiboot_flash.c **** }
 867               	.LM101:
 868 0132 00C0      		rjmp .L34
 869               	.L36:
 974:optiboot_flash.c ****        break;
 871               	.LM102:
 872 0134 0000      		nop
 873               	.L34:
 875               	.LM103:
 876 0136 0000      		nop
 877               	/* epilogue start */
 878 0138 0F90      		pop __tmp_reg__
 879 013a DF91      		pop r29
 880 013c CF91      		pop r28
 881 013e 0895      		ret
 883               	.Lscope7:
 885               		.stabd	78,0,0
 888               	watchdogReset:
 889               		.stabd	46,0,0
 982:optiboot_flash.c **** #endif
 983:optiboot_flash.c **** 
 984:optiboot_flash.c **** // Watchdog functions. These are only safe with interrupts turned off.
 985:optiboot_flash.c **** void watchdogReset() {
 891               	.LM104:
 892               	.LFBB8:
 893 0140 CF93      		push r28
 894 0142 DF93      		push r29
 895 0144 CDB7      		in r28,__SP_L__
 896 0146 DEB7      		in r29,__SP_H__
 897               	/* prologue: function */
 898               	/* frame size = 0 */
 899               	/* stack size = 2 */
 900               	.L__stack_usage = 2
 986:optiboot_flash.c ****   __asm__ __volatile__ (
 902               	.LM105:
 903               	/* #APP */
 904               	 ;  986 "optiboot_flash.c" 1
 905 0148 A895      		wdr
 906               	
 907               	 ;  0 "" 2
 987:optiboot_flash.c ****     "wdr\n"
 988:optiboot_flash.c ****   );
 989:optiboot_flash.c **** }
 909               	.LM106:
 910               	/* #NOAPP */
 911 014a 0000      		nop
 912               	/* epilogue start */
 913 014c DF91      		pop r29
 914 014e CF91      		pop r28
 915 0150 0895      		ret
 917               	.Lscope8:
 919               		.stabd	78,0,0
 922               	.global	watchdogConfig
 924               	watchdogConfig:
 925               		.stabd	46,0,0
 990:optiboot_flash.c **** 
 991:optiboot_flash.c **** void watchdogConfig(uint8_t x) {
 927               	.LM107:
 928               	.LFBB9:
 929 0152 CF93      		push r28
 930 0154 DF93      		push r29
 931 0156 1F92      		push __zero_reg__
 932 0158 CDB7      		in r28,__SP_L__
 933 015a DEB7      		in r29,__SP_H__
 934               	/* prologue: function */
 935               	/* frame size = 1 */
 936               	/* stack size = 3 */
 937               	.L__stack_usage = 3
 938 015c 8983      		std Y+1,r24
 992:optiboot_flash.c ****   WDTCSR = _BV(WDCE) | _BV(WDE);
 940               	.LM108:
 941 015e 80E6      		ldi r24,lo8(96)
 942 0160 90E0      		ldi r25,0
 943 0162 28E1      		ldi r18,lo8(24)
 944 0164 FC01      		movw r30,r24
 945 0166 2083      		st Z,r18
 993:optiboot_flash.c ****   WDTCSR = x;
 947               	.LM109:
 948 0168 80E6      		ldi r24,lo8(96)
 949 016a 90E0      		ldi r25,0
 950 016c 2981      		ldd r18,Y+1
 951 016e FC01      		movw r30,r24
 952 0170 2083      		st Z,r18
 994:optiboot_flash.c **** }
 954               	.LM110:
 955 0172 0000      		nop
 956               	/* epilogue start */
 957 0174 0F90      		pop __tmp_reg__
 958 0176 DF91      		pop r29
 959 0178 CF91      		pop r28
 960 017a 0895      		ret
 962               	.Lscope9:
 964               		.stabd	78,0,0
 971               	writebuffer:
 972               		.stabd	46,0,0
 995:optiboot_flash.c **** 
 996:optiboot_flash.c **** 
 997:optiboot_flash.c **** /*
 998:optiboot_flash.c ****  * void writebuffer(memtype, buffer, address, length)
 999:optiboot_flash.c ****  */
1000:optiboot_flash.c **** static inline void writebuffer(int8_t memtype, addr16_t mybuff,
1001:optiboot_flash.c ****              addr16_t address, pagelen_t len)
1002:optiboot_flash.c **** {
 974               	.LM111:
 975               	.LFBB10:
 976 017c CF93      		push r28
 977 017e DF93      		push r29
 978 0180 CDB7      		in r28,__SP_L__
 979 0182 DEB7      		in r29,__SP_H__
 980 0184 2897      		sbiw r28,8
 981 0186 0FB6      		in __tmp_reg__,__SREG__
 982 0188 F894      		cli
 983 018a DEBF      		out __SP_H__,r29
 984 018c 0FBE      		out __SREG__,__tmp_reg__
 985 018e CDBF      		out __SP_L__,r28
 986               	/* prologue: function */
 987               	/* frame size = 8 */
 988               	/* stack size = 10 */
 989               	.L__stack_usage = 10
 990 0190 8B83      		std Y+3,r24
 991 0192 7D83      		std Y+5,r23
 992 0194 6C83      		std Y+4,r22
 993 0196 5F83      		std Y+7,r21
 994 0198 4E83      		std Y+6,r20
 995 019a 2887      		std Y+8,r18
1003:optiboot_flash.c ****     switch (memtype) {
 997               	.LM112:
 998 019c 8B81      		ldd r24,Y+3
 999 019e 082E      		mov __tmp_reg__,r24
 1000 01a0 000C      		lsl r0
 1001 01a2 990B      		sbc r25,r25
 1002 01a4 8534      		cpi r24,69
 1003 01a6 9105      		cpc r25,__zero_reg__
 1004 01a8 01F4      		brne .L43
 1005               	.L41:
1004:optiboot_flash.c ****     case 'E': // EEPROM
1005:optiboot_flash.c **** #if defined(SUPPORT_EEPROM) || defined(BIGBOOT)
1006:optiboot_flash.c ****         while(len--) {
1007:optiboot_flash.c ****       eeprom_write_byte((address.bptr++), *(mybuff.bptr++));
1008:optiboot_flash.c ****         }
1009:optiboot_flash.c **** #else
1010:optiboot_flash.c ****   /*
1011:optiboot_flash.c ****    * On systems where EEPROM write is not supported, just busy-loop
1012:optiboot_flash.c ****    * until the WDT expires, which will eventually cause an error on
1013:optiboot_flash.c ****    * host system (which is what it should do.)
1014:optiboot_flash.c ****    */
1015:optiboot_flash.c ****   while (1)
1016:optiboot_flash.c ****       ; // Error: wait for WDT
 1007               	.LM113:
 1008 01aa 00C0      		rjmp .L41
 1009               	.L43:
 1010               	.LBB5:
1017:optiboot_flash.c **** #endif
1018:optiboot_flash.c ****   break;
1019:optiboot_flash.c ****     default:  // FLASH
1020:optiboot_flash.c ****   /*
1021:optiboot_flash.c ****    * Default to writing to Flash program memory.  By making this
1022:optiboot_flash.c ****    * the default rather than checking for the correct code, we save
1023:optiboot_flash.c ****    * space on chips that don't support any other memory types.
1024:optiboot_flash.c ****    */
1025:optiboot_flash.c ****   {
1026:optiboot_flash.c ****       // Copy buffer into programming buffer
1027:optiboot_flash.c ****       uint16_t addrPtr = address.word;
 1012               	.LM114:
 1013 01ac 8E81      		ldd r24,Y+6
 1014 01ae 9F81      		ldd r25,Y+7
 1015 01b0 9A83      		std Y+2,r25
 1016 01b2 8983      		std Y+1,r24
1028:optiboot_flash.c **** 
1029:optiboot_flash.c ****       /*
1030:optiboot_flash.c ****        * Start the page erase and wait for it to finish.  There
1031:optiboot_flash.c ****        * used to be code to do this while receiving the data over
1032:optiboot_flash.c ****        * the serial link, but the performance improvement was slight,
1033:optiboot_flash.c ****        * and we needed the space back.
1034:optiboot_flash.c ****        */
1035:optiboot_flash.c ****       do_spm(address.word,__BOOT_PAGE_ERASE,0);
 1018               	.LM115:
 1019 01b4 8E81      		ldd r24,Y+6
 1020 01b6 9F81      		ldd r25,Y+7
 1021 01b8 40E0      		ldi r20,0
 1022 01ba 50E0      		ldi r21,0
 1023 01bc 63E0      		ldi r22,lo8(3)
 1024 01be 0E94 0000 		call do_spm
 1025               	.L42:
1036:optiboot_flash.c ****       //boot_spm_busy_wait();
1037:optiboot_flash.c ****       
1038:optiboot_flash.c ****       /*
1039:optiboot_flash.c ****        * Copy data from the buffer into the flash write buffer.
1040:optiboot_flash.c ****        */
1041:optiboot_flash.c ****       do {
1042:optiboot_flash.c ****     do_spm((uint16_t)(void*)addrPtr,__BOOT_PAGE_FILL, *(mybuff.wptr++));
 1027               	.LM116:
 1028 01c2 8C81      		ldd r24,Y+4
 1029 01c4 9D81      		ldd r25,Y+5
 1030 01c6 9C01      		movw r18,r24
 1031 01c8 2E5F      		subi r18,-2
 1032 01ca 3F4F      		sbci r19,-1
 1033 01cc 3D83      		std Y+5,r19
 1034 01ce 2C83      		std Y+4,r18
 1035 01d0 FC01      		movw r30,r24
 1036 01d2 2081      		ld r18,Z
 1037 01d4 3181      		ldd r19,Z+1
 1038 01d6 8981      		ldd r24,Y+1
 1039 01d8 9A81      		ldd r25,Y+2
 1040 01da A901      		movw r20,r18
 1041 01dc 61E0      		ldi r22,lo8(1)
 1042 01de 0E94 0000 		call do_spm
1043:optiboot_flash.c ****     addrPtr += 2;
 1044               	.LM117:
 1045 01e2 8981      		ldd r24,Y+1
 1046 01e4 9A81      		ldd r25,Y+2
 1047 01e6 0296      		adiw r24,2
 1048 01e8 9A83      		std Y+2,r25
 1049 01ea 8983      		std Y+1,r24
1044:optiboot_flash.c ****       } while (len -= 2);
 1051               	.LM118:
 1052 01ec 8885      		ldd r24,Y+8
 1053 01ee 8250      		subi r24,lo8(-(-2))
 1054 01f0 8887      		std Y+8,r24
 1055 01f2 8885      		ldd r24,Y+8
 1056 01f4 8823      		tst r24
 1057 01f6 01F4      		brne .L42
1045:optiboot_flash.c **** 
1046:optiboot_flash.c ****       /*
1047:optiboot_flash.c ****        * Actually Write the buffer to flash (and wait for it to finish.)
1048:optiboot_flash.c ****        */
1049:optiboot_flash.c ****       do_spm(address.word,__BOOT_PAGE_WRITE,0);
 1059               	.LM119:
 1060 01f8 8E81      		ldd r24,Y+6
 1061 01fa 9F81      		ldd r25,Y+7
 1062 01fc 40E0      		ldi r20,0
 1063 01fe 50E0      		ldi r21,0
 1064 0200 65E0      		ldi r22,lo8(5)
 1065 0202 0E94 0000 		call do_spm
 1066               	.LBE5:
1050:optiboot_flash.c ****   } // default block
1051:optiboot_flash.c ****   break;
 1068               	.LM120:
 1069 0206 0000      		nop
1052:optiboot_flash.c ****     } // switch
1053:optiboot_flash.c **** }
 1071               	.LM121:
 1072 0208 0000      		nop
 1073               	/* epilogue start */
 1074 020a 2896      		adiw r28,8
 1075 020c 0FB6      		in __tmp_reg__,__SREG__
 1076 020e F894      		cli
 1077 0210 DEBF      		out __SP_H__,r29
 1078 0212 0FBE      		out __SREG__,__tmp_reg__
 1079 0214 CDBF      		out __SP_L__,r28
 1080 0216 DF91      		pop r29
 1081 0218 CF91      		pop r28
 1082 021a 0895      		ret
 1087               	.Lscope10:
 1089               		.stabd	78,0,0
 1095               	read_mem:
 1096               		.stabd	46,0,0
1054:optiboot_flash.c **** 
1055:optiboot_flash.c **** static inline void read_mem(uint8_t memtype, addr16_t address, pagelen_t length)
1056:optiboot_flash.c **** {
 1098               	.LM122:
 1099               	.LFBB11:
 1100 021c CF93      		push r28
 1101 021e DF93      		push r29
 1102 0220 00D0      		rcall .
 1103 0222 00D0      		rcall .
 1104 0224 1F92      		push __zero_reg__
 1105 0226 CDB7      		in r28,__SP_L__
 1106 0228 DEB7      		in r29,__SP_H__
 1107               	/* prologue: function */
 1108               	/* frame size = 5 */
 1109               	/* stack size = 7 */
 1110               	.L__stack_usage = 7
 1111 022a 8A83      		std Y+2,r24
 1112 022c 7C83      		std Y+4,r23
 1113 022e 6B83      		std Y+3,r22
 1114 0230 4D83      		std Y+5,r20
 1115               	.L45:
1057:optiboot_flash.c ****     uint8_t ch;
1058:optiboot_flash.c **** 
1059:optiboot_flash.c ****     switch (memtype) {
1060:optiboot_flash.c **** 
1061:optiboot_flash.c **** #if defined(SUPPORT_EEPROM) || defined(BIGBOOT)
1062:optiboot_flash.c ****     case 'E': // EEPROM
1063:optiboot_flash.c ****   do {
1064:optiboot_flash.c ****       putch(eeprom_read_byte((address.bptr++)));
1065:optiboot_flash.c ****   } while (--length);
1066:optiboot_flash.c ****   break;
1067:optiboot_flash.c **** #endif
1068:optiboot_flash.c ****     default:
1069:optiboot_flash.c ****   do {
1070:optiboot_flash.c **** #ifdef VIRTUAL_BOOT_PARTITION
1071:optiboot_flash.c ****         // Undo vector patch in bottom page so verify passes
1072:optiboot_flash.c ****       if (address.word == rstVect0) ch = rstVect0_sav;
1073:optiboot_flash.c ****       else if (address.word == rstVect1) ch = rstVect1_sav;
1074:optiboot_flash.c ****       else if (address.word == saveVect0) ch = saveVect0_sav;
1075:optiboot_flash.c ****       else if (address.word == saveVect1) ch = saveVect1_sav;
1076:optiboot_flash.c ****       else ch = pgm_read_byte_near(address.bptr);
1077:optiboot_flash.c ****       address.bptr++;
1078:optiboot_flash.c **** #elif defined(RAMPZ)
1079:optiboot_flash.c ****       // Since RAMPZ should already be set, we need to use EPLM directly.
1080:optiboot_flash.c ****       // Also, we can use the autoincrement version of lpm to update "address"
1081:optiboot_flash.c ****       //      do putch(pgm_read_byte_near(address++));
1082:optiboot_flash.c ****       //      while (--length);
1083:optiboot_flash.c ****       // read a Flash and increment the address (may increment RAMPZ)
1084:optiboot_flash.c ****       __asm__ ("elpm %0,Z+\n" : "=r" (ch), "=z" (address.bptr): "1" (address));
1085:optiboot_flash.c **** #else
1086:optiboot_flash.c ****       // read a Flash byte and increment the address
1087:optiboot_flash.c ****       __asm__ ("lpm %0,Z+\n" : "=r" (ch), "=z" (address.bptr): "1" (address));
 1117               	.LM123:
 1118 0232 8B81      		ldd r24,Y+3
 1119 0234 9C81      		ldd r25,Y+4
 1120 0236 FC01      		movw r30,r24
 1121               	/* #APP */
 1122               	 ;  1087 "optiboot_flash.c" 1
 1123 0238 2591      		lpm r18,Z+
 1124               	
 1125               	 ;  0 "" 2
 1126               	/* #NOAPP */
 1127 023a CF01      		movw r24,r30
 1128 023c 2983      		std Y+1,r18
 1129 023e 9C83      		std Y+4,r25
 1130 0240 8B83      		std Y+3,r24
1088:optiboot_flash.c **** #endif
1089:optiboot_flash.c ****       putch(ch);
 1132               	.LM124:
 1133 0242 8981      		ldd r24,Y+1
 1134 0244 0E94 0000 		call putch
1090:optiboot_flash.c ****   } while (--length);
 1136               	.LM125:
 1137 0248 8D81      		ldd r24,Y+5
 1138 024a 8150      		subi r24,lo8(-(-1))
 1139 024c 8D83      		std Y+5,r24
 1140 024e 8D81      		ldd r24,Y+5
 1141 0250 8823      		tst r24
 1142 0252 01F4      		brne .L45
1091:optiboot_flash.c ****   break;
 1144               	.LM126:
 1145 0254 0000      		nop
1092:optiboot_flash.c ****     } // switch
1093:optiboot_flash.c **** }
 1147               	.LM127:
 1148 0256 0000      		nop
 1149               	/* epilogue start */
 1150 0258 0F90      		pop __tmp_reg__
 1151 025a 0F90      		pop __tmp_reg__
 1152 025c 0F90      		pop __tmp_reg__
 1153 025e 0F90      		pop __tmp_reg__
 1154 0260 0F90      		pop __tmp_reg__
 1155 0262 DF91      		pop r29
 1156 0264 CF91      		pop r28
 1157 0266 0895      		ret
 1162               	.Lscope11:
 1164               		.stabd	78,0,0
 1170               	do_spm:
 1171               		.stabd	46,0,0
1094:optiboot_flash.c **** 
1095:optiboot_flash.c **** /*
1096:optiboot_flash.c ****  * Separate function for doing spm stuff
1097:optiboot_flash.c ****  * It's needed for application to do SPM, as SPM instruction works only
1098:optiboot_flash.c ****  * from bootloader.
1099:optiboot_flash.c ****  *
1100:optiboot_flash.c ****  * How it works:
1101:optiboot_flash.c ****  * - do SPM
1102:optiboot_flash.c ****  * - wait for SPM to complete
1103:optiboot_flash.c ****  * - if chip have RWW/NRWW sections it does additionaly:
1104:optiboot_flash.c ****  *   - if command is WRITE or ERASE, AND data=0 then reenable RWW section
1105:optiboot_flash.c ****  *
1106:optiboot_flash.c ****  * In short:
1107:optiboot_flash.c ****  * If you play erase-fill-write, just set data to 0 in ERASE and WRITE
1108:optiboot_flash.c ****  * If you are brave, you have your code just below bootloader in NRWW section
1109:optiboot_flash.c ****  *   you could do fill-erase-write sequence with data!=0 in ERASE and
1110:optiboot_flash.c ****  *   data=0 in WRITE
1111:optiboot_flash.c ****  */
1112:optiboot_flash.c **** static void do_spm(uint16_t address, uint8_t command, uint16_t data) {
 1173               	.LM128:
 1174               	.LFBB12:
 1175 0268 CF93      		push r28
 1176 026a DF93      		push r29
 1177 026c 00D0      		rcall .
 1178 026e 00D0      		rcall .
 1179 0270 1F92      		push __zero_reg__
 1180 0272 CDB7      		in r28,__SP_L__
 1181 0274 DEB7      		in r29,__SP_H__
 1182               	/* prologue: function */
 1183               	/* frame size = 5 */
 1184               	/* stack size = 7 */
 1185               	.L__stack_usage = 7
 1186 0276 9A83      		std Y+2,r25
 1187 0278 8983      		std Y+1,r24
 1188 027a 6B83      		std Y+3,r22
 1189 027c 5D83      		std Y+5,r21
 1190 027e 4C83      		std Y+4,r20
1113:optiboot_flash.c ****     // Do spm stuff
1114:optiboot_flash.c **** #if defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)    
1115:optiboot_flash.c ****      asm volatile (
1116:optiboot_flash.c ****    "    movw  r0, %3\n"
1117:optiboot_flash.c ****          "   sts %0, %1\n"
1118:optiboot_flash.c ****          "   spm\n"
1119:optiboot_flash.c ****          "   clr  r1\n"
1120:optiboot_flash.c ****          :
1121:optiboot_flash.c ****          : "i" (_SFR_MEM_ADDR(__SPM_REG)),
1122:optiboot_flash.c ****            "r" ((uint8_t)command),
1123:optiboot_flash.c ****            "z" ((uint16_t)address),
1124:optiboot_flash.c ****            "r" ((uint16_t)data)
1125:optiboot_flash.c ****          : "r0"
1126:optiboot_flash.c ****      );
1127:optiboot_flash.c **** #else 
1128:optiboot_flash.c ****     asm volatile (
 1192               	.LM129:
 1193 0280 4B81      		ldd r20,Y+3
 1194 0282 8981      		ldd r24,Y+1
 1195 0284 9A81      		ldd r25,Y+2
 1196 0286 2C81      		ldd r18,Y+4
 1197 0288 3D81      		ldd r19,Y+5
 1198 028a FC01      		movw r30,r24
 1199               	/* #APP */
 1200               	 ;  1128 "optiboot_flash.c" 1
 1201 028c 0901      		    movw  r0, r18
 1202 028e 47BF      	   out 55, r20
 1203 0290 E895      	   spm
 1204 0292 1124      	   clr  r1
 1205               	
 1206               	 ;  0 "" 2
 1207               	/* #NOAPP */
 1208               	.L47:
1129:optiboot_flash.c ****   "    movw  r0, %3\n"
1130:optiboot_flash.c ****          "   out %0, %1\n"
1131:optiboot_flash.c ****          "   spm\n"
1132:optiboot_flash.c ****          "   clr  r1\n"
1133:optiboot_flash.c ****          :
1134:optiboot_flash.c ****          : "i" (_SFR_IO_ADDR(__SPM_REG)),
1135:optiboot_flash.c ****            "r" ((uint8_t)command),
1136:optiboot_flash.c ****            "z" ((uint16_t)address),
1137:optiboot_flash.c ****            "r" ((uint16_t)data)
1138:optiboot_flash.c ****          : "r0"
1139:optiboot_flash.c ****     );     
1140:optiboot_flash.c **** #endif    
1141:optiboot_flash.c **** 
1142:optiboot_flash.c ****     // wait for spm to complete
1143:optiboot_flash.c ****     //   it doesn't have much sense for __BOOT_PAGE_FILL,
1144:optiboot_flash.c ****     //   but it doesn't hurt and saves some bytes on 'if'
1145:optiboot_flash.c ****     boot_spm_busy_wait();
 1210               	.LM130:
 1211 0294 87E5      		ldi r24,lo8(87)
 1212 0296 90E0      		ldi r25,0
 1213 0298 FC01      		movw r30,r24
 1214 029a 8081      		ld r24,Z
 1215 029c 882F      		mov r24,r24
 1216 029e 90E0      		ldi r25,0
 1217 02a0 8170      		andi r24,1
 1218 02a2 9927      		clr r25
 1219 02a4 892B      		or r24,r25
 1220 02a6 01F4      		brne .L47
1146:optiboot_flash.c **** #if defined(RWWSRE)
1147:optiboot_flash.c ****     // this 'if' condition should be: (command == __BOOT_PAGE_WRITE || command == __BOOT_PAGE_ERASE
1148:optiboot_flash.c ****     // but it's tweaked a little assuming that in every command we are interested in here, there
1149:optiboot_flash.c ****     // must be also SELFPRGEN set. If we skip checking this bit, we save here 4B
1150:optiboot_flash.c ****     if ((command & (_BV(PGWRT)|_BV(PGERS))) && (data == 0) ) {
 1222               	.LM131:
 1223 02a8 8B81      		ldd r24,Y+3
 1224 02aa 882F      		mov r24,r24
 1225 02ac 90E0      		ldi r25,0
 1226 02ae 8670      		andi r24,6
 1227 02b0 9927      		clr r25
 1228 02b2 892B      		or r24,r25
 1229 02b4 01F0      		breq .L49
 1231               	.LM132:
 1232 02b6 8C81      		ldd r24,Y+4
 1233 02b8 9D81      		ldd r25,Y+5
 1234 02ba 892B      		or r24,r25
 1235 02bc 01F4      		brne .L49
1151:optiboot_flash.c ****       // Reenable read access to flash
1152:optiboot_flash.c **** #if defined(__AVR_ATmega64__) || defined(__AVR_ATmega128__)      
1153:optiboot_flash.c ****       __boot_rww_enable();
1154:optiboot_flash.c **** #else
1155:optiboot_flash.c ****       boot_rww_enable();
 1237               	.LM133:
 1238 02be 81E1      		ldi r24,lo8(17)
 1239               	/* #APP */
 1240               	 ;  1155 "optiboot_flash.c" 1
 1241 02c0 87BF      		out 55, r24
 1242 02c2 E895      		spm
 1243               		
 1244               	 ;  0 "" 2
 1245               	/* #NOAPP */
 1246               	.L49:
1156:optiboot_flash.c **** #endif      
1157:optiboot_flash.c ****     }
1158:optiboot_flash.c **** #endif
1159:optiboot_flash.c **** }
 1248               	.LM134:
 1249 02c4 0000      		nop
 1250               	/* epilogue start */
 1251 02c6 0F90      		pop __tmp_reg__
 1252 02c8 0F90      		pop __tmp_reg__
 1253 02ca 0F90      		pop __tmp_reg__
 1254 02cc 0F90      		pop __tmp_reg__
 1255 02ce 0F90      		pop __tmp_reg__
 1256 02d0 DF91      		pop r29
 1257 02d2 CF91      		pop r28
 1258 02d4 0895      		ret
 1260               	.Lscope12:
 1262               		.stabd	78,0,0
 1266               	.Letext0:
 1267               		.ident	"GCC: (GNU) 5.4.0"
 1268               	.global __do_copy_data
