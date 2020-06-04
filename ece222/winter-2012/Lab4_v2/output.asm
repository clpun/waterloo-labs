out_crlf ; go to newline subroutine, taken from lab1 source code
				move.l   D1,-(A7)
				move     #CR,D1
				jsr      out_char 
				move     #LF,D1 
				jsr      out_char 
				move.l   (A7)+,D1 
				rts 
					
out_string ; output all the characters, taken from lab1 source code
				move.l  D1,-(A7) 
				move.l	A1,-(A7) 
out_next_char
				move.b	(A1)+,D1 
				jsr		out_char 
				tst.b	D1 
				bne		out_next_char 
				move.l	(A7)+,A1 					
				move.l	(A7)+,D1 
				rts
					
out_char ; display a character onto monitor
				move.l	D0,-(A7)
				move.l	D2,-(A7)
				clr.l	D2
				clr.l	D0
				move.b	#%0100,D0
;;;;;;;;;;;;;Replace Trap #15;;;;;;;;;;;;;
WAIT_TRANSMITTER
				move.b	D0,UCR0			; set “Transmitter Enable” bit(bit 2) in UCR0 to 1
				move.b	USR0,D2
				btst.b	#2,D2			; test if a key is pressed by checking if bit2 is zero
				beq		WAIT_TRANSMITTER; wait for key to be pressed
;;;;;;;;;;;;;Replace Trap #15;;;;;;;;;;;;;
				move.b	D1,UTB0			; take content of D1 and store it into UTBO
				move.l	(A7)+,D2
				move.l	(A7)+,D0
				rts