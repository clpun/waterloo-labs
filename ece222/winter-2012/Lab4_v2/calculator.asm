calculator ; choice 3 subroutine
				; Display "Enter a number from 0 to 9999:"
				lea		PROMPT1,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the first string
				lea		BUFFER,A1 	
				bsr.w	in_string_keypad 
				bsr.w	out_crlf 
				bsr		DEC2BIN ;turns ascii to binary
				
				move.l	D3, D1 ;moves first number to D1
				; Display "Enter a number from 0 to 9999:"
				lea		PROMPT1,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the second string
				lea		BUFFER,A1 	
				bsr.w	in_string_keypad
				bsr.w	out_crlf 
				bsr		DEC2BIN ;turns ascii to binary
				
				move.l	D3, D2 ;moves second number to D2
				; Get the third string, the operator
				lea		PROMPT2,A1
				bsr.w	out_string 
				bsr.w	out_crlf
				lea		BUFFER,A1 			
				bsr.w	in_string_keypad 	
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
				
exit_loop		lea		PROMPT5,A1 ; Ask user if they want to exit the calculator mode
				bsr.w	out_string 
				bsr.w	out_crlf
				; Get the string
				lea		BUFFER,A1 	
				bsr.w	in_string_keypad 
				bsr.w	out_crlf 
				
				move.b	(A1),D7
				; if "0" is pressed, goes back to menu
				cmp.l	#$0030,D7
				beq		menu
				; if "1" is pressed, stay in calculator mode
				cmp.l	#$0031,D7
				beq		calculator
				
ADD_OPERATION ; Results will be stored to D6
				move.l	D1,-(A7) ; Push
				move.l	D2,-(A7) ; Push
				move.l	A1,-(A7) ; Push
				clr		D6
				add.l	D1,D2 ; Perform addition
				move.l	D2,D6 ; Store answer in D6
				bsr		BIN2DEC ; Turn the answer to ascii character
				bsr		out_string ; Output the answer
				bsr		out_crlf ; Goes to newline
				move.l	(A7)+,A1 ; Pop
				move.l	(A7)+,D2 ; Pop
				move.l	(A7)+,D1; Pop
				bra		exit_loop ; have to make exit_loop
				
SUBTRACT_OPERATION ; Results will be stored to D6
				move.l	D1,-(A7) ; Push
				move.l	D2,-(A7) ; Push
				move.l	A1,-(A7) ; Push
				clr		D6
				cmp.l	D1,D2 ; Check to see if the second number is larger than the first number
				bgt		negative_sub ; branch to negative_sub if yes
				
				sub.l	D2,D1 ; Normal subtractions
				move.l	D1,D6 ; Perform subtraction
				bsr		BIN2DEC ; Turn answer into ascii character
				bsr		out_string ; Output the answer
				bsr		out_crlf ; Goes to newline
				move.l	(A7)+,A1 ; Pop
				move.l	(A7)+,D2 ; Pop
				move.l	(A7)+,D1 ; Pop
				bra		exit_loop
				
negative_sub	sub.l	D1,D2 ; Do negative subtractions
				move.l	D2,D6 ; Perform subtraction
				bsr		BIN2DEC ; Turn answer into ascii character
				move.b	#$2D,-(A1) ; Prepend a negative sign in front of the answer
				bsr		out_string ; Output the answer
				bsr		out_crlf ; Goes to newline
				move.l	(A7)+,A1 ; Pop
				move.l	(A7)+,D2 ; Pop
				move.l	(A7)+,D1 ; Pop
				bra		exit_loop
				
MULTIPLY_OPERATION ; to be modified, results will be stored to D6
				move.l	D1,-(A7) ; Push
				move.l	D2,-(A7) ; Push
				move.l	A1,-(A7) ; Push
				clr		D6
				mulu.l	D1,D2 ; Perform multiplication
				move.l	D2,D6 ; Anwswer is stored into D6
				bsr		BIN2DEC ; Turn answer into ascii character
				bsr		out_string ; Output the answer
				bsr		out_crlf ; Goes to newline
				move.l	(A7)+,A1 ; Pop
				move.l	(A7)+,D2 ; Pop
				move.l	(A7)+,D1 ; Pop
				bra		exit_loop
				
POWER_OPERATION ; Results will be stored to D6
				mulu.l	D1,D1 ; Perform multiplication
				bsr		SUBTRACT_OPERATION ; Do subtraction