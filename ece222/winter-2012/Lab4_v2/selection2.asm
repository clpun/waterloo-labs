SELECTION_2
	move.l		A1,-(A7)	; push
	move.l		A2,-(A7)	; push
	move.l		D0,-(A7)	; push
	move.l		D7,-(A7)	; push
	move.l		D3,-(A7)	; push
	
SET_TIMER
	bsr			out_crlf
	lea			CLOCK_MODE,A1	; display "Clock Mode"
	bsr			out_string
	lea			TIMER_PROMPT,A1	; ask user to enter time in (HH:MM:SS)
	bsr			out_string
	
	lea			HOURS,A1
GET_HOURS
	clr.l		D7
hours_flag_loop
	cmp.l		#$31,D7
	bne			hours_flag_loop	; wait for keyboard ISR flag to be set
	bsr			out_char		; display typed character on screen
	move.b		D1,(A1)+		; save input into HOURS
	cmp.l		#$3A,D1			; wait for ':' to be entered
	bne			GET_HOURS
	move.b 		#0,-(A1)		; add null to denote end of HOURS string

	lea			MINUTES,A1
GET_MINUTES
	clr.l		D7
minutes_flag_loop
	cmp.l		#$31,D7
	bne			minutes_flag_loop	; wait for keyboard ISR flag to be set
	bsr			out_char		; display typed character on screen
	move.b		D1,(A1)+		; save input into MINUTES	
	cmp.l		#$3A,D1			; wait for ':' to be entered
	bne			GET_MINUTES
	move.b 		#0,-(A1)		; add null to denote end of MINUTES string
	
	lea			SECONDS,A1
GET_SECONDS
	clr.l		D7
seconds_flag_loop
	cmp.l		#$31,D7
	bne			seconds_flag_loop	; wait for keyboard ISR flag
	bsr			out_char		; display typed character on screen
	move.b		D1,(A1)+		; save input into SECONDS
	cmp.l		#CR,D1			; wait for 'CR' to be entered
	bne			GET_SECONDS
	move.b 		#0,-(A1)		; add null to denote end of SECONDS
	bsr			out_crlf	
	
;;;;;;;;;;;;;;Error checkings...;;;;;;;;;;;;;;
	lea			HOURS,A1
	bsr			DEC2BIN
	cmp.l		#011,D3
	bgt			TIMER_ERROR
	cmp.l		#0,D3			; check to see if hours is within the range
	blt			TIMER_ERROR		; if out of range, print error message and ask the user to set the timer again
	
	lea			MINUTES,A1
	bsr			DEC2BIN
	cmp.l		#059,D3
	bgt			TIMER_ERROR
	cmp.l		#0,D3			; check to see if minutes is within the range
	blt			TIMER_ERROR		; if out of range, print error message and ask the user to set the timer again
	
	lea			SECONDS,A1
	bsr			DEC2BIN
	cmp.l		#059,D3
	bgt			TIMER_ERROR
	cmp.l		#0,D3			; check to see if seconds is within the range
	blt			TIMER_ERROR		; if out of range, print error message and ask the user to set the timer again
	bsr			out_crlf
;;;;;;;;;;;;;;Error checkings...;;;;;;;;;;;;;;

;;;;;;;;;;;;;;TIMER INTERRUPTS CONFIGURATION;;;;;;;;;;;;;;

	lea			TIMER_SET,A2
	move.l		(A2),D3			; check to see if the configuration has been done or not
	cmp.l		#$FFFFFFFF,D3
	beq			EXIT_S2			; exit if the timer has already been configurated
	lea			ISR_lvl_5,A1	; place timer ISR address into autovector table(level 6)
	move.l		#TIMER_ISR,(A1)
	
	move.w		#$FF3D,D0		; enable timer (set ORI bit, prescaler, bus clock div 16)
	move.w		D0,TMR0
	
	move.w		#$2AEA,D0		; set reference value for timer, 255
	move.w		D0,TRR0
	
	move.b		#$02,D0			; clear event register for timer 0
	move.b		D0,TER0
	
	move.l		#$96,D0			; set interrupt level = 5, priority = 2 for timer 0
	move.b		D0,ICR1
	
	lea			TIMER_SET,A2
	move.l		#$FFFFFFFF,(A2)
	
EXIT_S2
	move.l		(A7)+,D3		; pop
	move.l		(A7)+,D7		; pop
	move.l		(A7)+,D0		; pop
	move.l		(A7)+,A2		; pop
	move.l		(A7)+,A1		; pop
	rts

;;;;;;;;;;;;;;;;;;;Handle out of range;;;;;;;;;;;;;;;;;;
TIMER_ERROR
	move.l		A1,-(A7)
	lea			TIMER_OUTRANGE,A1
	bsr			out_string
	bsr			out_crlf
	move.l		(A7)+,A1
	bra			SET_TIMER