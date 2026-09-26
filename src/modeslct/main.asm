#import "../common/const.asm"
#import "segdefs.asm"

.segment UtilityRoutines
#import "../common/disk.asm"

.segment BasicUpstart
:BasicUpstart(main) 

.segment Main
main:

	// Set the game mode to mode 0:
	lda #GAME_MODE_MULTIPLES
	sta UMEM_GAME_MODE_ADDR

	// Set the mode number string:
	lda #$30
	clc
	adc UMEM_GAME_MODE_ADDR
	sta String_ModeNumberString

	// Load the game executable
	lda #<String_DatModeFilenamePrefix
	sta MMEM_ZERO_PAGE
	lda #>String_DatModeFilenamePrefix
	sta MMEM_ZERO_PAGE + 1
	lda #$08
	sta MMEM_ZERO_PAGE + 2
	jsr load_file	

	// Load the game data:
	lda #<String_GameExecutable
	sta MMEM_ZERO_PAGE
	lda #>String_GameExecutable
	sta MMEM_ZERO_PAGE + 1
	lda #$08		// Hard-code device 8 for now; TODO - dynamic device number detection
	sta MMEM_ZERO_PAGE + 2

	// Overwrite the end of the BASIC upstart so that once the game code is loaded, it will launch:
	lda #$20
	sta UMEM_MAIN_CODE_ADDRESS - 3
	lda #<load_file 
	sta UMEM_MAIN_CODE_ADDRESS - 2
	lda #>load_file
	sta UMEM_MAIN_CODE_ADDRESS - 1

	jmp UMEM_MAIN_CODE_ADDRESS - 3


String_DatModeFilenamePrefix: 
.text "DATMODE"

String_ModeNumberString: 
.text "0"

.byte $00

String_GameExecutable: 
.text "GAME"

.byte $00