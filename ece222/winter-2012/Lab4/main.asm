		cpu	5307
		include N:\ece222\Lab3\coldfire.asm
		
PROGRAM         equ     $10200000 ; Assign address information for label PROGRAM
OPERAND         equ     $10210000 ; Assign address information for label OPERAND
DELAY_TIME		equ		$10211000 ; Assign address information for label DELAY_TIME
HOURS			equ		$10212000
MINUTES			equ		$10213000
SECONDS			equ		$10214000
KEY_READY		equ		$10215000
TIMER_UPDATED	equ		$10216000
BUFFER          equ     $10220000 ; Assign address information for label BUFFER
STACK           equ     $10230000 ; Assign address information for label STACK

; CR and LF are used by the terminal emulator software to produce a new line
CR              equ     $0D ; Returns the cursor to the beginning of the line
LF              equ     $0A ; Moves the cursor to the next line
*******************************************************************************************
 move.b	#%0101,D7
 move.b	D7,UCR0 ; Enable receiver and transmitter enable for serial interfacing
 clr	D7
*******************************************************************************************

                org     OPERAND

PROMPT          dc.b "Main Menu:",CR,LF ; menu message
				dc.b "0. Return to Monitor",CR,LF ; menu message
				dc.b "1. Clock Display",CR,LF ; menu message
				dc.b "2. Enter Clock Mode",CR,LF ; menu message
				dc.b "3. Enter Calculator Mode",0 ; menu message

PROMPT1			dc.b "Enter a number from 0 to 9999:",0 	; message when user is supposed to enter a number
PROMPT2			dc.b "Enter an operator (+,-,*,^):",0 		; message when user is supposed to enter an operator
PROMPT3			dc.b "Overflow/Underflow error",0			; overflow/underflow message
PROMPT4			dc.b "Invalid input",0 						; message given when input is invalid
PROMPT5			dc.b "Enter 0 to exit, enter 1 to stay in calculator mode.",0	; message when calculator prompts the user to exit
SELECTION2_MSG	dc.b "Clock Mode.",0
TIMER_NOT_SET	dc.b "Your timer is not set yet. Please go to selection 2 to set the clock.",0
					
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
				
INVALID_CHOICE	; for choice 1 & 2
				move.l		A1,-(A7)
				lea			PROMPT4,A1 ; Output error message
				bsr			out_string
				bsr			out_crlf
				move.l		(A7)+,A1
				bra			menu ; Goes back to main menu
;;;;;;;;;;;;;;Calculator;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;Main Menu;;;;;;;;;;;;;;;;;
start			; Important Notes: D5 will store ascii string	
				lea	TIMER_UPDATED,A1
				clr.l A1

* INTERRUPTS CONFIGURATION
	move.l		#$0003ED7E,D0	; enable interrupts
	move.l		D0,IMR
	move.w		#$2000,SR		; Supervisor mode and Interrupt Priority Mask = 0		

* KEYBOARD INTERRUPTS CONFIGURATION
	lea			ISR_lvl_6,A1	; place keyboard ISR address into autovector table
	move.l		#KEYBOARD_ISR,(A1)
	
	move.b		#$9A,D0			; set interrupt level = 6, priority = 2 for UART0
	move.b		D0,ICR4
	
	move.b		#$02,D0			; set to 0x02 to enable receive interrupts, and disable transmit interrupts.
	move.b		D0,UIMR0
	
	move.b		#$05,D0			; enable receiver in UCR0
	move.b		D0,UCR0
				
menu			lea PROMPT,A1 ; point to start of messages
				bsr.w out_string ; print messages using out_string
				bsr.w out_crlf ; go to new line using out_crlf
flag_loop		lea KEY_READY,A1
				move.l (A1),D0
				cmp.l #$72,D0 ; 0x72 in keyboard flag means keyboard ISR serviced (button pressed)
				bne flag_loop ; loop until keyboard interrupt flag is set
				bsr out_char ; display user's menu selection
				bsr out_crlf
				
				cmp.l #$33,D1 ;checks if D1 is equal to 3, branch to calculator mode
				beq calculator
				
				cmp.l #$31,D1 ;checks if D1 is equal to 1
				beq INVALID_CHOICE ; output error msg
				
				cmp.l #$32,D1 ;checks if D1 is equal to 2
				beq INVALID_CHOICE ; output error msg
				
				cmp.l #$30,D1 ;checks if D1 is equal to 0, exit program if yes
				bne menu ; goes back to menu if no
				trap #15
				end