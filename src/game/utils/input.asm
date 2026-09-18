// =====================================================================================
// IS KEY PRESSED
// =====================================================================================
// - Sets accumulator to TRUE or FALSE
// =====================================================================================
.macro

is_key_pressed(key_code)
{
	jsr get_key_code
	cmp #key_code 					// Does the keycode match the requested value?
	beq key_is_pressed
	lda #FALSE 						// No match
	jmp macro_end

  key_is_pressed:
  	lda #TRUE 						// Match

  macro_end:
}
// =====================================================================================


// =====================================================================================
// GET KEY CODE
// =====================================================================================
// - Sets accumulator to current key code
// =====================================================================================
get_key_code:

	// Select the relevant keyboard row:
	lda #$EF
	sta $DC00 								// Disable all other keys except direction keys = row 4

	// Scan for J:
	lda #$02
	jsr read_matrix
	cmp #OFF
	beq key_j_pressed

	// Scan for K:
	lda #$05
	jsr read_matrix
	cmp #OFF
	beq key_k_pressed

	// Scan for M:
	lda #$04
	jsr read_matrix
	cmp #OFF
	beq key_m_pressed

	// Scan for I:
	lda #$01
	jsr read_matrix
	cmp #OFF
	beq key_i_pressed

	lda #$7F            					// Select row 7 to scan for spacebar
	sta $DC00

	// Scan for SPACE:
	lda #$04
	jsr read_matrix
	cmp #OFF
	beq key_space_pressed

	rts

  read_matrix:
	ldx #$02
	sta MMEM_ZERO_PAGE, x
	dex
	lda #$DC
	sta MMEM_ZERO_PAGE, x 
	lda #$01
	sta MMEM_ZERO_PAGE
	jsr get_bit	

	rts

  key_j_pressed:
  	lda #KEY_LEFT
  	rts

  key_k_pressed:
    lda #KEY_RIGHT
    rts

  key_i_pressed:
    lda #KEY_UP
    rts

  key_m_pressed:
  	lda #KEY_DOWN
  	rts

  key_space_pressed:
  	lda #KEY_SPACE
  	rts

// =====================================================================================