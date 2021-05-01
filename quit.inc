
;----------------------------------------------------------------------
;
HEADER "QUIT", "QUIT"
	
		.word HEX, LBRACKET, RSP0, RP!, PSP0, SP!, STATE, AT, ZEQUAL, ZBRANCH, QUIT2, PPTREADY 
QUIT2:	.word REFILL, PPTINPUT, ZBRANCH, QUIT3,
		.word DOLIT, INTERPRET, CATCH, ZDUP, ZBRANCH, QUIT3,
		.word DUP, DOLIT, -2, LESS, ZBRANCH, QUIT5,
		.word PPTERROR,
QUIT5:	.word BRANCH, QUIT,
QUIT3:	.word PPTOKEY,
		.word BRANCH, QUIT2,
	  	.word _LAST

;----------------------------------------------------------------------
;
HEADER ".ready", "PPTREADY"
.word CR, DOSTRING,  
			.string "> " "			
			.word TYPE, .word _LAST

;----------------------------------------------------------------------
;
HEADER ".input", "PPTINPUT"
.word CR, _LAST

;----------------------------------------------------------------------
;
HEADER ".error", "PPTERROR"
.word CR, DOSTRING,  
			.string " "??? " 
			.word TYPE, BASE, AT, TOR, DEC, DOT, TOIN, AT, DOT, RTO, BASE, TO, _LAST

;----------------------------------------------------------------------
;
HEADER ".ok", "PPTOKEY"
.word STATE, AT, DROP, 
.word CR, DOSTRING,
			.string " "ok"
 			.word TYPE, 
			.word _LAST

