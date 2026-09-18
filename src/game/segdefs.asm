// ================================================
// SEGMENT DEFINITIONS 
// ================================================
// ****            FOR GAME SCREEN             ****
// ================================================

.segmentdef BasicUpstart 						[start=UMEM_BASIC_UPSTART_ADDRESS]
.segmentdef Main 		 						[start=UMEM_MAIN_CODE_ADDRESS] 
.segmentdef Sprites 							[start=UMEM_SPRITE_DATA_START]
.segmentdef Screen 								[start=UMEM_GAME_SCREEN_DATA_START]
.segmentdef Tables								[start=UMEM_TABLES_DATA_START]
.segmentdef UtilityRoutines						[start=UMEM_UTILITY_ROUTINES_START]
.segmentdef Choices								[start=UMEM_CHOICES_DATA_START]


// Output file map:
.file [name=MAIN_FILE_NAME, 					segments="BasicUpstart, Main, Sprites, Screen, Tables, UtilityRoutines, Choices"]