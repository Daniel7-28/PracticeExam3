
	.cdecls C, LIST, "msp430.h" ; Include device header file

	.global concatenateString	;concatenate two String

	;Input:
	;		R12 -> pointer to first character of String1
	;		R13 -> pointer to first character of String2
	;		R14 -> store the two Strings

concatenateString:

	mov R12, R15
	clr R12

L0:
	cmp.b #0, 0(R15)
	jeq L1
	mov.b 0(R15), 0(R14)
	inc R14
	inc R12
	inc R15
	jmp L0

L1:
	clr R15
	mov R13, R15
	clr R13
	jmp L2
L2:
	cmp.b #0, 0(R15)
	jeq Done
	mov.b 0(R15), 0(R14)
	inc R14
	inc R15
	inc R12
	jmp L2

Done:
	ret
