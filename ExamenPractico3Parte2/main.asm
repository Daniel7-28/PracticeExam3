 ;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

            .sect ".sysmem"

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
;polling .set 1

tLow 	.word 0x1000
tHigh 	.word 0x1000
tOffset .word 0
tRotates .word 2
_main

RESET       mov.w   #2020h,SP                               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL                  ; Stop WDT
            bis.b   #BIT1,&P1DIR                            ; Set P1.0 to output direction
            bis.b   #BIT1,&P1OUT

	bic.b   #BIT3,&P2DIR			; P2.3 input
    bis.b   #BIT3,&P2REN            ; P2.3 pull-up register enable
	bis.b   #BIT3,&P2OUT            ; Configure P2.3 as pulled-up
    bis.b   #BIT3,&P2IES            ; P2.3 Lo/Hi edge

	; The next instruction is only needed for models MSP430FRXXXX
    bic.w   #LOCKLPM5,&PM5CTL0	; Unlock I/O pins - not needed for MSP430G2553

    bis.w   #CCIE,&TA0CCTL0                         ; TACCR0 interrupt enabled
    mov.w   tLow,&TA0CCR0
    mov.w   tLow, tOffset
    bis.w   #TASSEL__ACLK|ID_3|MC__CONTINOUS,&TA0CTL
    ; ACLK/8 counts 32768/8 pulses/sec = 4096 pulses/sec = 0x1000 in hex, continuous mode
    ; 2 x 0x1800/0x1000 = 3 secs/ cycle

 	nop
	bis.w   #GIE,SR
Mainloop
	nop
	bit.b #BIT3, &P2IN			; poll p2.3
	jnz Mainloop
	dec tRotates
	jz iRotates
	rra tLow
	rra tHigh
	bit.b #BIT3, &P2IN
	jz L1
L0:
	rla tLow
	rla tHigh
	jmp Mainloop

L1:

	bit.b #BIT3, &P2IN
	jeq L1
	jmp L0

iRotates:
	mov #2, tRotates
	mov #0x1000, tLow
	mov #0x1000, tHigh
	jmp Mainloop
	nop
	bis.w   #LPM0+GIE,SR                            ; Enter LPM0 w/ interrupt
    nop

;-------------------------------------------------------------------------------
TIMER0_A0_ISR;    ISR for TA0CCR0
;-------------------------------------------------------------------------------

	xor.b   #BIT1,&P1OUT 	; Toggle LED
    cmp tLow, tOffset
    jne tL1
    mov tHigh,tOffset  		; Add offset to TA0CCR0
    jmp tL2
tL1:
	mov tLow, tOffset
tL2:
	add.w   tOffset,&TA0CCR0 	; Add offset to TA0CCR0
    reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   RESET_VECTOR   		 ; MSP430 RESET Vector
			.short  RESET
			.sect   TIMER0_A0_VECTOR 	 ; Timer A0 ISR
			.short  TIMER0_A0_ISR
			.end
