// =====================================================================================
// SET BIT
// =====================================================================================
// - address: ZERO_PAGE = high, ZERO_PAGE + 1 = low
// - bit_number: ZERO_PAGE + 2
// - value: ON or OFF, ZERO_PAGE + 3
// =====================================================================================
set_bit:

	.var compareAddr = UMEM_VARIABLES_DATA_START + MEMORY_SET_BIT_COMPARE_VAL_ADDR

	// Load the compare value into memory:
	ldx #$00
	lda (MMEM_ZERO_PAGE, x)
	ldx #MEMORY_SET_BIT_COMPARE_VAL_ADDR
	sta UMEM_VARIABLES_DATA_START, x

	// Initialize X and Y:
	ldx #MEMORY_SET_BIT_VALUE_ADDR
	ldy MMEM_ZERO_PAGE, x 				// Y = value
	ldx #MEMORY_SET_BIT_NUMBER_ADDR
	lda MMEM_ZERO_PAGE, x
	tax 								// X = starting search index
	inx

  	// Search for bit:
  search_for_bit:
  	dex
  	cpx #$00							// Have we found the bit? 
  	beq perform_set_bit_operation		// Bit found; set the value
  	tya 								// Bit not found yet; move to the next bit
  	asl
  	tay
  	jmp search_for_bit

  	// Set bit:
  perform_set_bit_operation:
  	tya
  	cmp #ON 							// Does the bit need to be switched on or off?
  	beq set_bit_on

  	// Set bit off:
  	and compareAddr						// Switching off requires an AND operation
  	jmp apply_bit_change

  	// Set bit on:
  set_bit_on:
  	ora compareAddr						// Switching on requires an OR operation

  	// Apply bit change:
  apply_bit_change:
  	ldx #$00
  	sta (MMEM_ZERO_PAGE, x) 			// Apply the change
    
    rts

// =====================================================================================


// =====================================================================================
// GET BIT
// =====================================================================================
// - address: MMEM_ZERO_PAGE
// - bit_number: MMEM_ZERO_PAGE + 2
// - Stores result in accumulator: ON or OFF
// =====================================================================================
get_bit:

	// Initialize X and Y:
	ldy #$02
  	ldx MMEM_ZERO_PAGE, y
  	inx
  	ldy #$01

  	// Create bit mask:
  create_bit_mask:
  	dex
  	cpx #$00						// Have we found the bit? 
  	beq get_status					// Bit found; read the value
  	tya 							// Bit not found yet; move to the next bit
  	asl
  	tay
  	jmp create_bit_mask

  	// Read bit:
  get_status:
  	ldx #$00
  	lda (MMEM_ZERO_PAGE, x)
  	sta MMEM_ZERO_PAGE
  	tya
  	and MMEM_ZERO_PAGE				// Read value
  	beq status_off					// Bit is switched off
  	lda #ON
  	rts

  	// Report the status as OFF:
  status_off:
  	lda #OFF	

  	rts			

// =====================================================================================


// =====================================================================================
// PRESERVE WORKING DATA
// =====================================================================================
preserve_working_data:

	// Preserve registers:
	jsr preserve_registers

	// Preserve zero-page:
	ldx #$00

  preserve_zero_page:
	lda MMEM_ZERO_PAGE, x
	sta UMEM_ZERO_PAGE_TRANSFER_START, x
	cpx #$06
	beq return_from_preserve
	inx
	jmp preserve_zero_page

  return_from_preserve:
  	rts

// =====================================================================================


// =====================================================================================
// RESTORE WORKING DATA
// =====================================================================================
restore_working_data:

	// Restore zero-page:
	ldx #$00

  restore_zero_page:
	lda UMEM_ZERO_PAGE_TRANSFER_START, x
	sta MMEM_ZERO_PAGE, x
	cpx #$06
	beq begin_restore_registers
	inx
	jmp restore_zero_page

  begin_restore_registers:
	// Restore registers:
	jsr restore_registers

  	rts

// =====================================================================================


// =====================================================================================
// PRESERVE REGISTERS
// =====================================================================================
preserve_registers:

	sta UMEM_ZERO_PAGE_TRANSFER_START + 7
  	stx UMEM_ZERO_PAGE_TRANSFER_START + 8
  	sty UMEM_ZERO_PAGE_TRANSFER_START + 9

  	rts

// =====================================================================================


// =====================================================================================
// RESTORE REGISTERS
// =====================================================================================
restore_registers:

	lda UMEM_ZERO_PAGE_TRANSFER_START + 7
  	ldx UMEM_ZERO_PAGE_TRANSFER_START + 8
  	ldy UMEM_ZERO_PAGE_TRANSFER_START + 9

  	rts

// =====================================================================================


// =====================================================================================
// SET PARAMETERS
// =====================================================================================
.macro set_parameters(param_1, param_2, param_3, param_4, param_5, param_6, param_7)
{
	.if (param_1 != NULL)
	{
		lda #param_1
		sta MMEM_ZERO_PAGE
	}

	.if (param_2 != NULL)
	{
		lda #param_2
		sta MMEM_ZERO_PAGE + 1
	}

	.if (param_3 != NULL)
	{
		lda #param_3
		sta MMEM_ZERO_PAGE + 2
	}

	.if (param_4 != NULL)
	{
		lda #param_4
		sta MMEM_ZERO_PAGE + 3
	}

	.if (param_5 != NULL)
	{
		lda #param_5
		sta MMEM_ZERO_PAGE + 4
	}

	.if (param_6 != NULL)
	{
		lda #param_6
		sta MMEM_ZERO_PAGE + 5
	}

	.if (param_7 != NULL)
	{
		lda #param_7
		sta MMEM_ZERO_PAGE + 6
	}
}
// =====================================================================================


// =====================================================================================
// INITIALIZE MEMORY
// =====================================================================================
// ZERO_PAGE 	 = starting address
// ZERO_PAGE + 2 = bytes to clear
// =====================================================================================
initialize_memory:
	
	ldx MMEM_ZERO_PAGE + 2
	lda #$00

  begin_init_memory:
	sta (MMEM_ZERO_PAGE), x
	cpx #$00
	beq return_init_memory
	dex
	jmp begin_init_memory

  return_init_memory:
	rts

// =====================================================================================