;;;;;;;;;;;;;;Overflow/Underflow;;;;;;;;;;;;;
handle_overflow		
				move.l		A1,-(A7)
				lea			PROMPT3,A1
				bsr			out_string
				bsr			out_crlf
				move.l		(A7)+,A1
				bra			calculator
				
;;;;;;;;;;;;;;Overflow/Underflow;;;;;;;;;;;;;

BIN2DEC
				cmp.l		#9999,D6
				bgt			handle_overflow
				MOVE.L 		A2,-(A7)
				MOVE.L 		A0,-(A7)
				MOVE.L 		D6,-(A7)		; D6 contains binary result
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
				MOVEA.L 	#BUFFER+1024,A2	; A2 points to start of reversed string
				MOVEA.L 	A2,A3
				
REVERSE_LOOP	MOVE.B		-(A1),(A2)+		; set last letter as first letter of reversed string
				CMPA.L		A1,A0			; check if we have moved through all characters
				BNE			REVERSE_LOOP	; loop until we go through all characters
				MOVE.L 		#0,(A2)			; place 0 to represent end/null
				; pop stuff out of the stack
				MOVE.L		(A7)+,D6
				MOVE.L		(A7)+,A0
				MOVEA.L		A3,A1
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