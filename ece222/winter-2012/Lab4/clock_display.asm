CLOCK_DISPLAY_MODE
	movea.l		#TIMER_UPDATED,A1
	move.l		(A1),D0
	cmp.l		#$0,D0
	bne			NORMAL_OPERATION
	lea			TIMER_NOT_SET,A1
	bsr			out_string
	bsr			out_crlf
	bra			EXIT_CLOCK_MODE
	
NORMAL_OPERATION
	lea			SELECTION2_MSG,A1
	bsr			out_string
	clr.l		D2
	lea			KEY_READY,A1
	move.l		D2,(A1)
	
DISPLAY_CLOCK
	lea			KEY_READY,A1
	move.l		(A1),D2
	cmp.l		#$72,D2
	beq			CHECK_HOTKEYS
	clr.l		D2
	lea			TIMER_UPDATED,A1
	move.l		(A1),D0
	cmp.l		#$72,D0
	beq			UPDATE_CLOCK
	bra			DISPLAY_CLOCK

BACK_TO_MAIN_MENU
	lea			TIMER_UPDATED,A1
	move.l		#$72,(A1)
	move.w		#$2000,SR
EXIT_CLOCK_MODE
	rts

UPDATE_CLOCK
	; to be added...

CHECK_HOTKEYS
	cmp.l		#$70,D1
	beq			PAUSE	; P is pressed, Pause time in subroutine
	cmp.l		#$72,D1
	beq			RESET
	cmp.l		#CR,D1
	beq			BACK_TO_MAIN_MENU	; ENTER is pressed, return to main menu
	clr.l		D2	; clear flag - keyboard press has been serviced
	lea			KEY_READY,A1
	move.l		D2,(A1)
	bra			DISPLAY_CLOCK
PAUSE
	clr.l		D1
	move.w		#$2500,SR	; mask timer - Interrupt Priority Mask = 5
WAIT_FOR_S_ENT
	cmp.l		#CR,D1
	beq			BACK_TO_MAIN_MENU	; ENTER is pressed, return to main menu 
	cmp.l		#$73,D1
	bne			WAIT_FOR_S_ENT	; S is pressed, resume clock
	move.w		#$2000,SR		; unmask timer - Interrupt Priority Mask = 0 (allow time to increment)
	clr.l		D2				; clear flag - keyboard press has been serviced
	lea			KEY_READY,A1
	move.l		D2,(A1)
	bra			DISPLAY_CLOCK
RESET
	lea			HOURS,A1
	move.l		#$31310000,(A1)	; move 11 into HOURS (ASCII)
	lea			MINUTES,A1
	move.l		#$35390000,(A1)	; move 59 into MINUTES (ASCII)
	lea			SECONDS,A1
	move.l		#$35350000,(A1)	; move 55 into SECONDS (ASCII)
	clr.l		D2	; clear flag - keyboard press has been serviced
	lea			KEY_READY,A1
	move.l		D2,(A1)
	bra			UPDATE_CLOCK