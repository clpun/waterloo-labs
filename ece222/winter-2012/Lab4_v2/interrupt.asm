******************************************************
**************Interrupt Service Routines**************
******************************************************

; Keyboard interrupt service routine
; D1 will contain the key pressed
; D7 will be set to 0x31 to indicate keyboard ISR was called
KEYBOARD_ISR
	clr.l		D1
	move.b		URB0,D1	; record key press into D1
 	and.l 		#$7F,D1
	move.b		#$31,D7	; set flag
	rte	

; Timer interrupt service routine (called every 1s)
; TIMER_SET be set to 0x31 to indicate timer ISR was called
; HOURS, MINUTES, SECONDS will contain the updated time
TIMER_ISR
	move.l		A1,-(A7)	; push
	move.l		A2,-(A7)	; push
	move.l		D2,-(A7)	; push
	move.l		D3,-(A7)	; push
	move.l		D4,-(A7)	; push
	move.l		D5,-(A7)	; push
	move.l		D6,-(A7)	; push

	clr.l		D2
	move.b		#$02,D2		; clear timer interrupt condition
	move.b		D2,TER0
	
	clr.l		D2
; store seconds into D5 in BINARY
	lea			SECONDS,A1
	bsr			DEC2BIN
	move.l		D3,D5		; D5 now contains seconds in BINARY
	
; store seconds into D4 in BINARY
	lea			MINUTES,A1
	bsr			DEC2BIN
	move.l		D3,D4		; D4 now contains minutes in BINARY
	
; store seconds into D3 in BINARY
	lea			HOURS,A1
	bsr			DEC2BIN		; We have D3 be hours, D4 be minutes, D5 be seconds in BINARY
	
; increment seconds by 1
	add.l		#01,D5		; Add 1 to seconds
	cmp.l		#060,D5		; check if seconds is 60. if yes, proceed to ROLLOVER_CHECK.
	blt			UPDATE_TIME
	bsr			ROLLOVER_CHECK
	
UPDATE_TIME
; store the updated hours back into HOURS
	lea			HOURS,A1
	move.l		D3,D6
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9. 
	bgt			HOURS_READY
	move.b		#$30,(A1)+	; prepend the 0 in ASCII (0x30)
HOURS_READY
	lea			ANSWER,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; HOURS now contains updated hours
	
; store the updated hours back into MINUTES
	lea			MINUTES,A1
	move.l		D4,D6
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9.
	bgt			MINUTES_READY
	move.b		#$30,(A1)+	; add the 0 in ASCII (0x30)
MINUTES_READY
	lea			ANSWER,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; MINUTES now contains updated hours

; store the updated hours back into SECONDS
	lea			SECONDS,A1
	move.l		D5,D6
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9.
	bgt			SECONDS_READY
	move.b		#$30,(A1)+	; add the 0 in ASCII (0x30)
SECONDS_READY
	lea			ANSWER,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; SECONDS now contains updated hours
	
	lea			TIMER_SET,A1	; set TIMER flag to be 0x31 to indicate completion of timer ISR
	move.l		#$31,(A1)
	
	move.l		(A7)+,D6	; pop
	move.l		(A7)+,D5
	move.l		(A7)+,D4
	move.l		(A7)+,D3
	move.l		(A7)+,D2
	move.l		(A7)+,A2
	move.l		(A7)+,A1
	rte

ROLLOVER_CHECK
	move.l		#0,D5			; set seconds to 0
	add.l		#01,D4			; increment minutes by 1
	cmp.l		#060,D4			; check if minutes needs to rollover
	blt			EXIT_ROLLOVER_CHECK	; if the minutes is not 60, return from subroutine
	move.l		#0,D4			; set minutes to 0
	add.l		#01,D3			; increment hours by 1
	cmp.l		#012,D3			; check if hours needs to rollover
	blt			EXIT_ROLLOVER_CHECK	; if the hours is not 12, return from subroutine
	move.l		#0,D3			; set hours, minutes and seconds to be 0
	move.l		#0,D4
	move.l		#0,D5 
EXIT_ROLLOVER_CHECK
	rts