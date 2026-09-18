.segment UtilityRoutines

// =====================================================================================
// INIT SCORE
// =====================================================================================
// - Zero the score counter
// =====================================================================================
.macro

init_score()
{
	:set_score("123")
}
// =====================================================================================


// =====================================================================================
// SET SCORE
// =====================================================================================
// - score = integer
// =====================================================================================
.macro

set_score(score)
{
	.var scoreString = toIntString(score.asNumber())
	.var numDigits = scoreString.size()
	.var isOdd = mod(numDigits, 2)
	.var startingPosition = 0
	.var numDigitsForFormula = numDigits

	.if (isOdd == TRUE)
	{
		.eval numDigitsForFormula = numDigitsForFormula + 1
	}

	.eval startingPosition = (((-1) * (0.5)) * numDigitsForFormula) + 6

	// Display the score at the calculated offset:
	ldx #startingPosition
	ldy #$00

  display_score:
	lda score_string_start, y
	sta UMEM_SCORE_START_ADDRESS, x
	inx
	iny
	cpy #numDigits
	bne display_score
	jmp macro_end

  score_string_start:
  	.text scoreString

  macro_end:
}
// =====================================================================================


// =====================================================================================
// SET BREAKPOINT
// =====================================================================================
.macro set_breakpoint(conditional)
{
	breakpoint:

		.if (conditional == TRUE)
		{
			jsr preserve_working_data
			lda #TRUE
			cmp UMEM_BREAKPOINT_CONDITION_ADDR
			bne exit_breakpoint
			:check_exit_breakpoint()
			beq breakpoint

		  exit_breakpoint:
			:exit_breakpoint()
		}
		else
		{
			jsr preserve_working_data
			:check_exit_breakpoint()
			beq exit_breakpoint
			jmp breakpoint

		  exit_breakpoint:
			:exit_breakpoint()
		}
}
// =====================================================================================


// =====================================================================================
// CHECK EXIT BREAKPOINT
// =====================================================================================
.macro check_exit_breakpoint()
{
	jsr get_key_code
	cmp #KEY_CONTINUE_BREAKPOINT
}
// =====================================================================================


// =====================================================================================
// EXIT BREAKPOINT
// =====================================================================================
.macro exit_breakpoint()
{
	jsr restore_working_data
}
// =====================================================================================


// =====================================================================================
// SET INIT COMPLETE
// =====================================================================================
.macro set_init_complete()
{	
	lda #TRUE
	sta UMEM_INIT_INDICATOR_ADDR
}
// =====================================================================================


// =====================================================================================
// PROCESS SPRITE QUEUES
// =====================================================================================
process_sprite_queues:
	
	jsr process_coordinate_queue
    jsr process_animation_queue

    rts

// =====================================================================================


// =====================================================================================
// SET INIT STARTED
// =====================================================================================
.macro set_init_started()
{
	lda #FALSE
	sta UMEM_INIT_INDICATOR_ADDR
}	
// =====================================================================================


// =====================================================================================
// PROCESS USER INPUT
// =====================================================================================
process_user_input:

	// Check for user input:
    jsr get_key_code

  check_up:
    cmp #KEY_UP
    bne check_down
    lda #SPRITE_UP
    jsr move_player
    jmp return_process_user_input

  check_down:
    cmp #KEY_DOWN
    bne check_left 
    lda #SPRITE_DOWN
    jsr move_player
    jmp return_process_user_input
  
  check_left:
    cmp #KEY_LEFT
    bne check_right 
    lda #SPRITE_LEFT
    jsr move_player
    jmp return_process_user_input
  
  check_right:
    cmp #KEY_RIGHT
    bne check_space
    lda #SPRITE_RIGHT
    jsr move_player
    jmp return_process_user_input

  check_space:
  	cmp #KEY_SPACE
  	bne return_process_user_input
  	lda #SPRITE_PLAYER
  	jsr munch

  return_process_user_input:
    jsr lock_user_input
  	rts

// =====================================================================================


// =====================================================================================
// MUNCH
// =====================================================================================
// - Accumulator = sprite index
// =====================================================================================
munch:

	cmp #SPRITE_PLAYER
	bne return_munch
	ldx UMEM_SPRITE_PLAYER_POINTER_ADDR
	sta MMEM_ZERO_PAGE

  set_munch_param:
    stx MMEM_ZERO_PAGE + 1

    jsr queue_munch_animation

  return_munch:
  	rts

// =====================================================================================


// =====================================================================================
// MOVE PLAYER
// =====================================================================================
move_player:

	// Save direction parameter to X register:
	tax

	// Set movement parameters - player sprite index and pointer:
    lda UMEM_SPRITE_PLAYER_POINTER_ADDR
    sta MMEM_ZERO_PAGE + 1
    lda #SPRITE_PLAYER
    sta MMEM_ZERO_PAGE

    // Check the direction and move accordingly:
    cpx #SPRITE_LEFT
    beq move_player_left
    cpx #SPRITE_RIGHT
    beq move_player_right
    cpx #SPRITE_UP
    beq move_player_up

  move_player_down:  	
    jsr queue_y_coordinate_increment
    jmp return_move_player

  move_player_up:
  	jsr queue_y_coordinate_decrement
    jmp return_move_player

  move_player_left:
    jsr queue_x_coordinate_decrement
    jmp return_move_player

  move_player_right:
  	jsr queue_x_coordinate_increment

  return_move_player:
    rts

// =====================================================================================


// =====================================================================================
// LOCK USER INPUT
// =====================================================================================
lock_user_input:

	// Get number of passes:
    ldy #KEY_INPUT_LOCK_PASSES

    // Process each pass:
  outer_input_delay:

  	// Get number of cycles per pass:
    ldx #KEY_INPUT_LOCK_CYCLES

    // Process each cycle
  input_delay:

  	// Preserve X and Y:
    stx MMEM_ZERO_PAGE + 5
    sty MMEM_ZERO_PAGE + 6

    // Continue to process the sprite queues while waiting:
    jsr process_sprite_queues

    // Restore X and Y:
    ldx MMEM_ZERO_PAGE + 5
    ldy MMEM_ZERO_PAGE + 6

    // Process next cycle:
    dex
    cpx #$00
    bne input_delay

    // Process next pass:
    dey
    cpy #$00
    bne outer_input_delay

    rts

// =====================================================================================


// =====================================================================================
// GET RANDOM NUMBER
// =====================================================================================
// - ZERO_PAGE  	= min value
// - ZERO_PAGE + 1 	= max value
// - 
// - Returns number in accumulator
// =====================================================================================
get_random_number:

	inc MMEM_ZERO_PAGE + 1

  try_next_number:
	lda MMEM_ZERO_PAGE + 1
	clc
	sbc MMEM_ZERO_PAGE
	sta UMEM_VARIABLES_DATA_START
	inc UMEM_VARIABLES_DATA_START
	lda $D41B
	cmp UMEM_VARIABLES_DATA_START
	bcs try_next_number
	clc
	adc MMEM_ZERO_PAGE

    rts

// =====================================================================================


// =====================================================================================
// GET CHOICE ADDRESS
// =====================================================================================
// - ZERO_PAGE 		= Desired starting table block low byte
// - ZERO_PAGE + 1 	= Desired starting table block high byte
// - ZERO_PAGE + 2 	= Choice index relative to starting block
// - 
// - Returns:
// - ZERO_PAGE  	= String address low byte
// - ZERO_PAGE + 1 	= String address high byte
// =====================================================================================
get_choice_address:
	
	// Compute starting address from index:
	ldx MMEM_ZERO_PAGE + 2						// X = choice index

  seek_choice_start:
  	cpx #$00
  	beq return_choice_address
  	clc
  	lda MMEM_ZERO_PAGE
  	adc #$05 									// Seek forward to the start of the next choice
  	sta MMEM_ZERO_PAGE
  	lda MMEM_ZERO_PAGE + 1
  	adc #$00
  	sta MMEM_ZERO_PAGE + 1
  	dex
  	jmp seek_choice_start

  return_choice_address:
	rts

// =====================================================================================


// =====================================================================================
// INITIALIZE GRID
// =====================================================================================
init_grid:

	jsr seed_grid_data

	// Grid is seeded. Begin the process of grabbing a random cell and shrinking the seed data:
  begin_init_grid_populate:

  	// We need to keep track of choices - we need 10 correct, 10 incorrect, and 10 random.
  	// Number of available correct and incorrect choices and addresses vary with game mode and level.

  	// Check the game mode first:
  	lda UMEM_GAME_MODE_ADDR
  	cmp #GAME_MODE_MULTIPLES
  	beq init_grid_multiples
  	jmp end_init_grid

  init_grid_multiples:
  	// Check the level:
  	lda UMEM_LEVEL_ADDR
  	cmp #$00
  	beq init_grid_multiples_level_1
  	jmp end_init_grid

  init_grid_multiples_level_1:
  	// Get 10 random correct answers and store them in 10 random cells:
  	ldx #$0A
  	stx UMEM_VARIABLES_DATA_START + 2

  populate_next_correct_choice:
  	ldx UMEM_VARIABLES_DATA_START + 2
  	lda #$00
  	sta MMEM_ZERO_PAGE
  	lda #$09
  	sta MMEM_ZERO_PAGE + 1
  	jsr get_random_number

  	// Now we have a pointer to a random correct answer:
  	sta MMEM_ZERO_PAGE + 2
  	lda #<Multiples_Mode_Choices_OP2_Correct
  	sta MMEM_ZERO_PAGE
  	lda #>Multiples_Mode_Choices_OP2_Correct
  	sta MMEM_ZERO_PAGE + 1
  	jsr get_choice_address

  	// Now zero page contains the address of the random correct answer string:
  	lda MMEM_ZERO_PAGE
  	sta UMEM_VARIABLES_DATA_START
  	lda MMEM_ZERO_PAGE + 1
  	sta UMEM_VARIABLES_DATA_START + 1

  	// Now we need to fetch the next random x, y grid coordinate from the seed data:
  	jsr get_next_seed_location

  	// Now zero page contains the x, y coordinate to place the string:
  	lda MMEM_ZERO_PAGE
  	sta MMEM_ZERO_PAGE + 2
  	lda MMEM_ZERO_PAGE + 1
  	sta MMEM_ZERO_PAGE + 3
  	lda UMEM_VARIABLES_DATA_START 
  	sta MMEM_ZERO_PAGE
  	lda UMEM_VARIABLES_DATA_START + 1
  	sta MMEM_ZERO_PAGE + 1
  	.break
  	jsr populate_grid_cell

  	// Move to the next of the 10 correct answers:
  	ldx UMEM_VARIABLES_DATA_START + 2
  	dex
  	stx UMEM_VARIABLES_DATA_START + 2
  	cpx #$00
  	bne populate_next_correct_choice

  end_init_grid:
  	rts

// =====================================================================================


// =====================================================================================
// SEED GRID DATA
// =====================================================================================
seed_grid_data:
	
	// Seed the grid data:
	ldx #$00

  reset_x_init_grid:
	lda #$00 									// X coordinate

  reset_y_init_grid:
	ldy #$00 									// Y coordinate

  process_next_init_grid_seed:
	sta UMEM_GRID_SEED_ADDR, x 					// Store the current X-coordinate at the current seed location
	pha 										// Preserve the X-coordinate
	tya 										// Transfer the Y-coordinate to the accumulator
	sta UMEM_GRID_SEED_ADDR + 1, x 				// Store the Y-coordinate at the current seed location + 1
	pla 										// Restore the X-coordinate
	cpx #$3A									// Check to see if we have processed all seed steps
	beq return_seed_grid 						// If we have processed all seed steps, exit the routine
	inx 										// Otherwise, seek forward two positions to move to the next seed location 
	inx
	cpy #$04 									// Check whether we have processed all 5 Y-coordinates
	bne process_next_seed_y_coordinate			// If we have, reset the Y-coordinate to 0 and increment the X-coordinate. If not, move to the next Y-coordinate
	sta UMEM_VARIABLES_DATA_START
	inc UMEM_VARIABLES_DATA_START
	lda UMEM_VARIABLES_DATA_START
	jmp reset_y_init_grid

  process_next_seed_y_coordinate:
  	iny 										// Move to the next Y-coordinate
	cmp #$06 									// Check whether we have processed all 6 X-coordinates
	bne process_next_init_grid_seed	 			// If we have, reset the X and Y coordinates to 0. If not, move to the next X-coordinate
	jmp reset_x_init_grid

  return_seed_grid:
  	lda #$1E 						
  	sta UMEM_SEED_COUNTER_ADDR 					// Set the 0-indexed seed counter
	rts

// =====================================================================================


// =====================================================================================
// GET NEXT SEED LOCATION
// =====================================================================================
// - Stores x and y in zero page
// =====================================================================================
get_next_seed_location:

	pha
	tya
	pha
	txa
	pha
	ldx UMEM_SEED_COUNTER_ADDR 					// ----- X = 1B
	dex                                         // ----- X = 1A
  	stx MMEM_ZERO_PAGE + 1                      // ----- ZP + 1 = 1A
  	stx UMEM_VARIABLES_DATA_START + 4 // debug
  	lda #$00                                    // ----- A = 0
  	sta MMEM_ZERO_PAGE                          // ----- ZP = 0
  	sta UMEM_VARIABLES_DATA_START + 5 // debug
  	jsr get_random_number 						// ----- A = 1
  	sta UMEM_VARIABLES_DATA_START + 6 // debug


  	// We now have a number in the accumulator which is between 0 and the remaining number of cells in the seed data.

  	// Extract the grid cell at the selected location:
  	asl 										// ----- A = 2
  	tay  										// ----- Y = 2
  	lda UMEM_GRID_SEED_ADDR, y 					// ----- A = 0

  	// A now contains the address of the seeded X and Y. Load those values into zero-page:
  	sta MMEM_ZERO_PAGE 							// ----- ZP = 0
  	lda UMEM_GRID_SEED_ADDR + 1, y              // ----- A = 1
  	sta MMEM_ZERO_PAGE + 1 						// ----- ZP + 1 = 1

  	// Shift the seeded data. 
  	// X = number of stored seeds (0-indexed)
  	// Y = offset of data that was just grabbed

  	// Start by replacing the data we just grabbed with the next data up the seed:

  	// Are we finished? We are finished if X = Y.
  check_next_seed_element:
  	tya 										// ----- A = 2
  	lsr 										// ----- A = 1
  	//.break
  	cmp UMEM_SEED_COUNTER_ADDR 					// ----- 1B
  	beq decrement_seed_counter 					// ----- <>

  	lda UMEM_GRID_SEED_ADDR + 3, y 				// ----- 
  	sta UMEM_GRID_SEED_ADDR + 1, y
  	lda UMEM_GRID_SEED_ADDR + 2, y
  	sta UMEM_GRID_SEED_ADDR, y
  	lda #$00
  	sta UMEM_GRID_SEED_ADDR + 3, y
  	sta UMEM_GRID_SEED_ADDR + 2, y

  	// Move to the next element:
  	iny
  	iny
  	jmp check_next_seed_element

  decrement_seed_counter:
  	dec UMEM_SEED_COUNTER_ADDR

  	// Restore the registers:
  	pla
  	tax
  	pla
  	tay
  	pla

  	rts

// =====================================================================================


// =====================================================================================
// INITIALIZE LEVEL
// =====================================================================================
init_level:
	lda #$00
	sta UMEM_LEVEL_ADDR
	rts
// =====================================================================================


// =====================================================================================
// SET GAME MODE
// =====================================================================================
// - A = Game Mode
// =====================================================================================
set_game_mode:
	sta UMEM_GAME_MODE_ADDR
	rts
// =====================================================================================