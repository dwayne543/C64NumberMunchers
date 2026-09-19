// =========================================================
// LOAD CHARACTER SCREEN
// =========================================================
// - Assumes that screen color data immediately follows 
// - character data.
// =========================================================
.macro 

load_character_screen(data_start_address)
{
    .var color_data_start_address = data_start_address + MMEM_SCREEN_RAM_LENGTH
    .var background_color_start_address = color_data_start_address + MMEM_SCREEN_RAM_LENGTH

    ldx #$FF                                    // Screen byte offset counter
    ldy #$00                                    // Y: Populate last 231 bytes if = 1

  screen_load_loop:                             // Copy game screen data to screen memory
    lda data_start_address,                 x
    sta MMEM_SCREEN_CHAR_RAM_START,         x
    lda color_data_start_address,           x
    sta MMEM_SCREEN_COLOR_RAM_START,        x
    lda data_start_address          + $100, x
    sta MMEM_SCREEN_CHAR_RAM_START  + $100, x
    lda color_data_start_address    + $100, x
    sta MMEM_SCREEN_COLOR_RAM_START + $100, x
    lda data_start_address          + $200, x
    sta MMEM_SCREEN_CHAR_RAM_START  + $200, x
    lda color_data_start_address    + $200, x
    sta MMEM_SCREEN_COLOR_RAM_START + $200, x
    cpx #231                                    // If we have reached 231, start loading in the last 231 bytes
    beq set_allow_load_end_bit

  load_end_data:
    cpy #$01
    bne check_counter
    lda data_start_address          + $300, x
    sta MMEM_SCREEN_CHAR_RAM_START  + $300, x
    lda color_data_start_address    + $300, x
    sta MMEM_SCREEN_COLOR_RAM_START + $300, x
  
  check_counter:                                // Loop for 255 offsets
    dex
    bne screen_load_loop
    lda data_start_address                      // Handle the 256th offset
    sta MMEM_SCREEN_CHAR_RAM_START
    lda color_data_start_address
    sta MMEM_SCREEN_COLOR_RAM_START
    jmp set_background_colors

  set_allow_load_end_bit:
    ldy #$01
    jmp load_end_data

  set_background_colors:
    ldx #$00
    lda background_color_start_address, x
    sta MMEM_SCREEN_BORDER
    inx
    lda background_color_start_address, x
    sta MMEM_SCREEN_BACKGROUND
}
// ===============================================================================


// ===============================================================================
// DISABLE CURSOR
// ===============================================================================
disable_cursor:

  lda #$01
  sta MMEM_CURSOR_CONTROL

  rts

// ===============================================================================


// ===============================================================================
// POPULATE GRID CELL
// ===============================================================================
// - ZERO_PAGE      = value address low byte
// - ZERO_PAGE + 1  = value address high byte
// - ZERO_PAGE + 2  = grid x
// - ZERO_PAGE + 3  = grid y
// ===============================================================================
populate_grid_cell:

    // Translate grid coordinates to screen memory address:
    lda MMEM_ZERO_PAGE
    sta UMEM_VARIABLES_DATA_START                   // Variables + 0 = string address low byte
    lda MMEM_ZERO_PAGE + 1
    sta UMEM_VARIABLES_DATA_START + 1               // Variables + 1 = string address high byte
    lda MMEM_ZERO_PAGE + 2
    sta UMEM_VARIABLES_DATA_START + 2               // Variables + 2 = x
    sta MMEM_ZERO_PAGE
    lda MMEM_ZERO_PAGE + 3
    sta UMEM_VARIABLES_DATA_START + 3               // Variables + 3 = y
    sta MMEM_ZERO_PAGE + 1
    jsr get_screen_address_for_grid_coordinates

    // Text strings are assumed to always be 5 characters long.

    // Store the string address. Zero page = screen address, Zero page + 2 = string address:
  apply_cell_text:
    lda UMEM_VARIABLES_DATA_START                   // Store string address in zero_page + 2
    sta MMEM_ZERO_PAGE + 2
    lda UMEM_VARIABLES_DATA_START + 1
    sta MMEM_ZERO_PAGE + 3

    ldy #$00

  apply_next_char:
    lda (MMEM_ZERO_PAGE + 2), y         // Read current string char
    sta (MMEM_ZERO_PAGE), y             // Store current string char on screen memory
    iny                                 // Read next char
    cpy #$05                            // Read 5 chars total
    bne apply_next_char

    // Update the cell attributes to indicate this cell is populated:    
    ldx UMEM_VARIABLES_DATA_START + 2
    ldy UMEM_VARIABLES_DATA_START + 3
    stx MMEM_ZERO_PAGE
    sty MMEM_ZERO_PAGE + 1
    lda #SCREEN_GRID_ATTR_HASVALUE
    sta MMEM_ZERO_PAGE + 2
    lda #ON
    sta MMEM_ZERO_PAGE + 3
    jsr update_cell_attribute

    rts

// ===============================================================================


// ===============================================================================
// UPDATE CELL ATTRIBUTE
// ===============================================================================
// ZERO_PAGE      = x
// ZERO_PAGE + 1  = y
// ZERO_PAGE + 2  = bit
// ZERO_PAGE + 3  = value
// ===============================================================================
update_cell_attribute:
    
    jsr get_attribute_offset_for_grid_x_y    
    lda #>UMEM_GRID_ATTRIBUTES_START
    sta MMEM_ZERO_PAGE + 1  
    jsr set_bit
    rts

// ===============================================================================


// ===============================================================================
// GET ATTRIBUTE OFFSET FOR GRID X Y
// ===============================================================================
// - ZERO_PAGE      = x
// - ZERO_PAGE + 1  = y
// - 
// - Places offset in accumulator, places the complete low byte of address in ZERO_PAGE
// ===============================================================================
get_attribute_offset_for_grid_x_y:

    ldx MMEM_ZERO_PAGE
    ldy MMEM_ZERO_PAGE + 1

    lda #<UMEM_GRID_ATTRIBUTES_START
    sta MMEM_ZERO_PAGE

  process_next_y:
    cpy #$00                              // Have we counted all the Y coordinates for this row yet?
    beq process_next_x                    // If so, advance the X coordinate and reset the Y coordinates
    inc MMEM_ZERO_PAGE
    dey
    jmp process_next_y

  process_next_x:
    cpx #$00                              // Have we counted all the X coordinates yet?
    beq return_get_attr_offset            // If so, we have found the byte offset.
    inc MMEM_ZERO_PAGE
    dex
    ldy #$04
    jmp process_next_y

  return_get_attr_offset:
    lda MMEM_ZERO_PAGE
    rts

// ===============================================================================


// ===============================================================================
// GET SCREEN ADDRESS FOR GRID COORDINATES
// ===============================================================================
// - ZERO_PAGE      = X
// - ZERO_PAGE + 1  = Y
// - 
// - Table structure:
// - [XX] [YY] [ADDR1] [ADDR2]
// - 
// - Stores address in zero page
// ===============================================================================
get_screen_address_for_grid_coordinates:

    ldx MMEM_ZERO_PAGE
    ldy MMEM_ZERO_PAGE + 1

    lda #$00

  seek_x_screen_addr:
    cpx #$00
    beq seek_y_screen_addr
    clc
    adc #($05 * $02)                  // Skip 5 rows, rows are 2 columns wide each
    dex
    jmp seek_x_screen_addr

  seek_y_screen_addr:
    cpy #$00
    beq return_screen_grid_addr
    clc
    adc #($01 * $02)                  // Skip 1 row, rows are 2 columns wide each
    dey
    jmp seek_y_screen_addr

  return_screen_grid_addr:
    ldx #<Tbl_Screen_Grid_Map
    stx MMEM_ZERO_PAGE
    ldx #>Tbl_Screen_Grid_Map
    stx MMEM_ZERO_PAGE + 1
    tay 
    lda (MMEM_ZERO_PAGE), y
    tax 
    iny
    lda (MMEM_ZERO_PAGE), y
    stx MMEM_ZERO_PAGE
    sta MMEM_ZERO_PAGE + 1

    rts

// ===============================================================================


// ===============================================================================
// GET GRID POSITION ADDRESS
// ===============================================================================
.function get_grid_position_address(x, y)
{
    .return SCREEN_GRID_DATA_START + ((SCREEN_ROW_OFFSET * SCREEN_GRID_ROW_SPACING) * y) + (SCREEN_GRID_COLUMN_SPACING * x)
}
// ===============================================================================