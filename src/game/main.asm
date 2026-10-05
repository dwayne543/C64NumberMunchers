#import "../common/const.asm"
#import "segdefs.asm"
#import "data/screen.asm"
#import "data/sprites.asm"
#import "data/tables.asm"
#import "data/sounds.asm"
.segment UtilityRoutines
#import "../common/disk.asm"
#import "game_logic.asm"
#import "utils/memory.asm"
#import "utils/input.asm"
#import "utils/screen.asm"
#import "utils/sprites.asm"
#import "utils/sound.asm"

#if DEBUG
#import "data/modes/data_multiples.asm"
.segment BasicUpstart
:BasicUpstart(main)
#endif

.segment Main
main:

    :set_init_started()
    
    :load_character_screen(UMEM_GAME_SCREEN_DATA_START)
    :init_score()

    jsr init_level
    jsr init_sprite_subsystem
    jsr initialize_rng_mode

    :set_parameters(<Muncher_Idle, >Muncher_Idle, SPRITE_PLAYER, $40, $43, OFF, NULL)
    jsr display_sprite

    jsr init_grid

    lda #SPRITE_PLAYER
    sta MMEM_ZERO_PAGE
    lda #$C0
    sta MMEM_ZERO_PAGE + 1
    jsr queue_sprite_idle_frame

    //ldx #$06
    //ldy #$05

  /* populate_next_row:
    dex
   populate_next_column:
    dey
    lda #<my_test_string
    sta MMEM_ZERO_PAGE
    lda #>my_test_string 
    sta MMEM_ZERO_PAGE + 1
    stx MMEM_ZERO_PAGE + 2
    sty MMEM_ZERO_PAGE + 3
    txa
    pha
    tya
    pha
    jsr populate_grid_cell
    pla
    tay
    pla
    tax
    cpy #$00
    bne populate_next_column
    ldy #$05
    cpx #$00
    bne populate_next_row*/

    :set_init_complete()

  game_loop:

    jsr process_sprite_queues
    jsr process_sound_queue
    jsr process_user_input

    /*ldx #$1E

    next_seed:
    txa
    pha
    jsr get_next_seed_location
    pla
    tax
    cpx #$00
    beq done
    dex
    .break
    jmp next_seed

    done: brk*/

/*
    lda #$00
    sta MMEM_ZERO_PAGE
    lda #$09
    sta MMEM_ZERO_PAGE + 1
    jsr get_random_number

    lda #$01
    sta MMEM_ZERO_PAGE + 2
    lda #<Multiples_Mode_Choices_OP2_Correct
    sta MMEM_ZERO_PAGE
    lda #>Multiples_Mode_Choices_OP2_Correct
    sta MMEM_ZERO_PAGE + 1
    jsr get_choice_address

    lda #$00
    sta MMEM_ZERO_PAGE + 2
    sta MMEM_ZERO_PAGE + 3
    jsr populate_grid_cell
    */

    jmp game_loop