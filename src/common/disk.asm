// ===============================================================================
// LOAD FILE
// ===============================================================================
// - ZERO_PAGE      = Filename string address low byte
// - ZERO_PAGE + 1  = Filename string address high byte
// - ZERO_PAGE + 2  = Device number
// - 
// - Only supports embedded addressing
// ===============================================================================
load_file:

    // Set logical file details:
    lda #$01                              // Logical file number (arbitrary; 1-128)
    ldx MMEM_ZERO_PAGE + 2                // Device number
    ldy #TRUE                             // Addressing mode: TRUE = embedded, FALSE = overridden 
    jsr KRN_SET_LOGICAL_FILE_SYSTEM

    ldy #$00

  seek_load_filename_length:
    // Find the filename length:
    lda (MMEM_ZERO_PAGE), y 
    cmp #$00
    beq load_file_length_found
    iny
    jmp seek_load_filename_length

  load_file_length_found:
    tya                                   // Filename length
    ldx MMEM_ZERO_PAGE                    // Filename address low byte
    ldy MMEM_ZERO_PAGE + 1                // Filename address high byte
    jsr KRN_SET_FILE_NAME

    // Trigger Kernal load routine:
    lda #FALSE                            // FALSE = Load, TRUE = Verify
    jsr KRN_LOAD_FILE
    
    rts

// ===============================================================================