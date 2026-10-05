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


// ===============================================================================
// QUEUE SOUND
// ===============================================================================
// - ZERO_PAGE 		= SFX data address low byte
// - ZERO_PAGE + 1 	= SFX data address high byte
// ===============================================================================
queue_sound:
	
	// Check how many records currently in the queue:
	lda UMEM_SOUND_QUEUE_START

	// Multiply the value by 2 to get the next queue position:
	asl
	tax

	// Write the new record to the queue:
	lda MMEM_ZERO_PAGE
	sta UMEM_SOUND_QUEUE_START + 1, x
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_SOUND_QUEUE_START + 2, x

	// Increment the queue counter:
	inc UMEM_SOUND_QUEUE_START

	rts

// ===============================================================================


// =====================================================================================
// PROCESS SOUND QUEUE
// =====================================================================================
// - Queue structure:
// - 
// - [00] Number of queued items
// - [01] Queue start
// -
// - [00] sound data address low byte
// - [01] sound data address high byte
// =====================================================================================
process_sound_queue:

	// Sound takes lowest priority. Check sprite animation and coordinate queues; exit if either have pending items:
	lda UMEM_SPRITE_ANIM_QUEUE_START
	cmp #$00
	bne return_process_sound_queue
	lda UMEM_SPRITE_COORD_QUEUE_START
	cmp #$00
	bne return_process_sound_queue

	// Check if any items in the queue:
	ldx UMEM_SOUND_QUEUE_START
	cpx #$00
	bne begin_process_sound_queue
	jmp return_process_sound_queue

  begin_process_sound_queue:
  	ldy UMEM_SOUND_QUEUE_START + 1
  	lda UMEM_SOUND_QUEUE_START + 2

  	// Play the sound:
    sty MMEM_ZERO_PAGE
    sta MMEM_ZERO_PAGE + 1
    jsr play_one_bit_sample

  	// Advance the queue:
  	ldx UMEM_SOUND_QUEUE_START
  	ldy #$01

  advance_sound_queue:
  	cpx #$01
  	beq decrement_sound_queue
  	lda UMEM_SOUND_QUEUE_START + 2, y
  	sta UMEM_SOUND_QUEUE_START, y
  	iny
  	lda UMEM_SOUND_QUEUE_START + 2, y
  	sta UMEM_SOUND_QUEUE_START, y
  	iny
  	dex
  	jmp advance_sprite_animation_queue

  decrement_sound_queue:
  	dec UMEM_SOUND_QUEUE_START

  return_process_sound_queue:
  	rts

// =====================================================================================


// ===============================================================================
// PLAY ONE BIT SAMPLE
// ===============================================================================
// - ZERO_PAGE 		= SFX data address low byte
// - ZERO_PAGE + 1 	= SFX data address high byte
// 
// - SFX Data Structure:
// - [XX] [XX] 
// - [XX] [XX XX XX XX XX XX XX XX XX XX]
// - Byte 1: Number of notes to play
// - Byte 2: Number of bytes per note
// - Rows:
// - 	Byte 1: Length of note
// - 	Bytes 2 - X: Frequencies (# cycles high, # cycles low, etc...)
// ===============================================================================
play_one_bit_sample:

		sei

		pha
		txa
		pha
		tya
		pha
		lda UMEM_VARIABLES_DATA_START
		pha
		lda UMEM_VARIABLES_DATA_START + 1
		pha
		lda UMEM_VARIABLES_DATA_START + 2
		pha
		lda UMEM_VARIABLES_DATA_START + 3
		pha
		ldy #$00
		lda (MMEM_ZERO_PAGE), y
		sta UMEM_VARIABLES_DATA_START 				// Variables + 0: 	Number of notes to play
		iny
		lda (MMEM_ZERO_PAGE), y
		sta UMEM_VARIABLES_DATA_START + 1 			// Variables + 1: 	Number of bytes per note

		// Rewind the data pointer:
		clc
		lda MMEM_ZERO_PAGE
		adc #$01
		sta MMEM_ZERO_PAGE
		bcc continue_rewind
		clc
		lda MMEM_ZERO_PAGE + 1
		adc #$01
		sta MMEM_ZERO_PAGE + 1

	continue_rewind:
		sec
		lda MMEM_ZERO_PAGE
		sbc UMEM_VARIABLES_DATA_START + 1
		sta MMEM_ZERO_PAGE
		bcs next_note
		sec
		lda MMEM_ZERO_PAGE + 1
		sbc #$01
		sta MMEM_ZERO_PAGE + 1

	next_note:
		lda UMEM_VARIABLES_DATA_START + 1
	    clc
	    adc #$01
	    adc MMEM_ZERO_PAGE             
	    sta MMEM_ZERO_PAGE  
	    bcc reset_y_outer
	    inc MMEM_ZERO_PAGE + 1         
	reset_y_outer:
	    ldy #$00
	    lda (MMEM_ZERO_PAGE), y        
	    sta UMEM_VARIABLES_DATA_START + 2 			// Variables + 2: 	Note duration                
	reset_y_inner:
	    ldy #$00
	next_pop:
	    iny                             
	    lda (MMEM_ZERO_PAGE), y        
	    sta UMEM_VARIABLES_DATA_START + 3			// Variables + 3: 	Frequency swap delay
	do_pop:
	    txa
	    eor #$0F
	    tax
	    stx MMEM_VOLUME_CONTROL
	dec_cnt:
	    dec UMEM_VARIABLES_DATA_START + 3              
	    bne dec_cnt
	    cpy UMEM_VARIABLES_DATA_START + 1                  
	    bne next_pop
	    dec UMEM_VARIABLES_DATA_START + 2
	    bne reset_y_inner
	    dec UMEM_VARIABLES_DATA_START
	    bne next_note
	    /*lda UnknownMem                  
	    cmp #$00 //#$84
	    bne pop_done
	    pla
	    sta UnknownMem_2*/
	pop_done:

		pla
		sta UMEM_VARIABLES_DATA_START + 3
		pla
		sta UMEM_VARIABLES_DATA_START + 2
		pla
		sta UMEM_VARIABLES_DATA_START + 1
		pla 
		sta UMEM_VARIABLES_DATA_START
		pla
		tay
		pla
		tax
		pla

		cli

	    rts

// ===============================================================================