;;;;;;;;;;;;;;;;;;;;;;clock display;;;;;;;;;;;;;;;;;;;;;;
SELECTION_1
	move.l		A1,-(A7)	; push
	move.l		D1,-(A7)	; push
	move.l		D0,-(A7)	; push
	move.l		D7,-(A7)	; push
	
	bsr			out_crlf
	lea			TIMER_SET,A1	; check to see if a time was set
	move.l		(A1),D0
	cmp.l		#0,D0
	bne			CLOCK_SET		; if time was set, continue to "Clock Display" mode
	lea			NO_TIME_SET,A1	; if time not set, give warning message and go back to main menu
	bsr			out_string
	bra			EXIT_S1			; return to main menu
	
	bsr			out_crlf
CLOCK_SET
	lea			CLOCK_DISPLAY,A1	; display clock mode message
	bsr			out_string

	clr.l		D7
DISPLAY_CLOCK
	cmp.l		#$31,D7			
	beq			CHECK_HOTKEYS	; check to see if a key is pressed
	lea			TIMER_SET,A1
	move.l		(A1),D0			; check to see if the time is updated
	cmp.l		#$31,D0
	beq			UPDATE_CLOCK	; reprint time if yes
	bra			DISPLAY_CLOCK	; keep looping...until user presses enter
CHECK_HOTKEYS
	cmp.l		#$70,D1
	beq			PAUSE			; P is pressed, pause time
	cmp.l		#$72,D1
	beq			RESET			; R is pressed, reset time
	cmp.l		#CR,D1
	beq			BACK_TO_MENU	; ENTER is pressed, return to main menu
	clr.l		D7				; clear flag to indicate that the keyboard has been serviced
	bra			DISPLAY_CLOCK

BACK_TO_MENU
	lea			TIMER_SET,A1
	move.l		#$31,(A1)
	move.w		#$2000,SR		; unmask timer
	
EXIT_S1
	bsr			out_crlf
	bsr			out_crlf
	
	move.l		(A7)+,D7		; pop
	move.l		(A7)+,D0		; pop
	move.l		(A7)+,D1		; pop
	move.l		(A7)+,A1		; pop
	rts
	
;;;;;;;;;;;;;;;;;;Update clock;;;;;;;;;;;;;;;;;;
UPDATE_CLOCK
	lea 		HOURS,A1
	bsr			out_string		; print HOURS
	move.b		#$3A,D1
	bsr			out_char		; print ':'
	lea 		MINUTES,A1
	bsr			out_string		; print MINUTES
	move.b		#$3A,D1
	bsr			out_char		; print ':'
	lea 		SECONDS,A1
	bsr			out_string		; print SECONDS
	move.b		#CR,D1			; go to new line
	bsr			out_char
	lea			TIMER_SET,A1
	move.l		#$0,(A1)		; set timer flag to 0 to indicate that timer has been serviced
	bra			DISPLAY_CLOCK
	
;;;;;;;;;;;;;;;;;;;;;Hotkey check;;;;;;;;;;;;;;;;;;;;;
PAUSE
	clr.l		D1
	move.w		#$2500,SR		; mask timer so that the timer stops incrementing
WAIT_START
	cmp.l		#CR,D1
	beq			BACK_TO_MENU	; if ENTER is pressed, return to main menu 
	cmp.l		#$73,D1
	bne			WAIT_START		; if S is pressed, start the clock again by unmasking it
	move.w		#$2000,SR
	clr.l		D7				; clear flag to indicate that the keyboard has been serviced
	bra			DISPLAY_CLOCK
	
RESET
	move.l		A1,-(A7)
	lea			HOURS,A1
	move.l		#$31310000,(A1)	; move 11 into HOURS
	lea			MINUTES,A1
	move.l		#$35390000,(A1)	; move 59 into MINUTES
	lea			SECONDS,A1
	move.l		#$35350000,(A1)	; move 55 into SECONDS
	clr.l		D7				; clear flag to indicate that the keyboard has been serviced
	move.l		(A7)+,A1
	bra			UPDATE_CLOCK