; literhyo
;
	.module	literhyo
.include "rhyophyre.inc"

	.area	_CODE

_lite_on::
	ld	a,#ACR_STATUS ; set the STATUS bit in the Aux Control Reg
	out	(dev_acr),a
	ret

_lite_off::
	ld	a,#0x00      ; clear the STATUS bit
	out	(dev_acr),a
	ret
