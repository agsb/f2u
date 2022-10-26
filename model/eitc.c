#include <stdio.h>
#include <stdlib.h>

/*
    simple model for extended indirect thread code

    */

#define MAX 7000

unsigned int pc, ip, sp, rp, dp, w, a, b;
    
unsigned int memory[MAX];


/*

label and goto self routines

*/

_exit: //unnest
	ip = m[rp];
	rp++;
	goto _next;

; load w with contents of cell at ips
; if zero (NULL) is a primitive word
_next: // next
	w = m[ip];
	ip++;
    if ( ! w ) goto _jump;
	goto _enter;

; else is a reference
_enter: //nest
	rp--; 
    m[rp] = ip;
    ip = w;
	goto _next;

; continue 
_link:
	putc ('\n');
	goto _next;

; then jump, for exec it, save next return into ips
_jump:
	w = ip;
	ip++;
	pc = w;
	goto _prime;

_prime:
	putc (w+'A');
	goto _link;

int main (int argc, char * argv[]) {

    sp = STK;
    
    rp = STK + STK;
    
    pc = rp + 1;
    
    dp = pc + 1;

    w = a = b = 0


