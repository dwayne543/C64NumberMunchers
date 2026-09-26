// ************************************************************************************
// ROUTINE CATALOG:
// - 
// - Routine Name 					Returns  											Parameters
// ---------------------------------------------------------------------------------------------------------------------------------------
// - init_virtual_sprite_memory 	------- 											-------
//
// - init_sprites 					-------												-------
//
// - set_sprite_multicolor_data		-------												-------
//
// - get_sprite_color_data_address	ZERO_PAGE  		= color data address low byte 		ZERO_PAGE 		= sprite address low byte
// - 								ZERO_PAGE + 1 	= color data address high byte 		ZERO_PAGE + 1 	= sprite address high byte
//
// - get_sprite_pointer 			ZERO_PAGE 		= sprite pointer 					ZERO_PAGE 		= sprite address low byte
// - 																					ZERO_PAGE + 1   = sprite address high byte
//
// - display_sprite 				-------	 											ZERO_PAGE 		= idle sprite address low byte
// -																					ZERO_PAGE + 1 	= idle sprite address high byte
// - 																					ZERO_PAGE + 2  	= sprite index
// -																					ZERO_PAGE + 3 	= start x low byte
// - 																					ZERO_PAGE + 4 	= start y
// - 																					ZERO_PAGE + 5 	= start x high bit (ON / OFF)
//
// - render_sprites 				------- 											-------
//
// - enable_renderer 				------- 											-------
//
// - process_coordinate_queue 		------- 											-------
//
// - get_coordinates 				ZERO_PAGE 		= x coordinate low byte 			ZERO_PAGE 		= sprite index
// -  								ZERO_PAGE + 1 	= y coordinate 
// - 								ZERO_PAGE + 2 	= x coordinate high bit (ON / OFF)
//
// - queue_coordinate_update 		------- 											ZERO_PAGE 		= sprite index
// - 																					ZERO_PAGE + 1 	= x coordinate low byte
// - 																					ZERO_PAGE + 2 	= y coordinate
// - 																					ZERO_PAGE + 3  	= x coordinate high bit (ON / OFF) 
//
// ************************************************************************************





// =====================================================================================
// INITIALIZE VIRTUAL SPRITE MEMORY
// =====================================================================================
init_virtual_sprite_memory:

	:set_parameters(<UMEM_VIRTUAL_SPRITE_RAM_START, >UMEM_VIRTUAL_SPRITE_RAM_START, $09, NULL, NULL, NULL, NULL)
	jsr initialize_memory
	
	:set_parameters(<UMEM_VIRTUAL_SPRITE_COORD_START, >UMEM_VIRTUAL_SPRITE_COORD_START, $11, NULL, NULL, NULL, NULL)
	jsr initialize_memory

	:set_parameters(<UMEM_SPRITE_COORD_QUEUE_START, >UMEM_SPRITE_COORD_QUEUE_START, $FF, NULL, NULL, NULL, NULL)
	jsr initialize_memory

	:set_parameters(<UMEM_SPRITE_GRID_POS_START, >UMEM_SPRITE_GRID_POS_START, $10, NULL, NULL, NULL, NULL)
	jsr initialize_memory

	rts

// =====================================================================================


// =====================================================================================
// INIT SPRITES
// =====================================================================================
init_sprites:

	// Initialize all sprites to off
	lda #OFF 											// Initialize all sprites to off
	sta MMEM_SPRITE_TOGGLE

	// Initialize all sprites to single-color mode
	lda #OFF
	sta MMEM_SPRITE_COLOR_MODE

	// Set up multicolor data
	jsr set_sprite_multicolor_data						// Set up multicolor data

	rts

// =====================================================================================


// =====================================================================================
// SET SPRITE MULTICOLOR DATA
// =====================================================================================
set_sprite_multicolor_data:

	lda #SPRITE_MULTICOLOR_1
	sta MMEM_SPRITE_MULTICOLOR_1
	lda #SPRITE_MULTICOLOR_2
	sta MMEM_SPRITE_MULTICOLOR_2

	rts

// =====================================================================================


// =====================================================================================
// GET SPRITE COLOR DATA ADDRESS
// =====================================================================================
// - Returns start address of sprite color data. Format:
// - [Offset]	[Value]
// - $00		Color
// - $01		IsMulticolor (TRUE or FALSE)
// - Loads address into zero page
// - 
// - ZERO_PAGE = sprite address
// =====================================================================================
get_sprite_color_data_address:

	// Start looking through the color data map table until the requested row is found:
	ldx #$00						// Current row number
	
  search_next_row:
	lda Tbl_Sprite_Color_Map, x 	// Read low byte
	cmp MMEM_ZERO_PAGE 				// Low byte match?
	beq read_high_byte
	inx 							// No match; jump to next row
	inx 
	inx 
	inx
	jmp search_next_row

  read_high_byte:
	inx
	lda Tbl_Sprite_Color_Map, x 	// Read high byte
	cmp MMEM_ZERO_PAGE + 1 			// High byte match?
	beq row_found
	inx 							// No match; jump to next row
	inx
	inx
	jmp search_next_row	

  row_found:
  	inx
  	ldy #$01 
  	lda Tbl_Sprite_Color_Map, x 	// Read low address byte
  	sta MMEM_ZERO_PAGE			 	// Store low byte in zero page
  	inx 
  	lda Tbl_Sprite_Color_Map, x 	// Read high address byte
  	sta MMEM_ZERO_PAGE, y			// Store high byte in zero page + 1

  	rts

// =====================================================================================


// =====================================================================================
// SPRITE POINTER
// =====================================================================================
// - Sets zero page to value of sprite pointer that corresponds to specified sprite address
// - 
// - ZERO_PAGE  	= Sprite address low byte
// - ZERO_PAGE + 1  = sprite address high byte
// =====================================================================================
get_sprite_pointer:

	// Divide by 64:
	ldx #$06

  divide_next_step:
	lsr MMEM_ZERO_PAGE + 1
	ror MMEM_ZERO_PAGE
	dex
	cpx #$00
	beq return_get_sprite_pointer
	jmp divide_next_step

  return_get_sprite_pointer:
  	rts

// =====================================================================================


// =====================================================================================
// DISPLAY SPRITE
// =====================================================================================
// - sprite_index: 0-based sprite index (0-7)
// - 
// - ZERO_PAGE  	= idle sprite address low byte   (-> Variables + 6)
// - ZERO_PAGE + 1 	= idle sprite address high byte  (-> Variables + 7)
// - ZERO_PAGE + 2	= sprite index
// - ZERO_PAGE + 3  = start x
// - ZERO_PAGE + 4 	= start y
// - ZERO_PAGE + 5  = start x high bit
// =====================================================================================
display_sprite:

	lda MMEM_ZERO_PAGE
	sta UMEM_VARIABLES_DATA_START + 6
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_VARIABLES_DATA_START + 7

	// Compute the variables:
	jsr get_sprite_pointer
	ldx #$05

  save_next_display_sprite_parameter:
	lda MMEM_ZERO_PAGE, x
	sta UMEM_VARIABLES_DATA_START, x
	cpx #$00
	beq point_sprite_register
	dex 
	jmp save_next_display_sprite_parameter	

  point_sprite_register:
	// Point the VIC-II to the sprite data:
	ldx UMEM_VARIABLES_DATA_START + 2
	lda UMEM_VARIABLES_DATA_START												
  	sta MMEM_SPRITE_RAM_START, x												// Point the requested register at the sprite data

  	// Set the X and Y coordinates:
  	txa 
  	asl
  	tax
  	lda UMEM_VARIABLES_DATA_START + 3
  	sta MMEM_SPRITE_COORD_RAM_START, x
  	lda UMEM_VARIABLES_DATA_START + 4
  	sta MMEM_SPRITE_COORD_RAM_START + 1, x
  	lda UMEM_VARIABLES_DATA_START + 5
  	cmp #$00														// Check if the X coordinate > 255
  	beq set_color_data												// If not > 255, then skip the X-high bit set routine
  	ldx #$00
  	lda #<MMEM_SPRITE_COORD_9TH_BIT
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda #>MMEM_SPRITE_COORD_9TH_BIT
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda UMEM_VARIABLES_DATA_START + 2
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda #ON	
  	sta MMEM_ZERO_PAGE, x
  	jsr set_bit

  	// Set color data:
  set_color_data:
  	lda UMEM_VARIABLES_DATA_START + 6
  	sta MMEM_ZERO_PAGE
  	lda UMEM_VARIABLES_DATA_START + 7
  	sta MMEM_ZERO_PAGE + 1
  	jsr get_sprite_color_data_address								// Get base color data address from lookup table      
	ldx #$00       
	lda (MMEM_ZERO_PAGE), x    										// Get sprite color
	ldy UMEM_VARIABLES_DATA_START + 2
	sta MMEM_SPRITE_COLOR_RAM_START, y								// Set sprite color
	inx 
	lda (MMEM_ZERO_PAGE), x											// Get multicolor mode bool
	cmp #FALSE
	beq enable_sprite 												// If single-color mode, skip multi-color code
	ldx #$00
	lda #<MMEM_SPRITE_COLOR_MODE
	sta MMEM_ZERO_PAGE, x
	inx
	lda #>MMEM_SPRITE_COLOR_MODE
	sta MMEM_ZERO_PAGE, x
	inx
	lda UMEM_VARIABLES_DATA_START + 2
	sta MMEM_ZERO_PAGE, x
	inx
	lda #ON
	sta MMEM_ZERO_PAGE, x
	jsr set_bit 													// Enable multicolor mode

	// Enable sprite:
  enable_sprite:
  	ldx #$00
  	lda #<MMEM_SPRITE_TOGGLE
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda #>MMEM_SPRITE_TOGGLE
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda UMEM_VARIABLES_DATA_START + 2
  	sta MMEM_ZERO_PAGE, x
  	inx
  	lda #ON
  	sta MMEM_ZERO_PAGE, x
  	jsr set_bit

  	rts

// =====================================================================================


// =====================================================================================
// RENDER SPRITES
// =====================================================================================
// - Flips the frame buffer into sprite memory. Runs at VBlank.
// - Virtual sprite memory configuration:
// 
// - [00]: Pending flags. If bit is 1, needs to be picked up by renderer.
// - [02]: Start of direct mapping
//
// - The above map applies to animation frame memory as well as coordinate memory.
// =====================================================================================
render_sprites:

	// This is an interrupt, so preserve working data:
  	jsr preserve_working_data

  	// Disable blinking cursor:
    jsr disable_cursor

	// Loop through each sprite and check for pending animation frames:
	ldx #$08 	

  check_for_pending_animation:
	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_RAM_START)
  	dex
	stx MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #ON
  	beq update_animation_frame
  	ldx MMEM_ZERO_PAGE + 2
  	cpx #$00
  	bne check_for_pending_animation

  	// Loop through each sprite and check for pending coordinate updates:
  	ldx #$08
  	stx MMEM_ZERO_PAGE + 2

  check_for_pending_coordinate:
	ldx MMEM_ZERO_PAGE + 2
	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_COORD_START)
  	dex
  	stx MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #ON
  	beq update_coordinate
  	ldx MMEM_ZERO_PAGE + 2
  	cpx #$00
  	bne check_for_pending_coordinate
  	jmp return_from_render_sprite

  	//X = sprite index 0-7
  update_animation_frame:
  	ldx MMEM_ZERO_PAGE + 2
  	lda UMEM_VIRTUAL_SPRITE_RAM_START + 1, x
  	sta MMEM_SPRITE_RAM_START, x
  	:set_setbit_parameters(UMEM_VIRTUAL_SPRITE_RAM_START, OFF)
  	jsr set_bit
  	ldx MMEM_ZERO_PAGE + 2
  	cpx #$00
  	bne check_for_pending_animation
  	ldx #$08
  	stx MMEM_ZERO_PAGE + 2
  	jmp check_for_pending_coordinate

  update_coordinate:
  	ldx MMEM_ZERO_PAGE + 2
  	txa
  	asl
  	tax
  	lda UMEM_VIRTUAL_SPRITE_COORD_START + 1, x
  	sta MMEM_SPRITE_COORD_RAM_START, x
  	lda UMEM_VIRTUAL_SPRITE_COORD_START + 2, x
  	sta MMEM_SPRITE_COORD_RAM_START + 1, x
  	lda UMEM_VIRTUAL_SPRITE_COORD_START + $11, x
  	sta MMEM_SPRITE_COORD_9TH_BIT
  	:set_setbit_parameters(UMEM_VIRTUAL_SPRITE_COORD_START, OFF)
  	txa
  	lsr
  	tax
  	stx MMEM_ZERO_PAGE + 2
  	jsr set_bit
  	ldx MMEM_ZERO_PAGE + 2
  	cpx #$00
  	beq return_from_render_sprite
  	jmp check_for_pending_coordinate

  return_from_render_sprite:  

  	// Acknowledge the interrupt:
  	asl $D019
  	//lda $DC0D

  	// Restore working data:
  	jsr restore_working_data

  	//rti

  	// Hand off interrupt control back to the C64:
  	jmp KRN_HANDLE_INTERRUPTS

// =====================================================================================


// =====================================================================================
// SET CHECK RENDER FLAG PARAMETERS
// =====================================================================================
.macro set_check_render_flag_parameters(flag_address)
{
	:set_parameters(<flag_address, >flag_address, NULL, NULL, NULL, NULL, NULL)
}
// =====================================================================================


// =====================================================================================
// SET SETBIT PARAMETERS
// =====================================================================================
.macro set_setbit_parameters(flag_address, value)
{
	:set_parameters(<flag_address, >flag_address, NULL, value, NULL, NULL, NULL)
}
// =====================================================================================


// =====================================================================================
// ENABLE RENDERER
// =====================================================================================
enable_renderer:

	// Switch off interrupts while we set up the renderer:
	sei

	// Switch off interrupts signals from CIA-1:
	lda #%01111111
	sta $DC0D

	// Clear most significant bit of VIC-II raster register:
	and $D011
	sta $D011

	// Acknowledge pending interrupts from CIA:
	sta $DC0D	// 1
	sta $DD0D	// 2

	// Disable keyboard interrupt:
	lda #$7F
	sta $DC0D

	// Set interrupt raster line:
	lda #$00
	sta $D012

	// Point to the interrupt routine:
	lda #<render_sprites
	sta $0314
	lda #>render_sprites
	sta $0315

	// Enable raster interrupt signals:
	lda #%00000001
	sta $D01A

	// Disable keyboard scanning by replacing jump to scnkey routine instructions in kernal with no-ops:
	lda $EA
	sta $EA7B
	sta $EA7C
	sta $EA7D

	// Re-enable interrupts:
	cli

	rts

// =====================================================================================


// =====================================================================================
// PROCESS ANIMATION QUEUE
// =====================================================================================
// - Queue structure:
// - 
// - [00] Number of queued items
// - [01] Queue start
// -
// - [00] sprite index (0 - 7)
// - [01] animation frame
// =====================================================================================
process_animation_queue:

	// Check if any items in the queue:
	ldx UMEM_SPRITE_ANIM_QUEUE_START
	cpx #$00
	bne check_flagged_anim_frames
	jmp return_process_animation_queue

  check_flagged_anim_frames:
  	ldy UMEM_SPRITE_ANIM_QUEUE_START + 1 				// Y = sprite index  	
  	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_RAM_START)
  	sty MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #OFF
  	beq begin_process_animation_queue
  	jmp return_process_animation_queue

  begin_process_animation_queue:
  	ldy UMEM_SPRITE_ANIM_QUEUE_START + 1
  	lda UMEM_SPRITE_ANIM_QUEUE_START + 2
  	sta UMEM_VIRTUAL_SPRITE_RAM_START + 1, y

  	// Flag the virtual sprite animation memory for processing:
  	:set_setbit_parameters(UMEM_VIRTUAL_SPRITE_RAM_START, ON)
  	lda UMEM_SPRITE_ANIM_QUEUE_START + 1
  	sta MMEM_ZERO_PAGE + 2
  	jsr set_bit

  	// Advance the queue:
  	ldx UMEM_SPRITE_ANIM_QUEUE_START
  	ldy #$01

  advance_sprite_animation_queue:
  	cpx #$01
  	beq decrement_sprite_animation_queue
  	lda UMEM_SPRITE_ANIM_QUEUE_START + 2, y
  	sta UMEM_SPRITE_ANIM_QUEUE_START, y
  	iny
  	lda UMEM_SPRITE_ANIM_QUEUE_START + 2, y
  	sta UMEM_SPRITE_ANIM_QUEUE_START, y
  	iny
  	dex
  	jmp advance_sprite_animation_queue

  decrement_sprite_animation_queue:
  	dec UMEM_SPRITE_ANIM_QUEUE_START

  return_process_animation_queue:
  	rts

// =====================================================================================


// =====================================================================================
// PROCESS COORDINATE QUEUE
// =====================================================================================
// - Queue structure:
// - 
// - [00] Number of queued items
// - [01] Queue start
// -
// - [00] sprite index (0-7)
// - [01] x
// - [02] y
// - [03] x high bit
// =====================================================================================
process_coordinate_queue:

	// Check if any items in the queue:
	ldx UMEM_SPRITE_COORD_QUEUE_START
	cpx #$00
	bne check_flagged_coordinates
	jmp return_process_coordinate_queue

  check_flagged_coordinates:
  	ldy UMEM_SPRITE_COORD_QUEUE_START + 1 				// Y = sprite index  	
  	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_COORD_START)
  	sty MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #OFF
  	beq begin_process_coordinate_queue
  	jmp return_process_coordinate_queue

  begin_process_coordinate_queue:
  	ldy UMEM_SPRITE_COORD_QUEUE_START + 1
    tya
  	asl
  	tay
  	lda UMEM_SPRITE_COORD_QUEUE_START + 2
  	sta UMEM_VIRTUAL_SPRITE_COORD_START + 1, y
  	lda UMEM_SPRITE_COORD_QUEUE_START + 3
  	sta UMEM_VIRTUAL_SPRITE_COORD_START + 2, y
  	:set_setbit_parameters(UMEM_VIRTUAL_SPRITE_COORD_START + $11, ON)
  	lda UMEM_SPRITE_COORD_QUEUE_START + 4
  	sta MMEM_ZERO_PAGE + 3
  	tya
  	lsr
  	sta MMEM_ZERO_PAGE + 2
  	jsr set_bit

  	// Flag the virtual sprite coordinate memory for processing:
  	:set_setbit_parameters(UMEM_VIRTUAL_SPRITE_COORD_START, ON)
  	lda UMEM_SPRITE_COORD_QUEUE_START + 1
  	sta MMEM_ZERO_PAGE + 2
  	jsr set_bit

  	// Advance the queue:
  	ldx UMEM_SPRITE_COORD_QUEUE_START
  	ldy #$01

  advance_sprite_coord_queue:
  	cpx #$01
  	beq decrement_sprite_coord_queue
  	lda UMEM_SPRITE_COORD_QUEUE_START + 4, y
  	sta UMEM_SPRITE_COORD_QUEUE_START, y
  	iny
  	lda UMEM_SPRITE_COORD_QUEUE_START + 4, y
  	sta UMEM_SPRITE_COORD_QUEUE_START, y
  	iny
  	lda UMEM_SPRITE_COORD_QUEUE_START + 4, y
  	sta UMEM_SPRITE_COORD_QUEUE_START, y
  	iny
  	lda UMEM_SPRITE_COORD_QUEUE_START + 4, y
  	sta UMEM_SPRITE_COORD_QUEUE_START, y
  	iny
  	dex
  	jmp advance_sprite_coord_queue

  decrement_sprite_coord_queue:
  	dec UMEM_SPRITE_COORD_QUEUE_START

  return_process_coordinate_queue:
  	rts

// =====================================================================================


// =====================================================================================
// GET ANIMATION FRAME
// =====================================================================================
// - Accumulator = sprite index
// - 
// - Stores animation frame in the accumulator
// =====================================================================================
get_animation_frame:

	// Capture parameter:
	sta UMEM_VARIABLES_DATA_START + 8

	// Anything in the animation queue?
	lda UMEM_SPRITE_ANIM_QUEUE_START
	cmp #$00
	bne search_anim_queue
	jmp search_anim_framebuffer

	// The queue has records in it. Search the queue for the most recently added record for this sprite index:
  search_anim_queue:
  	asl
  	tax
  	lda UMEM_SPRITE_ANIM_QUEUE_START - 1, x
  	cmp UMEM_VARIABLES_DATA_START + 8
  	beq read_anim_queue
  	txa
  	lsr
  	tax
  	dex
  	cpx #$00
  	beq search_anim_framebuffer
  	txa
  	jmp search_anim_queue

  	// Found a record for this sprite index in the queue. Read the frame from there:
  read_anim_queue:
  	lda UMEM_SPRITE_ANIM_QUEUE_START, x
  	jmp return_get_animation_frame

  	// Nothing found in the queue, look at the framebuffer to see if there is a pending update for this sprite:
  search_anim_framebuffer:
  	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_RAM_START)
  	lda UMEM_VARIABLES_DATA_START + 8
  	sta MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #$00
  	bne read_anim_framebuffer
  	jmp read_anim_live

  	// We found a pending update in the framebuffer. Get the frame from there:
  read_anim_framebuffer:
  	ldx UMEM_VARIABLES_DATA_START + 8
  	lda UMEM_VIRTUAL_SPRITE_RAM_START + 1, x
  	jmp return_get_animation_frame	

  	// Nothing in the queue or the framebuffer. Get the live frame:
  read_anim_live:
  	ldx UMEM_VARIABLES_DATA_START + 8
  	lda MMEM_SPRITE_RAM_START, x

  return_get_animation_frame:
  	rts

// =====================================================================================


// =====================================================================================
// GET COORDINATES
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - 
// - Stores:
// - ZERO_PAGE 		= x low
// - ZERO_PAGE + 1 	= y low
// - ZERO_PAGE + 2  = x high bit
// =====================================================================================
get_coordinates:

	// Capture zero-page:
	lda MMEM_ZERO_PAGE
	sta UMEM_VARIABLES_DATA_START

	// Anything in the coordinate queue?
	lda UMEM_SPRITE_COORD_QUEUE_START
	cmp #$00
	bne search_queue
	jmp search_framebuffer

	// The queue has records in it. Search the queue for the most recently added record for this sprite index:
  search_queue:
  	asl
  	asl
  	tax
  	lda UMEM_SPRITE_COORD_QUEUE_START - 3, x
  	cmp UMEM_VARIABLES_DATA_START
  	beq read_queue
  	txa
  	lsr
  	lsr
  	tax
  	dex
  	cpx #$00
  	beq search_framebuffer
  	txa
  	jmp search_queue

  	// Found a record for this sprite index in the queue. Read the coordinates from there:
  read_queue:
  	lda UMEM_SPRITE_COORD_QUEUE_START - 2, x
  	sta MMEM_ZERO_PAGE
  	lda UMEM_SPRITE_COORD_QUEUE_START - 1, x
  	sta MMEM_ZERO_PAGE + 1
  	lda UMEM_SPRITE_COORD_QUEUE_START, x
  	sta MMEM_ZERO_PAGE + 2
  	jmp return_get_coordinates

  	// Nothing found in the queue, look at the framebuffer to see if there is a pending update for this sprite:
  search_framebuffer:
  	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_COORD_START)
  	lda UMEM_VARIABLES_DATA_START
  	sta MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	cmp #$00
  	bne read_framebuffer
  	jmp read_live

  	// We found a pending update in the framebuffer. Get the coordinates from there:
  read_framebuffer:
  	:set_check_render_flag_parameters(UMEM_VIRTUAL_SPRITE_COORD_START + $11)
  	lda UMEM_VARIABLES_DATA_START
  	sta MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	sta MMEM_ZERO_PAGE + 2
  	asl
  	tax
  	lda UMEM_VIRTUAL_SPRITE_COORD_START + 1, x
  	sta MMEM_ZERO_PAGE
  	lda UMEM_VIRTUAL_SPRITE_COORD_START + 2, x
  	sta MMEM_ZERO_PAGE + 1
  	jmp return_get_coordinates

  	// Nothing in the queue or the framebuffer. Get the live coordinates:
  read_live:
  	:set_check_render_flag_parameters(MMEM_SPRITE_COORD_9TH_BIT)
  	lda UMEM_VARIABLES_DATA_START
  	sta MMEM_ZERO_PAGE + 2
  	jsr get_bit
  	sta MMEM_ZERO_PAGE + 2
  	lda UMEM_VARIABLES_DATA_START
  	asl
  	tax
  	lda MMEM_SPRITE_COORD_RAM_START, x
  	sta MMEM_ZERO_PAGE
  	lda MMEM_SPRITE_COORD_RAM_START + 1, x
  	sta MMEM_ZERO_PAGE + 1

  return_get_coordinates:
  	rts

// =====================================================================================


// =====================================================================================
// QUEUE ANIMATION UPDATE
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - ZERO_PAGE + 1 	= animation frame
// =====================================================================================
queue_animation_update:
	
	// Check how many records currently in the queue:
	lda UMEM_SPRITE_ANIM_QUEUE_START

	// Multiply the value by 2 to get the next queue position:
	asl
	tax

	// Write the new record to the queue:
	lda MMEM_ZERO_PAGE
	sta UMEM_SPRITE_ANIM_QUEUE_START + 1, x
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_SPRITE_ANIM_QUEUE_START + 2, x

	// Increment the queue counter:
	inc UMEM_SPRITE_ANIM_QUEUE_START

	rts

// =====================================================================================


// =====================================================================================
// QUEUE COORDINATE UPDATE
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - ZERO_PAGE + 1 	= x low
// - ZERO_PAGE + 2  = y low
// - ZERO_PAGE + 3  = x high bit
// =====================================================================================
queue_coordinate_update:
	
	// Check how many records currently in the queue:
	lda UMEM_SPRITE_COORD_QUEUE_START

	// Multiply the value by 4 to get the next queue position:
	asl
	asl
	tax

	// Write the new record to the queue:
	lda MMEM_ZERO_PAGE
	sta UMEM_SPRITE_COORD_QUEUE_START + 1, x
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_SPRITE_COORD_QUEUE_START + 2, x
	lda MMEM_ZERO_PAGE + 2
	sta UMEM_SPRITE_COORD_QUEUE_START + 3, x
	lda MMEM_ZERO_PAGE + 3
	sta UMEM_SPRITE_COORD_QUEUE_START + 4, x

	// Increment the queue counter:
	inc UMEM_SPRITE_COORD_QUEUE_START

	rts

// =====================================================================================


init_sprite_update_routines:
queue_x_coordinate_decrement:
	:create_animated_sprite_update_routine(SPRITE_LEFT)
queue_x_coordinate_increment:
	:create_animated_sprite_update_routine(SPRITE_RIGHT)
queue_y_coordinate_increment:
	:create_animated_sprite_update_routine(SPRITE_DOWN)
queue_y_coordinate_decrement:
	:create_animated_sprite_update_routine(SPRITE_UP)

	lda UMEM_INIT_INDICATOR_ADDR
	cmp #TRUE
	bne return_from_init_sprite_routines
	jmp game_loop

return_from_init_sprite_routines:
	rts
	

// =====================================================================================
// QUEUE MUNCH ANIMATION
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - ZERO_PAGE + 1 	= starting animation frame
// =====================================================================================
queue_munch_animation:
		
	// Save the sprite index:
	lda MMEM_ZERO_PAGE
	sta UMEM_VARIABLES_DATA_START 						// Variables + 0 = sprite index
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_VARIABLES_DATA_START + 1 					// Variables + 1 = starting animation frame
	ldy #SPRITE_MUNCH_STEP
	sty UMEM_VARIABLES_DATA_START + 2 					// Variables + 2 = sprite step size

  next_munch_sprite_update_step:
  	ldy UMEM_VARIABLES_DATA_START + 2 					// Y = sprite step size
  	cpy #$00 											// Have we processed all the steps?

	// If so, return to idle frame
	bne move_to_next_munch_step
	jmp munch_return_idle_frame	

  move_to_next_munch_step:
  	dey													// If not, move to the next step
  	sty UMEM_VARIABLES_DATA_START + 2	
	lda UMEM_VARIABLES_DATA_START 						// A = sprite index
	ldx #SPRITE_MUNCH_SPEED 							// X = frames per step

  continue_munch_animation:
  	// Queue the animation update:
	lda UMEM_VARIABLES_DATA_START  						// A = sprite index
	jsr get_animation_frame
	sta MMEM_ZERO_PAGE + 1 	 							// ZERO_PAGE + 1 = current animation frame
	sta UMEM_VARIABLES_DATA_START + 3					// Variables + 3 = current animation frame
	lda UMEM_VARIABLES_DATA_START + 1 					// A = starting animation frame
	sta UMEM_VARIABLES_DATA_START + 4	 				// Variables + 4 = starting animation frame
	sta UMEM_VARIABLES_DATA_START + 5 					// Variables + 5 = target
	
	// Find the target frame:
	ldx #SPRITE_MUNCH_ANIM_OFFSET						// X = frame location

  search_target_munch_frame:
	cpx #$00 											// Are we finished incrementing?
	beq queue_munch_frame_swap 							// If yes, queue the frame swap
	inc UMEM_VARIABLES_DATA_START + 5 					// Increment starting animation frame once per offset value to get the target
	dex 												// If not, continue incrementing
	jmp search_target_munch_frame

  queue_munch_frame_swap:
	lda UMEM_VARIABLES_DATA_START 						// A = sprite index
	sta MMEM_ZERO_PAGE 									// ZERO_PAGE = sprite index
	lda UMEM_VARIABLES_DATA_START + 5 					// Store the target as parameter 2
	sta MMEM_ZERO_PAGE + 1

  compare_munch_target:
	lda UMEM_VARIABLES_DATA_START + 3 					// A = current animation frame
	cmp UMEM_VARIABLES_DATA_START + 5 	 				// Compare to the target
	bne apply_munch_anim_queue_update 					// If the current frame is different from the target, proceed
	lda UMEM_VARIABLES_DATA_START + 4 					// If they're the same, set the target = starting frame
	sta MMEM_ZERO_PAGE + 1

  apply_munch_anim_queue_update:
	jsr queue_animation_update

	// Process the next step
	jmp next_munch_sprite_update_step 
	dex 												// Process next frame in this step
	cpx #$00 											// Have we finished processing all frames?
	bne continue_munch_animation						// If not, continue animation

  munch_return_idle_frame:
  	lda UMEM_VARIABLES_DATA_START
  	sta MMEM_ZERO_PAGE
  	lda UMEM_VARIABLES_DATA_START + 1
  	jsr queue_sprite_idle_frame

  	rts

// =====================================================================================


// =====================================================================================
// CREATE ANIMATED SPRITE UPDATE ROUTINE
// =====================================================================================
// - queue_x_coordinate_increment
// - queue_x_coordinate_decrement
// - queue_y_coordinate_increment
// - queue_y_coordinate_decrement
// -
// - ZERO_PAGE 		= sprite index
// - ZERO_PAGE + 1 	= starting animation frame
// =====================================================================================
.macro create_animated_sprite_update_routine(direction)
{
		// Init / execute switch:
		lda UMEM_INIT_INDICATOR_ADDR
		cmp #TRUE
		beq perform_update
		jmp return_from_init

	perform_update:
		// Save the sprite index:
		lda MMEM_ZERO_PAGE
		sta UMEM_VARIABLES_DATA_START 						// Variables + 0 = sprite index
		lda MMEM_ZERO_PAGE + 1
		sta UMEM_VARIABLES_DATA_START + 5 					// Variables + 5 = starting animation frame

		// Get the current grid position:
		jsr get_sprite_grid_position 						// ZERO_PAGE = X, ZERO_PAGE + 1 = Y
		lda MMEM_ZERO_PAGE + 1 								// A = sprite grid position Y
		sta UMEM_VARIABLES_DATA_START + 4 					// Variables + 4 = sprite grid position Y
		lda MMEM_ZERO_PAGE									// A = sprite grid position X
		sta UMEM_VARIABLES_DATA_START + 1 					// Variables + 1 = sprite grid position X

		// Are we already at the boundary?
	.if (direction == SPRITE_RIGHT)
	{
		cmp #SPRITE_MAX_X_GRID_POSITION
	}
	else .if (direction == SPRITE_LEFT)
	{
		cmp #$00
	}
	else .if (direction == SPRITE_DOWN)
	{
		lda UMEM_VARIABLES_DATA_START + 4
		cmp #SPRITE_MAX_Y_GRID_POSITION
	}
	else .if (direction == SPRITE_UP)
	{
		lda UMEM_VARIABLES_DATA_START + 4
		cmp #$00
	}
		
		bne continue_apply_coord_update
		jmp return_sprite_update

	  continue_apply_coord_update:

	  	// Is this the player?
	  	lda #SPRITE_PLAYER
	  	cmp UMEM_VARIABLES_DATA_START
	  	beq set_sprite_player
	  	lda #FALSE
	  	sta UMEM_VARIABLES_DATA_START + 9 					// Variables + 9 = is player (TRUE or FALSE)
	  	lda #SCREEN_GRID_ATTR_ISENEMY
	  	sta MMEM_ZERO_PAGE + 2
	  	jmp check_apply_coord_direction

	  set_sprite_player:
	  	lda #TRUE
	  	sta UMEM_VARIABLES_DATA_START + 9 					// Variables + 9 = is player (TRUE or FALSE)
	  	lda #SCREEN_GRID_ATTR_ISPLAYER
	  	sta MMEM_ZERO_PAGE + 2

	  check_apply_coord_direction:

	  	// Clear position flags for current grid coordinates:
	  	lda UMEM_VARIABLES_DATA_START + 1
	  	sta MMEM_ZERO_PAGE
	  	lda UMEM_VARIABLES_DATA_START + 4
	  	sta MMEM_ZERO_PAGE + 1
	  	lda #FALSE
	  	sta MMEM_ZERO_PAGE + 3
	  	jsr update_cell_attribute

	.if (direction == SPRITE_RIGHT || direction == SPRITE_LEFT)
	{
		ldy #SPRITE_X_STEP 								    // Y = SPRITE_X_STEP
	}
	else
	{
		ldy #SPRITE_Y_STEP									// Y = SPRITE_Y_STEP
	}

		sty UMEM_VARIABLES_DATA_START + 3 					// Variables + 3 = sprite step size

	  next_sprite_update_step:
	  	ldy UMEM_VARIABLES_DATA_START + 3 					// Y = sprite step size
	  	cpy #$00 											// Have we processed all the steps?

		// If so, increment the sprite's grid position
		bne move_to_next_coord_step
		jmp update_grid_position	

	  move_to_next_coord_step:
	  	dey													// If not, move to the next step
	  	sty UMEM_VARIABLES_DATA_START + 3	
		lda UMEM_VARIABLES_DATA_START + 4 					// A = sprite grid position Y
		sta UMEM_VARIABLES_DATA_START + 2 					// Variables + 2 = sprite grid position Y
		lda UMEM_VARIABLES_DATA_START 						// A = sprite index

		// Get the current coordinates:	
		sta MMEM_ZERO_PAGE 									// ZERO_PAGE = sprite index
		jsr get_coordinates 								// ZERO_PAGE = x, ZERO_PAGE + 1 = y, ZERO_PAGE + 2 = x_high_bit

	.if (direction == SPRITE_RIGHT || direction == SPRITE_LEFT)
	{
		ldx #SPRITE_X_SPEED									// X = x increments per step
	}
	else 
	{
		ldx #SPRITE_Y_SPEED									// X = y increments per step
	}

	.if (direction == SPRITE_RIGHT)
	{
	  do_x_increment:
	  	// Check if x-low is at max:
	  	lda #$FF  											// A = $FF
	  	cmp MMEM_ZERO_PAGE  								// Is X coordinate FF?
	  	beq check_x_high 									// If so, check x_high_bit
		inc MMEM_ZERO_PAGE 									// If not, increment X coordinate

	  continue_x_increment:
		dex 												// Process next increment in this step
		cpx #$00 											// Have we finished processing all increments?
		bne do_x_increment 									// If not, check the X coordinate again and increment
		jmp set_coord_update_params 						// If finished, queue the coordinate update

	  check_x_high:
	  	// Check if x-high is already on:
	  	lda #ON 											// A = ON
	  	cmp MMEM_ZERO_PAGE + 2 								// Check if x_high_bit = ON
	  	beq return_sprite_update							// If x_high_bit is already on, cancel the operation

	  inc_x_high:
	  	// Set x-high to on, set x-low to 0; return to increment routine:
	  	sta MMEM_ZERO_PAGE + 2 								// x_high_bit = ON
	  	lda #$00 											// A = $00
	  	sta MMEM_ZERO_PAGE 									// x coordinate = $00
	  	jmp continue_x_increment 							// Process next increment in this step
	}
	else .if (direction == SPRITE_LEFT)
	{
	  do_x_decrement:
		// Check if x-low is at min:
	  	lda #$00 											// A = $00
	  	cmp MMEM_ZERO_PAGE  								// Is X coordinate 00?
	  	beq check_x_high_dec								// If so, check x_high_bit
		dec MMEM_ZERO_PAGE 									// If not, decrement X coordinate	

	  continue_x_decrement:
		dex 												// Process next increment in this step
		cpx #$00 											// Have we finished processing all decrements?
		bne do_x_decrement 									// If not, check the X coordinate again and decrement
		jmp set_coord_update_params							// If finished, queue the coordinate update	

	  check_x_high_dec:
	  	// Check if x-high is already off:
	  	lda #OFF											// A = OFF
	  	cmp MMEM_ZERO_PAGE + 2 								// Check if x_high_bit = OFF
	  	beq return_sprite_update							// If x_high_bit is already off, cancel the operation

	  dec_x_high:
	  	// Set x-high to off, set x-low to $FF; return to decrement routine:
	  	sta MMEM_ZERO_PAGE + 2 								// x_high_bit = OFF
	  	lda #$FF 											// A = $FF
	  	sta MMEM_ZERO_PAGE 									// x coordinate = $00
	  	jmp continue_x_decrement 							// Process next decrement in this step
	}
	else .if (direction == SPRITE_DOWN)
	{
	  do_y_increment:
		inc MMEM_ZERO_PAGE + 1								// Increment Y coordinate
		dex 												// Process next increment in this step
		cpx #$00 											// Have we finished processing all increments?
		bne do_y_increment 									// If not, check the Y coordinate again and increment
		jmp set_coord_update_params 						// If finished, queue the coordinate update
	}
	else .if (direction == SPRITE_UP)
	{
	  do_y_decrement:
		dec MMEM_ZERO_PAGE + 1								// Decrement Y coordinate
		dex 												// Process next decrement in this step
		cpx #$00 											// Have we finished processing all decrements?
		bne do_y_decrement 									// If not, check the Y coordinate again and decrement
		jmp set_coord_update_params 						// If finished, queue the coordinate update
	}

	  set_coord_update_params:
		// Set coord update parameters:
		lda MMEM_ZERO_PAGE + 2 								// A = x_high_bit
		sta MMEM_ZERO_PAGE + 3 								// ZERO_PAGE + 3 = x_high_bit
		lda MMEM_ZERO_PAGE + 1 								// A = y coordinate
		sta MMEM_ZERO_PAGE + 2 								// ZERO_PAGE + 2 = y coordinate
		lda MMEM_ZERO_PAGE 									// A = x coordinate
		sta MMEM_ZERO_PAGE + 1 								// ZERO_PAGE + 1 = x coordinate

		// Queue the update:
		lda UMEM_VARIABLES_DATA_START 						// A = sprite index
		sta MMEM_ZERO_PAGE									// ZERO_PAGE = sprite index

		jsr queue_coordinate_update 						// Queue the update

		// Queue the animation update:
		lda UMEM_VARIABLES_DATA_START
		jsr get_animation_frame
		sta MMEM_ZERO_PAGE + 1 	 							// ZERO_PAGE + 1 = current animation frame
		sta UMEM_VARIABLES_DATA_START + 7					// Variables + 7 = current animation frame
		lda UMEM_VARIABLES_DATA_START + 5 					// A = starting animation frame
		sta UMEM_VARIABLES_DATA_START + 6	 				// Variables + 6 = starting animation frame
		sta UMEM_VARIABLES_DATA_START + 8 					// Variables + 8 = target
		
		// Find the target frame:
		ldx #direction 										// X = direction

	  search_target_frame:
		cpx #$00 											// Are we finished incrementing?
		beq queue_frame_swap 								// If yes, queue the frame swap
		inc UMEM_VARIABLES_DATA_START + 8 					// Increment starting animation frame once per direction value to get the target
		dex 												// If not, continue incrementing
		jmp search_target_frame

	  queue_frame_swap:
		lda UMEM_VARIABLES_DATA_START 						// A = sprite index
		sta MMEM_ZERO_PAGE 									// ZERO_PAGE = sprite index
		lda UMEM_VARIABLES_DATA_START + 8 					// Store the target as parameter 2
		sta MMEM_ZERO_PAGE + 1

	  compare_target:
		lda UMEM_VARIABLES_DATA_START + 7 					// A = current animation frame
		cmp UMEM_VARIABLES_DATA_START + 8 	 				// Compare to the target
		bne apply_anim_queue_update 						// If the current frame is different from the target, proceed
		inc MMEM_ZERO_PAGE + 1 								// If they're the same, increment the target

	  apply_anim_queue_update:
		jsr queue_animation_update

		// Process the next step
		jmp next_sprite_update_step 	

	  update_grid_position:
	  	// Update grid position:
	  	lda UMEM_VARIABLES_DATA_START
	  	sta MMEM_ZERO_PAGE
	  	lda UMEM_VARIABLES_DATA_START + 1
	  	sta MMEM_ZERO_PAGE + 1
	  	lda UMEM_VARIABLES_DATA_START + 2
	  	sta MMEM_ZERO_PAGE + 2

	.if (direction == SPRITE_RIGHT)
	{
	    inc MMEM_ZERO_PAGE + 1
	}
	else .if (direction == SPRITE_LEFT)
	{
		dec MMEM_ZERO_PAGE + 1
	}
	else .if (direction == SPRITE_DOWN)
	{
	    inc MMEM_ZERO_PAGE + 2
	}
	else .if (direction == SPRITE_UP)
	{
		dec MMEM_ZERO_PAGE + 2
	}

	    jsr set_sprite_grid_position

	return_sprite_update:
		// Queue idle frame:
		lda UMEM_VARIABLES_DATA_START
		sta MMEM_ZERO_PAGE
		lda UMEM_VARIABLES_DATA_START + 5
		sta MMEM_ZERO_PAGE + 1
		jsr queue_sprite_idle_frame

		rts

	return_from_init:
}
// =====================================================================================


// =====================================================================================
// QUEUE SPRITE IDLE FRAME
// =====================================================================================
// ZERO_PAGE 		= sprite index
// ZERO_PAGE + 1 	= starting animation frame
// =====================================================================================
queue_sprite_idle_frame:

	// Is this the player?
	lda #SPRITE_PLAYER
	cmp MMEM_ZERO_PAGE
	bne return_to_idle_frame

	// Yes, this is the player. Check if the player is in a populated cell:
	lda MMEM_ZERO_PAGE + 1
	pha
	jsr get_sprite_grid_position
	lda #SCREEN_GRID_ATTR_HASVALUE
	sta MMEM_ZERO_PAGE + 2
	jsr get_cell_attribute
	ldy #SPRITE_PLAYER
	tax
	sty MMEM_ZERO_PAGE
	pla
	sta MMEM_ZERO_PAGE + 1
	txa
	cmp #OFF
	beq return_to_idle_frame

	// Player is in a populated cell - swap the idle frame for the transparent frame:
	lda MMEM_ZERO_PAGE + 1
	clc
	adc #$0A
	sta MMEM_ZERO_PAGE + 1

  return_to_idle_frame:
	jsr queue_animation_update

	rts

// =====================================================================================


// =====================================================================================
// SET SPRITE GRID POSITION
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - ZERO_PAGE + 1 	= x
// - ZERO_PAGE + 2  = y
// =====================================================================================
set_sprite_grid_position:

	lda MMEM_ZERO_PAGE
	cmp #SPRITE_PLAYER
	beq set_sprite_grid_flag_player
	ldy #SCREEN_GRID_ATTR_ISENEMY

  perform_sprite_grid_pos_update:
	asl
	tax
	lda MMEM_ZERO_PAGE + 1
	sta UMEM_SPRITE_GRID_POS_START, x
	sta MMEM_ZERO_PAGE
	lda MMEM_ZERO_PAGE + 2
	sta UMEM_SPRITE_GRID_POS_START + 1, x
	sta MMEM_ZERO_PAGE + 1
	sty MMEM_ZERO_PAGE + 2
	lda #TRUE
    sta MMEM_ZERO_PAGE + 3
    jsr update_cell_attribute
	jmp return_set_sprite_grid_position

  set_sprite_grid_flag_player:
  	ldy #SCREEN_GRID_ATTR_ISPLAYER
  	jmp perform_sprite_grid_pos_update

  return_set_sprite_grid_position:
	rts

// =====================================================================================


// =====================================================================================
// GET SPRITE GRID POSITION
// =====================================================================================
// - ZERO_PAGE 		= sprite index
// - 
// - Returns:
// - ZERO_PAGE  	= x
// - ZERO_PAGE + 1  = y
// =====================================================================================
get_sprite_grid_position:

	lda MMEM_ZERO_PAGE
	asl
	tax
	lda UMEM_SPRITE_GRID_POS_START, x
	sta MMEM_ZERO_PAGE
	lda UMEM_SPRITE_GRID_POS_START + 1, x
	sta MMEM_ZERO_PAGE + 1

	rts

// =====================================================================================


// =====================================================================================
// INIT SPRITE SUBSYSTEM
// =====================================================================================
init_sprite_subsystem:

    jsr init_virtual_sprite_memory
    jsr init_sprite_update_routines
    jsr init_sprites
    jsr enable_renderer

    :set_parameters(SPRITE_PLAYER, $00, $00, NULL, NULL, NULL, NULL)
    jsr set_sprite_grid_position    

    // Save sprite pointers for quick retrieval later:
	lda #<Muncher_Idle
    sta MMEM_ZERO_PAGE
    lda #>Muncher_Idle
    sta MMEM_ZERO_PAGE + 1
    jsr get_sprite_pointer
    lda MMEM_ZERO_PAGE
    sta UMEM_SPRITE_PLAYER_POINTER_ADDR

    rts

// =====================================================================================