
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

: jump wk @ ip dup @ 2+ ! exec ;

: next ip @ dup @ wk ! 2+ ip ! 
    wk @ if jump else nest then ;

nexti is next

\ all twig words end with: unnest 
\ all leaf words end with: jmp unnest

*/

// size of memory
#define END 1024

// size of stack
#define STK 18

// number of primitives
#define WDS 26

#define MAX 10

#define debug 1

#define last -1

int main (int argc, char * argv[]) {

int zz = 0;

int  i, j, k, n, m, p;

int  ip, dp, wk, rp;

// links to routines
int  hdr[END];

// plain memory
int  ram[END];

// stack return
int  stk[STK];

// label and goto self routines

goto setup;

// pull ip
unnest:
	ip = stk[rp];
	rp++;
    if (debug) {
        printf ("\nunnest < ip %4d wk %4d rp %4d =",  ip, wk, rp);
        printf ("( "); for (i=rp; i < STK; i++)  printf ("%4d ", stk[i]); printf (")\n");
        }
	goto next;

//; load wk with contents of cell at ip
next: 

	wk = ram[ip];
	ip++;

    if (debug) {
        printf ("\nnext = ip %4d wk %4d rp %4d =",  ip, wk, rp);
        }

    if (zz++ > 512) return (0);

//; if last (-1) is a end of compoud word
    if ( wk == -1) goto unnest;

//; if zero (NULL) is a primitive word
    if ( wk == 0 ) goto jump;

//; else is a reference
	goto nest;

// push ip
nest:
	rp--; 
    stk[rp] = ip;
    ip = wk;
    if (debug) {
        printf ("\nnest > ip %4d wk %4d rp %4d =",  ip, wk, rp);
        printf ("( "); for (i=rp; i < STK; i++)  printf ("%4d ", stk[i]); printf (")\n");
        }
	goto next;

//; continue 
link:
    if (debug) {
        printf ("\nlink > ip %4d wk %4d rp %4d =\n",  ip, wk, rp);
        }
	//printf ("\n");
	goto unnest;

//; then jump, for exec it, save next return into ip
jump:
    // skip zero
	wk = ip;
    if (debug) {
        printf ("\njump > ip %4d wk %4d rp %4d =\n",  ip, wk, rp);
        }
	goto exec;

//; exec
exec:
    if (debug) {
        printf ("%2d %2d,", wk, ram[wk]);
        }
    goto link;

// setup pointers
setup:

    rp = STK - 1;

// loop random links

    {

    unsigned int seed;

    seed = atoi(argv[1]); //(unsigned int *) (void *) &main;

    srand ( ( seed ) );

    }


// setup primitives

    for (n = 0, m = 0 ; n < WDS ; n++, m++) {

        ram[n] = 0;

        hdr[m] = n;
        
        }

// setup some random compound

    while (n < END) {

        hdr[m] = n;
// how many words
        j = rand() % MAX + 2;

        for (i = 0; i < j ; i++) {
// which words, no recursion
            p = rand() % (m - 2) + 1;

            ram[n] = hdr[p];
            
            n++;

            }   
        
        ram[n] = last; // to unnest

        n++;

        m++;

        } 

    ram[n-1] = last;

    
    wk = atoi (argv[3]);

// dump it 
        
    if (wk && 0x1) {

    j = WDS;

    printf ("\n (%4d %4d) ", j, hdr[j]);

    for (j = i = 0; i < END; i++) {

        if (i < WDS) { j++; continue; };
  
        printf ("%4d ",ram[i]);

        if (ram[i] == -1)  {
            
            j++;
            printf ("\n (%4d %4d) ", j, hdr[j]);

            }

        }    
    }

// test it 

    if (wk && 0x2) {

        printf ("\n\n");

// grow stack
        for (i = 0; i < STK - 2; i++) {
            
            j = rand() % (m - WDS) + WDS;

            stk[i] = hdr[j];
            
            printf ("& %4d %4d %4d\n", i, j, stk[i]);

            }
        
        stk[i] = stk[0];
        
        printf ("& %4d %4d %4d\n", i, 0, stk[i]);

        rp = STK; // grows downwards

        ip = wk = stk[0];
    
        goto nest;
    
        }

    return (0);

}
