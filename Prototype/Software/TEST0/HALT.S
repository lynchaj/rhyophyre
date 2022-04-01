start:
	ld	a,4	; CS
	out	($89),a

	halt
	jr start
	.end
