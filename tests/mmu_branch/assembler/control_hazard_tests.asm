////////////////////////////////////////////////////////////
// BRANCH PREDICTION AND CONTROL HAZARD TEST
////////////////////////////////////////////////////////////

start:
LDI r1, 0, 0x0001	    ;pc = 0
LDI r2, 0, 0x0002		;pc = 1 // right edge
LDI r3, 0, 0x0003		;pc = 2

LDI r4, 0, 0x0100		;pc = 3 // starting position
LDI r5, 0, 0x4000		;pc = 4 // left edge

shift_left:
BGT r4, r5, wait_left	;pc = 5 -> pc = 8 | branch not taken, flush pc=8 on ID
MLHU r4, r2, r4			;pc = 6
JMP shift_left			;pc = 7 -> pc = 5

wait_left:
AHS r0, r1, r0			;pc = 8,  
BNEQ r0, r3, shift_left	;pc = 9 -> pc = 5

LDI r0, 0, 0x00			;pc = 10

shift_right:
BLT r4, r2, wait_right	;pc = 11 -> pc = 13
SHRHI 1, r4, r4			;pc = 12
JMP shift_right			;pc = 13 -> pc = 11

wait_right:	
AHS r0, r1, r0			;pc = 14
BNEQ r0, r3, shift_right;pc = 15 -> pc = 11				
	
end:
jmp end					;pc = 16 -> pc = 16

