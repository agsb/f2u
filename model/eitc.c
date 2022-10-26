#include <stdio.h>
#include <stdlib.h>

/*

simple simulator model for extended indirect thread code

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

#define END 8192

#define STK 18

#define WDS 26

#define MAX 10

#define debug 1

int main (int argc, char * argv[]) {

int  i, j, k, n, m;

// define registers as 16 bits

int  ip, rp, wk;
int  pc, sp, dp, a, b;

// define  memory as 16 bits

int  ram[END];

// label and goto self routines

// pop ip
unnest:
	ip = ram[rp];
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
    ram[rp] = ip;
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

    sp = STK;
    
    rp = STK + STK;
    
    pc = rp + 1;
    
    dp = pc + 1;

    ip = pc;

    wk = a = b = 0;


// loop random links

    srand (1);

// setup primitives

    for (k = 0 ; k < WDS ; k++) {

        ram[k + dp] = 0;
        
        }

    dp = dp + k;

// setup some random 

    while (dp < (END-MAX) ) {

        k = rand() % MAX;
    
        printf ("~%4d",k);

        for (i = 0; i < k ; i++) {

            printf (":%4d",k);
            ram[dp] = rand() % dp;

            dp++;

            }   
        
        printf (":%4d",0);
        ram[dp] = 0;

        dp++;

        } 

// dump it 
        
    for (k = 0; k < dp; k++) {

        if (k < WDS) continue;

        printf ("%4d ",ram[k]);

        if (ram[k] == 0)  printf ("\n");

        }    

    return (0);

}
