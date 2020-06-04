		CPU	5307
		; include q:\eng\ece\Coldfire\coldfire.asm

PROGRAM         equ     $10200000 ; Assign address information for label PROGRAM
OPERAND         equ     $10210000 ; Assign address information for label OPERAND
BUFFER          equ     $10220000 ; Assign address information for label BUFFER
STACK           equ     $10230000 ; Assign address information for label STACK

; CR and LF are used by the terminal emulator software to produce a new line
CR              equ     $0D ; Returns the cursor to the beginning of the line
LF              equ     $0A ; Moves the cursor to the next line

                org     OPERAND


PROMPT          dc.b "Main Menu:",CR,LF ; menu message
				dc.b "0. Return to Monitor",CR,LF ; menu message
				dc.b "1. Clock Display",CR,LF ; menu message
				dc.b "2. Enter Clock Mode",CR,LF ; menu message
				dc.b "3. Enter Calculator Mode",0 ; menu message

PROMPT1			dc.b "Enter a number from 0 to 9999:",0 	; message when user is supposed to enter a number
PROMPT2			dc.b "Enter an operator (+,-,*,^):",0 		; message when user is supposed to enter an operator
PROMPT3			dc.b "Overflow error",0						; overflow message
PROMPT4			dc.b "Invalid input",0 						; message given when input is invalid
PROMPT5			dc.b "Do you want to exit the program? Press enter if yes.",0								; message when calculator prompts the user to exit
					
				org     PROGRAM
				lea     STACK,a7
				jmp     start 
					
;;;;;;;;;;;;;;Taken from Lab 1;;;;;;;;;;;;;;
in_string
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
				add.l   #1, D2
				bra     in_string_loop
					
exit_in_string	tst.l   D2
				beq     in_string_loop
				move.b	#0,(A1)
				
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				rts
					
out_crlf ; go to newline subroutine
				move.l   D1,-(A7)
				move     #CR,D1
				jsr      out_char 
				move     #LF,D1 
				jsr      out_char 
				move.l   (A7)+,D1 
				rts 
					
out_string ; output all the characters
				move.l  D1,-(A7) 
				move.l	A1,-(A7) 
out_next_char
				move.b   (A1)+,D1 
				jsr      out_char 
				tst.b    D1 
				bne      out_next_char 
				move.l   (A7)+,A1 					
				move.l   (A7)+,D1 
				rts
					
out_char ; display a character onto monitor
				move.l  D0,-(A7)
				move.l  #$0013,d0 
				TRAP    #15
				move.l  (A7)+,D0 
				rts
							
in_char	; Takes input from user
				move.l  D0,-(A7) 
				move.l  #$0010,d0 
				TRAP    #15 
				and.l   #$7F,d1 
				bsr     out_char
					
				move.l  (A7)+,D0
				rts 
;;;;;;;;;;;;;;Taken from Lab 1;;;;;;;;;;;;;;

;;;;;;;;;;;;;;Conversion;;;;;;;;;;;;;;;;
; Note: Have to check for overflow/underflow too
BIN2DEC
				; push stuff into stack
				MOVE.L 		A2,-(A7)
				MOVE.L 		A1,-(A7)
				MOVE.L 		A0,-(A7)
				MOVE.L 		D6,-(A7)		; D6 contains binary result
				lea			BUFFER,A1
				MOVE.L		A1,A0			; points to original string
				
ASCII_DEC		DIVU.W		#$000A,D6		; divide binary by 10
				SWAP		D6				; move remainder to lower side of D6
				ADD.L		#$0030,D6		; add 0x30 to change to ASCII
				MOVE.B		D6,(A1)+		; move remainder (byte) into A1
				SWAP		D6				; move quotient to lower side of D6
				AND.L		#$0000FFFF,D6	; clear upper side of D2, leaving only quotient
				TST.B		D6
				BNE			ASCII_DEC		; repeat until quotient is 0
				MOVE.B		#0,(A1)			; add null sign; A1 points to NULL after normal string
				MOVEA.L 	#BUFFER+1024,A2	; ANSWER points to start of reversed string, A2 points to start of reversed string
				
REVERSE_LOOP	MOVE.B		-(A1),(A2)+		; set last letter as first letter of reversed string
				CMPA.L		A1,A0			; check if we have moved through all characters
				BNE			REVERSE_LOOP	; loop until we go through all characters
				MOVE.L 		#0,(A2)			; place 0 to represent end/null
				; pop stuff out of the stack
				MOVE.L		(A7)+,D6
				MOVE.L		(A7)+,A0
				;MOVE.L		(A7)+,A1
				MOVEA.L 	#BUFFER+1024,A1
				MOVE.L		(A7)+,A2
				RTS

DEC2BIN	; Important Note: D3 would be holding the encoded binary
				; push stuff into stack
				MOVE.L	A1,-(A7)	; points to character
				MOVE.L	D5,-(A7)	; D5 contains ascii string
				CLR.L	D3			; clear D3

ASCII_BIN		CLR.L	D5			; clear D5
				MOVE.B	(A1)+,D5	; take an ascii character
				SUB.L	#$0030,D5	; subtract 0x30 to convert to decimal
				MULU.W	#010,D3		; multiply current encoded binary by 10
				ADD.L	D5,D3		; add digit to current encoded binary
				TST.B	(A1)		; test to see if A1 has reached null yet
				BNE		ASCII_BIN	; repeat for every character, A1 should point to null at the end
				MOVE.L	(A7)+,D5	; pop
				MOVE.L	(A7)+,A1	; pop
				RTS							
;;;;;;;;;;;;;;Conversion;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;Calculator;;;;;;;;;;;;;;;;
calculator ; choice 3 subroutine
				; Display "Enter a number from 0 to 9999:"
				lea		PROMPT1,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the first string
				lea		BUFFER,A1 	
				bsr.w	in_string 
				bsr.w	out_crlf 
				bsr		DEC2BIN ;turns ascii to binary
				
				; if "enter" is pressed, goes back to menu
				cmp.l	#CR,D3
				beq		menu
				cmp.l	#$LF,D3
				beq		menu
				
				move.l	D3, D1 ;moves first number to D1
				; Display "Enter a number from 0 to 9999:"
				lea		PROMPT1,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the second string
				lea		BUFFER,A1 	
				bsr.w	in_string 
				bsr.w	out_crlf 
				bsr		DEC2BIN ;turns ascii to binary
				
				; if "enter" is pressed, goes back to menu
				cmp.l	#CR,D3
				beq		menu
				cmp.l	#$LF,D3
				beq		menu
				
				move.l	D3, D2 ;moves second number to D2
				; Get the third string, the operator
				lea		PROMPT2,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				lea		BUFFER,A1 			
				bsr.w	in_string 	
				bsr.w	out_crlf 
				bsr		DEC2BIN ;turns ascii to binary
				
				; if "enter" is pressed, goes back to menu
				cmp.l	#CR,D3
				beq		menu
				cmp.l	#$LF,D3
				beq		menu
				
				move.b	D3,D4 ; moves operator to D4
				; checks for which operator D4 is
				; ascii character reference: http://www.pcguide.com/res/tablesASCII-c.html
				; ADD_OPERATION
				cmp.l	#$2B,D4
				beq		ADD_OPERATION
				; SUBTRACT_OPERATION
				cmp.l	#$2D,D4
				beq		SUBTRACT_OPERATION
				; MULTIPLY_OPERATION
				cmp.l	#$2A,D4
				beq		MULTIPLY_OPERATION
				; POWER_OPERATION
				cmp.l	#$5E,D4
				beq		POWER_OPERATION
				; ERROR
				lea		PROMPT4,A1 ; gives an error message
				bsr.w	out_string 
				bsr.w	out_crlf
				
				bra		calculator ; returns to beginning
				; should handle exit after this...to be added
exit_loop		lea		PROMPT5,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the string
				lea		BUFFER,A1 	
				bsr.w	in_string 
				bsr.w	out_crlf 
				bsr		DEC2BIN ; turns ascii to binary
				; if "enter" is pressed, goes back to menu
				cmp.l	#CR,D3
				beq		menu
				cmp.l	#$LF,D3
				beq		menu
				; if not
				bra		calculator
				
ADD_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				clr		D6
				add.l	D1,D2
				move.l	D2,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop ; have to make exit_loop
				
SUBTRACT_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				clr		D6
				sub.l	D2,D1
				move.l	D1,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop ; have to make exit_loop
				
MULTIPLY_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				clr		D6
				muls.l	D1,D2
				move.l	D2,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop
				
POWER_OPERATION ; to be modified, results will be stored to D6
				muls.l	D1,D1
				bsr		SUBTRACT_OPERATION
				
INVALID_CHOICE	; for choice 1 & 2
				move.l		A1,-(A7)
				lea			PROMPT4,A1
				bsr			out_string
				bsr			out_crlf
				move.l		(A7)+,A1
				rts
;;;;;;;;;;;;;;Calculator;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;Main Menu;;;;;;;;;;;;;;;;;
start			; Important Notes: D5 will store ascii string		
menu			lea PROMPT,A1 ; point to start of messages
				bsr.w out_string ; print messages using out_string
				bsr.w out_crlf ; go to new line using out_crlf
				lea BUFFER,A1 ; point to start of buffer
				bsr.w in_string ; read string and add a trailing NULL
				bsr.w out_crlf ; go to next line
				move.b (A1), D5 ;moves ascii string to D5
				
				cmp.l #$33,D5 ;checks if D5 is equal to 3, branch to calculator mode
				beq calculator
				
				cmp.l #$31,D5 ;checks if D5 is equal to 1
				beq INVALID_CHOICE ; output error msg
				
				cmp.l #$32,D5 ;checks if D5 is equal to 2
				beq INVALID_CHOICE ; output error msg
				
				cmp.l #$30,D5 ;checks if D5 is equal to 0, exit program if yes
				bne menu ; goes back to menu if no
				trap #15
				end
					
		
					
	
	
	
	
	
	
	
	
	
	
	
