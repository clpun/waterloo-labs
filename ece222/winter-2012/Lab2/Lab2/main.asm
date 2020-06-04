		CPU	5307

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
PROMPT3			dc.b "Overflow/Underflow error",0						; overflow message
PROMPT4			dc.b "Invalid input",0 						; message given when input is invalid
PROMPT5			dc.b "Do you want to exit the program? y/n",0								; message when calculator prompts the user to exit
					
				org     PROGRAM
				lea     STACK,a7
				jmp     start 

				include	input.asm
				include output.asm
				include conversion.asm

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
				
				move.l	D3, D2 ;moves second number to D2
				; Get the third string, the operator
				lea		PROMPT2,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				lea		BUFFER,A1 			
				bsr.w	in_string 	
				bsr.w	out_crlf 
				
				move.b	(A1),D4 ; moves operator to D4
				; checks for which operator D4 is
				; ascii character reference: http://www.pcguide.com/res/tablesASCII-c.html
				; ADD_OPERATION
				cmp.l	#$002B,D4
				beq		ADD_OPERATION
				; SUBTRACT_OPERATION
				cmp.l	#$002D,D4
				beq		SUBTRACT_OPERATION
				; MULTIPLY_OPERATION
				cmp.l	#$002A,D4
				beq		MULTIPLY_OPERATION
				; POWER_OPERATION
				cmp.l	#$005E,D4
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
				; bsr		DEC2BIN ; turns ascii to binary
				move.b	(A1),D7
				; if "enter" is pressed, goes back to menu
				cmp.l	#$0079,D7
				beq		menu
				
				cmp.l	#$006E,D7
				beq		calculator
				
ADD_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				move.l	A1,-(A7)
				clr		D6
				add.l	D1,D2
				move.l	D2,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop ; have to make exit_loop
				
SUBTRACT_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				move.l	A1,-(A7)
				clr		D6
				cmp.l	D1,D2
				bgt		negative_sub
				
				sub.l	D2,D1
				move.l	D1,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop
				
negative_sub	sub.l	D1,D2
				move.l	D2,D6
				bsr		BIN2DEC
				move.b	#$2D,-(A1)
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				bra		exit_loop
				
MULTIPLY_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7)
				move.l	D2,-(A7)
				move.l	A1,-(A7)
				clr		D6
				muls.l	D1,D2
				move.l	D2,D6
				bsr		BIN2DEC
				bsr		out_string
				bsr		out_crlf
				move.l	(A7)+,A1
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
				bra			menu
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