include "Interface.xc"

const $AACC_VERSION = "V1.0"

init
	; Initializes everything
	@Initialize_crafting()
	@Initialize_interface()
	print("Starting AACC " & $AACC_VERSION)
	
	
tick
	@Devices_tick()