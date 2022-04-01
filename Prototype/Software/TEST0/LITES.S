; lites.s
;
	.module	lites
.include "mark4.inc"

	.area	_CODE

_lite_on::
	ld	a,#0x04		; SD_CS
	out	(dev_sd),a
	ret

_lite_off::
	ld	a,#0x00		; no SD_CS
	out	(dev_sd),a
	ret
