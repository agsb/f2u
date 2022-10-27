

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

#include <stdio.h>
#include <stdlib.h>

/*

simple simulator for extended indirect thread code

0 variable ip
0 variable wk

defer nexti

: unnest r> ip ! nexti ;

: nest ip @ >r   nexti ;

: jump wk ! ip dup @ 2+ ! exec ;

: next ip @ dup @ wk ! 2+ ip ! 
    wk @ IF jump    
         ELSE unnest
         THEN ;

nexti is next

*/

#define END 1024

#define STK 18

#define WDS 26

#define MAX 10

#define debug 1

int main (int argc, char * argv[]) {

int  i, j, k, n, m, p;

int  ip, dp, wk, rp;

int  hdr[END];

int  ram[END];

int  stk[STK];

// label and goto self routines

goto setup;

// pop ip
unnest:
	ip = stk[rp];
	rp++;
    if (debug) printf ("<%4d", ip);
	goto next;

//; load wk with contents of cell at ip
next: 
	wk = ram[ip];
	ip++;
//; if zero (NULL) is a primitive word
    if ( ! wk ) goto jump;
//; else is a reference
	goto nest;

// push ip
nest:
	rp--; 
    stk[rp] = ip;
    ip = wk;
    if (debug) printf (">%4d", ip);
	goto next;

//; continue 
link:
	putchar ('\n');
	goto next;

//; then jump, for exec it, save next return into ip
jump:
	wk = ip;
	ip++;
	goto exec;

//; exec
exec:
    putchar ('Z' - wk);
    goto link;

// setup pointers
setup:

    rp = STK - 1;

// loop random links

    srand (1);

// setup primitives

    for (n = 0, m = 0 ; n < WDS ; n++, m++) {

        ram[n] = 0;

        hdr[m] = n;
        
        }

// setup some random 

    while (n < END) {

        hdr[m] = n;

        j = rand() % MAX + 2;

        for (i = 0; i < j ; i++) {

            p = rand() % (m - 2) + 1;

            ram[n] = hdr[p];
            
            n++;

            }   
        
        ram[n] = 0;

        n++;

        m++;

        } 

// dump it 
        
    j = 0;

    for (i = 0; i < END; i++) {

        if (i < WDS) { j++; continue; };
  
        printf ("%4d ",ram[i]);

        if (ram[i] == 0)  {
            
            printf (" == %4d %4d\n (%4d) ", hdr[j], j, i);

            j++;

            }

        }    

    return (0);

}
