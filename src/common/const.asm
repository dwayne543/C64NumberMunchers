// COMMENT OUT THIS LINE TO BUILD PRODUCTION VERSION
#define DEBUG


.const EXTENSION						= ".prg"

// ============================================
// NAME OF MAIN FILE PRODUCED TO GO ON THE DISK
// ============================================
#if DEBUG
.const MAIN_FILE_NAME					= "main" + EXTENSION
.const MODESEL_FILE_NAME  				= MAIN_FILE_NAME
#else
.const MAIN_FILE_NAME 					= "game" + EXTENSION
.const MODESEL_FILE_NAME 				= "modeslct" + EXTENSION
#endif

.const MULTIPLES_MODE_DATA_FILE_NAME 	= "datmode0" + EXTENSION
// ============================================


// ============================================
// ADDRESS MAP - USER SPACE
// ============================================
.const UMEM_BASIC_UPSTART_ADDRESS 		= $0801
.const UMEM_MAIN_CODE_ADDRESS	  		= $0810
.const UMEM_SPRITE_DATA_START     		= $3000
.const UMEM_GAME_SCREEN_DATA_START		= $8000
.const UMEM_SOUND_DATA_START 			= $7F00
.const UMEM_TABLES_DATA_START			= $7000
.const UMEM_VARIABLES_DATA_START		= $6000
.const UMEM_ZERO_PAGE_TRANSFER_START	= $6050
.const UMEM_SPRITE_ANIM_QUEUE_START		= $6100
.const UMEM_SPRITE_COORD_QUEUE_START	= $6200
.const UMEM_VIRTUAL_SPRITE_RAM_START	= $6300
.const UMEM_VIRTUAL_SPRITE_COORD_START  = $6310
.const UMEM_SOUND_QUEUE_START 			= $6600
.const UMEM_SCORE_START_ADDRESS			= $07A1
.const UMEM_BREAKPOINT_CONDITION_ADDR 	= $5FFE
.const UMEM_INIT_INDICATOR_ADDR 		= $5FDF
.const UMEM_SPRITE_GRID_POS_START		= $5FE0
.const UMEM_INTERRUPT_VARIABLES_START   = $5FC0
.const UMEM_SPRITE_PLAYER_POINTER_ADDR  = $5FB0
.const UMEM_UTILITY_ROUTINES_START	 	= $0A00
.const UMEM_GAME_MODE_ADDR				= $2FFF
.const UMEM_SCORE_ADDR   				= $2FFD
.const UMEM_LEVEL_ADDR 					= $2FFC
.const UMEM_GRID_SEED_ADDR				= $2FBC
.const UMEM_SEED_COUNTER_ADDR			= $2FBB
.const UMEM_MODE_DATA_START				= $9000
.const UMEM_GRID_ATTRIBUTES_START		= $5F90
// ============================================


// ============================================
// ADDRESS MAP - MACHINE SPACE
// ============================================
.const MMEM_SCREEN_CHAR_RAM_START 		= $0400   // Screen RAM for character mode starts at $0400
.const MMEM_SCREEN_COLOR_RAM_START		= $D800   // Screen color RAM for character mode starts at $D800
.const MMEM_SCREEN_RAM_LENGTH 			= 1000    // Screen RAM in character mode has 1,000 positions = 1,000 bytes of RAM each (char and color data)
.const MMEM_SCREEN_BORDER				= $D020
.const MMEM_SCREEN_BACKGROUND			= $D021
.const MMEM_SPRITE_RAM_START			= $07F8
.const MMEM_SPRITE_COORD_RAM_START		= $D000 
.const MMEM_SPRITE_COORD_9TH_BIT		= $D010 
.const MMEM_SPRITE_TOGGLE				= $D015
.const MMEM_SPRITE_COLOR_RAM_START		= $D027
.const MMEM_SPRITE_COLOR_MODE			= $D01C
.const MMEM_SPRITE_MULTICOLOR_1			= $D025
.const MMEM_SPRITE_MULTICOLOR_2			= $D026
.const MMEM_ZERO_PAGE					= $0002
.const MMEM_LAST_KEY_PRESSED			= $00CB
.const MMEM_CURSOR_CONTROL				= $00CC
.const MMEM_VOLUME_CONTROL 			= $D418
// ============================================


// ============================================
// KERNAL ROUTINE ADDRESSES
// ============================================
.const KRN_SET_LOGICAL_FILE_SYSTEM 		= $FFBA
.const KRN_SET_FILE_NAME				= $FFBD
.const KRN_LOAD_FILE   					= $FFD5
.const KRN_READ_KEY 					= $FFE4
.const KRN_HANDLE_INTERRUPTS			= $EA31	
// ============================================


// ============================================
// COLOR CONSTANTS
// ============================================
.const COLOR_BLACK						= $00
.const COLOR_WHITE						= $01
.const COLOR_RED						= $02
.const COLOR_CYAN						= $03
.const COLOR_PURPLE						= $04
.const COLOR_GREEN						= $05
// ============================================


// ============================================
// SPRITE CONSTANTS
// ============================================
.const SPRITE_UP 						= $07
.const SPRITE_DOWN						= $05
.const SPRITE_LEFT 						= $03
.const SPRITE_RIGHT						= $01
.const SPRITE_1							= $00
.const SPRITE_2							= $01
.const SPRITE_3							= $02
.const SPRITE_4							= $03
.const SPRITE_5							= $04
.const SPRITE_6							= $05
.const SPRITE_7							= $06
.const SPRITE_8							= $07
.const SPRITE_MULTICOLOR_1				= COLOR_WHITE
.const SPRITE_MULTICOLOR_2				= COLOR_GREEN
.const SPRITE_COORD_OFFSET_ADDR			= $02
.const SPRITE_DIRECTION_ADDR			= $01
.const SPRITE_DECREMENT_ADDR			= $04
.const SPRITE_LOW_BYTE_ADDR				= $03
.const SPRITE_INDEX_ADDR				= $00
.const SPRITE_STEP_ADDR					= $05
.const SPRITE_CURRENT_STEP_ADDR			= $06
.const SPRITE_IDLE_ADDR					= $07
.const SPRITE_ANIM_FRAME_ADDR			= $08
.const SPRITE_ANIM_BUFFER_ADDR			= $09
.const SPRITE_ANIM_QUEUE_BUFFER_ADDR	= $0A 				// (x5)
.const SPRITE_PLAYER 	 				= SPRITE_1
.const SPRITE_X_STEP					= $08
.const SPRITE_Y_STEP					= $08
.const SPRITE_X_SPEED					= $06
.const SPRITE_Y_SPEED					= $04
.const SPRITE_MAX_X_GRID_POSITION		= $05
.const SPRITE_MAX_Y_GRID_POSITION		= $04
.const SPRITE_MUNCH_ANIM_OFFSET 		= $09
.const SPRITE_MUNCH_STEP				= $08
.const SPRITE_MUNCH_SPEED				= $06
// ============================================


// ============================================
// MEMORY CONSTANTS
// ============================================
.const MEMORY_SET_BIT_ADDRESS_ADDR		= $00
// ============================================


// ============================================
// BOOL CONSTANTS
// ============================================
.const TRUE								= $01
.const FALSE							= $00
.const ON 								= TRUE
.const OFF 								= FALSE
.const NULL								= "NULL"
// ============================================


// ============================================
// KEYBOARD CONTROL CONSTANTS
// ============================================
.const KEY_UP 							= $49  		// I
.const KEY_RIGHT 						= $4B 		// K
.const KEY_DOWN							= $4D 		// M
.const KEY_LEFT							= $4A		// J
.const KEY_SPACE  						= $10 		// SPACE
.const KEY_CONTINUE_BREAKPOINT			= KEY_LEFT
.const KEY_INPUT_LOCK_CYCLES			= $20
.const KEY_INPUT_LOCK_PASSES			= $1A
// ============================================


// ============================================
// SCREEN CONSTANTS
// ============================================
.const SCREEN_ROW_OFFSET 				= 40 		// 40 display chars per line
.const SCREEN_GRID_FIRST_ROW 			= 3 		// Grid data starts on the 4th row (0-indexed)
.const SCREEN_GRID_FIRST_COLUMN 		= 4 		// Grid data starts on the 5th column (0-indexed)
.const SCREEN_GRID_ROW_SPACING  		= 4 		// Each grid row is 4 units apart from the last
.const SCREEN_GRID_COLUMN_SPACING 		= 6 		// Each grid column is 6 units apart from the last
.const SCREEN_GRID_DATA_START 			= MMEM_SCREEN_CHAR_RAM_START + (SCREEN_ROW_OFFSET * SCREEN_GRID_FIRST_ROW) + SCREEN_GRID_FIRST_COLUMN
.const SCREEN_GRID_ATTR_HASVALUE		= $00
.const SCREEN_GRID_ATTR_ISCORRECT		= $01
.const SCREEN_GRID_ATTR_ISPLAYER		= $02
.const SCREEN_GRID_ATTR_ISENEMY			= $03
.const SCREEN_GRID_ATTR_ISSAFE			= $04
// ============================================


// ============================================
// GAME MODE CONSTANTS
// ============================================
.const GAME_MODE_MULTIPLES 				= $00
.const GAME_MODE_FACTORS				= $01
.const GAME_MODE_PRIMES					= $02
.const GAME_MODE_EQUALITY				= $03
.const GAME_MODE_INEQUALITY				= $04
// ============================================