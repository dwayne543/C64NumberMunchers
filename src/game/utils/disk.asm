// =====================================================================================
// LOAD FILE
// =====================================================================================
// - Execute the disk load operation
// - Parameter 1: Filename string
// - Parameter 2: Secondary addresses (1 = use file's embedded address; 0 = force custom address)
// - Parameter 3: Target Address (Only read if Parameter 2 is set to 0)
// =====================================================================================
.macro

load_file(filename, secondary_addr, target_addr)
{
    // 1. Set the filename parameters
    lda #filename_end - filename_start  // Calculate filename length dynamically
    ldx #<filename_start
    ldy #>filename_start
    jsr KRN_SET_FILE_NAME
    
    // 2. Set up logical file details
    lda #$01                            // Logical file number (arbitrary value 1-127)
    ldx #$08                            // Device number (default disk drive is 8)
    ldy #secondary_addr                 // 1 = load to file header address, 0 = load to custom address
    jsr KRN_SET_LOGICAL_FILE_SYSTEM
    
    // 3. Trigger the KERNAL load routine
    lda #$00                            // 0 = LOAD operation (1 = VERIFY operation)
    ldx #<target_addr                   // Low byte of destination (Ignored if secondary_addr = 1)
    ldy #>target_addr                   // High byte of destination (Ignored if secondary_addr = 1)
    jsr KRN_LOAD_FILE
    jmp macro_end
    
  filename_start:
    .text filename                      // Kick Assembler raw text directive
    
  filename_end:

  macro_end:
}
// ===============================================================================