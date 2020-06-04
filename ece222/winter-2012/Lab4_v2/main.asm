		cpu		5307
		include coldfire.asm

PROGRAM 	equ 		$10200000	; Assign address information for label PROGRAM
OPERAND 	equ 		$10210000	; Assign address information for label OPERAND
ANSWER		equ			$10214000	; storing output of BIN2DEC
DELAY_TIME	equ			$10215000	; delay stored here
HOURS		equ			$10216000	; storing HOURS
MINUTES		equ			$10217000	; storing MINUTES
SECONDS		equ			$10218000	; storing SECONDS
TIMER_SET	equ			$10219000	; flag for timer interrupt (0x31 after ISR, 0x00 after serviced)
SELECTION	equ			$10220000	; storing menu selection
BUFFER 		equ 		$10230000	; BUFFER refers to address location $1023000	
CR 			equ 		$0D			; CR (carriage return), cursor at beginning of line
LF 			equ 		$0A			; LF (line feed), cursor moves to a new line

*******************************************************************************************
 move.b	#%0101,D7
 move.b	D7,UCR0 ; Enable receiver and transmitter enable for serial interfacing
 clr	D7
*******************************************************************************************

				org			OPERAND

MENU_PROMPT
				dc.b		"Select a menu item (0 to 3)",CR,LF
				dc.b		"0. Return to Monitor",CR,LF
				dc.b		"1. Clock Display",CR,LF
				dc.b		"2. Enter Clock Mode",CR,LF
				dc.b		"3. Enter Calculator Mode",CR,LF,0

INVALID			dc.b		"Invalid selection.",CR,LF,0
TIMER_OUTRANGE	dc.b		"Timer out of range. Your time has to be between 00:00:00 and 11:59:59",CR,LF,0
CLOCK_DISPLAY	dc.b		"Clock Display",CR,LF,0
NO_TIME_SET		dc.b		"You have not set the time yet. Please go to selection 2 to set the clock.",0
CLOCK_MODE		dc.b		"Clock Mode...",CR,LF,0
TIMER_PROMPT	dc.b		"Please set the time( HH:MM:SS ):",CR,LF,0
PROMPT1			dc.b		"Enter a number from 0 to 9999:",0
PROMPT2			dc.b		"Enter an operator (+,-,*,^):",0
PROMPT3			dc.b		"Overflow/Underflow error",0
PROMPT4			dc.b		"Invalid input",0 	
PROMPT5			dc.b		"Enter 0 to exit, enter 1 to stay in calculator mode.",0

				org			PROGRAM
				lea			BUFFER,A7
				jmp			START

				include		input.asm
				include		output.asm
				include		error.asm
				include		selection0.asm
				include		selection1.asm
				include		selection2.asm
				include		calculator.asm
				include		conversion.asm
				include		interrupt.asm
				
START
	lea			TIMER_SET,A1	; Clear timer flag
	clr.l		(A1)

;;;;;;;;;;;;;;;;;;;INTERRUPTS CONFIGURATION;;;;;;;;;;;;;;;;;;;
	move.l		#$0003ED7E,D0	; enable interrupts
	move.l		D0,IMR
	
	move.w		#$2000,SR		; Set SR to supervisory mode and interrupt mask priority to 0(bits 8-10)		
;;;;;;;;;;;;;;KEYBOARD INTERRUPTS CONFIGURATION;;;;;;;;;;;;;;
	lea			ISR_lvl_6,A1	; store keyboard ISR address into autovector table(lv 6)
	move.l		#KEYBOARD_ISR,(A1)
	
	move.b		#$9A,D0			; set interrupt level = 6, priority = 2 for UART0
	move.b		D0,ICR4
	
	move.b		#$02,D0			; set RxRDY in UIMR0
	move.b		D0,UIMR0
	
	move.b		#$05,D0			; enable receiver in UCR0
	move.b		D0,UCR0
	
;;;;;;;;;;;;;;;;Main Menu;;;;;;;;;;;;;;;;
menu
	lea			MENU_PROMPT,A1	; print main menu	
	bsr			out_string
* Ask user for menu selection
	clr.l		D7
flag_loop
	cmp.l		#$31,D7			; if a key is pressed, D7 would contain 0x31
	bne			flag_loop		; loop until keyboard interrupt flag is set
	bsr			out_char		; display the selection
	bsr			out_crlf
* User enters menu selection 0
input_0
	cmp.l		#$30,D1			; check if user entered '0'
	bne			input_1			; check next input if not '0'
	bra			SELECTION_0		; if '0', return to monitor
* User enters menu selection 1
input_1
	cmp.l		#$31,D1			; check if user entered '1'
	bne			input_2			; check next input if not '1'
	bsr			SELECTION_1		; if '1', enter clock display
	bra			menu			; return to main menu after subroutine
* User entered menu selection 2
input_2
	cmp.l		#$32,D1			; check if user entered '2'
	bne			input_3			; check next input if not '2'
	bsr			SELECTION_2		; if '2', enter clock mode (to set time)
	bra			menu			; return to main menu after subroutine
* User entered menu selection 3
input_3
	cmp.l		#$33,D1			; check 3
	bne			input_error		; show error if input is something other than 0, 1, 2 or 3
	bsr			calculator		; if 3, enter calculator
	bra			menu			; return to main menu after subroutine
* User entered invalid menu selection
input_error
	bsr			out_crlf
	jsr			SELECTION_INVALID	; handle error
	bra			menu				; return to main menu after subroutine
;;;;;;;;;;;;;;;;Main Menu;;;;;;;;;;;;;;;;
	end
	