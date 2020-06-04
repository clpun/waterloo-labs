;;;;;;;;;;;;;Handle invalid selections;;;;;;;;;;;
SELECTION_INVALID
	move.l		A1,-(A7)
	lea			INVALID,A1
	bsr			out_string
	bsr			out_crlf
	move.l		(A7)+,A1
	rts
