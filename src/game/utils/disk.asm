// ===============================================================================
// LOAD FILE
// ===============================================================================
// - ZERO_PAGE      = Filename string address low byte
// - ZERO_PAGE + 1  = Filename string address high byte
// - ZERO_PAGE + 2  = Device number
// - 
// - Only supports embedded addresses
// ===============================================================================
load_file:

  seek_load_filename_length:
    // Find the filename length:
    ldy #$00
    lda (MMEM_ZERO_PAGE), y
    cmp #$00
    beq load_file_length_found
    iny
    jmp seek_load_filename_length

  load_file_length_found:
    tya
    ldx MMEM_ZERO_PAGE
    ldy MMEM_ZERO_PAGE + 1
    jsr KRN_SET_FILE_NAME

    // Set logical file details:
    lda #$01
    ldx MMEM_ZERO_PAGE + 2
    ldy #TRUE
    jsr KRN_SET_LOGICAL_FILE_SYSTEM

    // Trigger Kernal load routine:
    lda #FALSE
    jsr KRN_LOAD_FILE

    rts

// ===============================================================================