

/*
 *  DISCLAIMER
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
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
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

;----------------------------------------------------------------------
;
; ok ( -- 0 ) 
;
HEADER "4", "FOUR", F_LEAP
    NOOP 
    pspush tos_low, tos_high 
    clr tos_low 
    clr tos_high 
    adiw tos_low, 4
    POON 

;----------------------------------------------------------------------
;
; ok ( w -- w + 4 ) 
;
HEADER "4+", "FOURPLUS",
     .word FOUR, PLUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w -- w - 4 ) 
;
HEADER "4-", "FOURMINUS",
     .word FOUR, MINUS, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- ) 
;
HEADER "2>R", "TWOTOR",
     .word SWAP, RTO, RTO, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- ) 
;
HEADER "2R>", "TWORTO",
     .word RTO, RTO, SWAP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- ) 
;
HEADER "2R@", "TWORAT",
     .word RTO, RTO, TWODUP, TOR, TOR, SWAP, ENDS
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w1 w2 w1 w2 ) 
;
HEADER "2DROP", "TWODROP",
     .word DROP, DROP, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 -- w1 w2 w1 w2 ) 
;
HEADER "2DUP", "TWODUP",
     .word OVER, OVER, ENDS 
 
;----------------------------------------------------------------------
;
; ok ( w1 w2 w3 w4 -- w3 w4 w1 w2 ) 
;
HEADER "2SWAP", "TWOSWAP",
     .word ROTU, TOR, ROTU, TOR, ENDS 
     
;----------------------------------------------------------------------
;
; ok ( w1 w2 w3 w4 -- w3 w4 + w1 w2 ) 
;
HEADER "D+", "DPLUS",
     .word TOR, SWAP, TOR, UMPLUS, RTO, RTO, UMPLUS, UMPLUS, ENDS 
     
;----------------------------------------------------------------------
;
; ok ( w1 w2 w3 w4 -- w3 w4 - w1 w2 ) 
;
HEADER "D-", "DMINUS",
     .word ENDS 
     
 
