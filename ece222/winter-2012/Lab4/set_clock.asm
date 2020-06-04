; display welcome message
; ask user to enter time in (HH:MM:SS)
; ask for hours. loop
	; wait for keyboard ISR flag
	; display typed character on screen
	; save character into HOURS
	; check for the ':' entered to denote end of HOURS. loop until ':' is entered
	; add null to denote end of HOURS string
; ask for mins. loop
	; wait for keyboard ISR flag
	; display typed character on screen
	; save character into MINUTES
	; check for the ':' entered to denote end of HOURS. loop until ':' is entered
	; add null to denote end of MINUTES string
; ask for SECONDS. loop
	; wait for keyboard ISR flag
	; display typed character on screen
	; save character into SECONDS
	; check for the #CR entered to denote end of SECONDS. loop until #CR is entered
	; add null to denote end of MINUTES string
; error checkings...

; timer interrupts config. only once