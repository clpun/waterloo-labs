;;;;;;;;;;;;For keyboard...;;;;;;;;;;;
in_string	; All taken from lab1 source code
				move.l  D1,-(A7)
				move.l  D2,-(A7)
				move.l  A1,-(A7)
				move.l  #0, D2
in_string_loop	jsr 	in_char
				tst.l   D1
				beq     in_string_loop
				cmp.l   #CR,D1
				beq.w   exit_in_string
				cmp.l   #LF,D1
				beq.w   exit_in_string
				move.b  D1,(A1)+
				add.l   #1,D2
				bra     in_string_loop
				
exit_in_string	tst.l   D2
				beq     menu
				move.b	#0,(A1)
				
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				rts

in_char	; Takes input from user
				move.l  D0,-(A7)
				clr.l	D0
;;;;;;;;;;;;;;;To replace Trap #15;;;;;;;;;;;;;;;
WAIT_RECEIVER	move.b	USR0,D0
				btst.b	#0,D0			; test if a key is pressed
				beq		WAIT_RECEIVER	; wait for key to be pressed
				move.b	URB0,D1			; record key press into D1
;;;;;;;;;;;;;;;To replace Trap #15;;;;;;;;;;;;;;;
				and.l 	#$7F,D1
				bsr 	out_char 		; Echo the character back to the user
				move.l	(A7)+,D0
				rts

;;;;;;;;;For keypad...;;;;;;;
in_string_keypad
				move.l 	D1,-(A7)		; put D1 in stack
				move.l 	D2,-(A7)		; put D2 in stack
				move.l 	A1,-(A7)		; put A1 in stack
				move.l 	#0, D2 			; Keep character count
in_string_loop_keypad
				jsr 	in_keypad		; Get input from keypad
				cmp.l 	#LF,D1			; See if user has pressed enter
				beq.w 	exit_in_string_keypad ; if yes, user has finished typing word
				cmp.l 	#CR,D1			; See if user has pressed clear
				beq		clear_operation	; If yes, proceed to clear everything
				move.b 	D1,(A1)+
				add.l 	#1, D2			; Increase the character count
				bra 	in_string_loop_keypad	; Keep looping until user finished typing word (B)
exit_in_string_keypad
				tst.l 	D2
				beq 	menu 	; User pressed enter without inputing anything, goes back to main
				move.b	#0,(A1)
				move.l 	(A7)+,A1
				move.l 	(A7)+,D2
				move.l 	(A7)+,D1
				rts						; go back to main, reverse string and display on monitor

;;;;;;;;;;;clear for keypad;;;;;;;;;;;;
clear_operation
				tst.l	D2
				beq		no_input ; If no input, proceed to no_input
				move.b	-(A1),D1 ; clear everything
				sub.l	#1,D2
				cmp.l	#0,D2
				bne		clear_operation ; Keep looping until everything is cleared
				
no_input		move.b	#0,(A1)
				clr.l	D1
				jmp		in_string_loop_keypad

;;;;;;;;;Parallel interfacing for keypad;;;;;;;;;;
in_keypad
				move.l	A6,-(A7)
				move.l	A5,-(A7)
				move.l	D0,-(A7)
				move.l	D7,-(A7)
				clr.l	D0
				clr.l	D1
				clr.l	D7
				clr.w	PAR				; Initialize PAR with a word of zeros
;;;;;;;;;;;;Get row;;;;;;;;;;;;
				move.w	#$FFF0,D7		
				move.w	D7,PADDR		; Set column pins as outputs(1) and row pins as inputs(0)
				move.w	D7,PADAT		; Drive column pins high(1) and row pins low(0)
				lea		DELAY_TIME,A6
				move.l	#01,(A6)		; Execute a small 1ms time delay to give time for the voltage on the keypad wires to stabilize.
				bsr		CALCULATE_DELAY	; Make a delay
ROW_INPUT		move.w	PADAT,D0
				cmp.l	#$FFF0,D0		; wait for valid button press
				beq		ROW_INPUT
				move.l	#30,(A6)		; set 30ms delay to check for debouncing
				bsr		CALCULATE_DELAY
				move.w	PADAT,D0		; Retrieve row input
;;;;;;;;;;;;Get column;;;;;;;;;;
				move.W	#$FF0F,D7
				move.w	D7,PADDR		; Now set column pins as inputs(0) and row pins as outputs(1)
				move.w	D7,PADAT		; Drive column pins low(0) and row pins high(1)
				move.l	#01,(A6)		; set 1ms delay
				bsr		CALCULATE_DELAY
				move.w	PADAT,D1		; Retrieve column input
				and.l	D0,D1
				bsr		LOOKUP_CHARACTER
				
STOP_AUTO_REPEAT
				clr.l	D7
				move.w	PADAT,D7
				cmp.l	#$FF0F,D7
				bne		STOP_AUTO_REPEAT ; Keep looping until no input is received
				
				bsr		out_char	; print out the character
				move.l	(A7)+,D7
				move.l	(A7)+,D0
				move.l	(A7)+,A5
				move.l	(A7)+,A6
				rts
				
;;;;;;;;;;;;;;Determines button pressed;;;;;;;;;;;;;;;
LOOKUP_CHARACTER
				cmp	#$FF28,D1 ; 0
				beq	ZERO
				cmp	#$FF11,D1 ; 1
				beq	ONE
				cmp	#$FF21,D1 ; 2
				beq	TWO
				cmp	#$FF41,D1 ; 3
				beq	THREE
				cmp	#$FF12,D1 ; 4
				beq	FOUR
				cmp	#$FF22,D1 ; 5
				beq	FIVE
				cmp	#$FF42,D1 ; 6
				beq	SIX
				cmp	#$FF14,D1 ; 7
				beq	SEVEN
				cmp	#$FF24,D1 ; 8
				beq	EIGHT
				cmp	#$FF44,D1 ; 9
				beq	NINE
				cmp	#$FF18,D1 ; Clear
				beq	A
				cmp	#$FF48,D1 ; Enter
				beq	B
				cmp	#$FF81,D1 ; +
				beq	C
				cmp	#$FF82,D1 ; -
				beq	D
				cmp	#$FF84,D1 ; *
				beq	E
				cmp	#$FF88,D1 ; ^
				beq	F
ZERO			move.l	#$30,D1
				rts
ONE				move.l	#$31,D1
				rts
TWO				move.l	#$32,D1
				rts
THREE			move.l	#$33,D1
				rts
FOUR			move.l	#$34,D1
				rts
FIVE			move.l	#$35,D1
				rts
SIX				move.l	#$36,D1
				rts
SEVEN			move.l	#$37,D1
				rts
EIGHT			move.l	#$38,D1
				rts
NINE			move.l	#$39,D1
				rts
A				move.l	#$0D,D1
				rts
B				move.l	#$0A,D1
				rts
C				move.l	#$2B,D1
				rts
D				move.l	#$2D,D1
				rts
E				move.l	#$2A,D1
				rts
F				move.l	#$5E,D1
				rts
				
;(A6) should contain the # of ms delay

CALCULATE_DELAY
				move.l	A6,-(A7)
				move.l	D0,-(A7)
				move.l	#18000,D0
				mulu.l	(A6),D0			; delay of 1ms*(A6)
DELAYTIME		subq.l	#01,D0			; loop appropriate times to create a delay
				cmp.l	#0,D0
				beq		DELAYTIME
				move.l	(A7)+,D0
				move.l	(A7)+,A6
				rts