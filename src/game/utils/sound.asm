// ===============================================================================
// INITIALIZE RNG MODE
// ===============================================================================
initialize_rng_mode:

	lda #$FF
	sta $D40E
	sta $D40F
	lda #$80
	sta $D412

	// Delay a random number of cycles to prime the RNG:
	lda #$00
	sta MMEM_ZERO_PAGE
	lda #$FE
	sta MMEM_ZERO_PAGE + 1
	jsr get_random_number
	tax

  next_prime_rng_cycle:
  	cpx #$00
  	beq return_initialize_rng_mode
  	dex
  	jmp next_prime_rng_cycle

  return_initialize_rng_mode:
	rts

// ===============================================================================