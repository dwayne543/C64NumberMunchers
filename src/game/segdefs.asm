// ================================================
// SEGMENT DEFINITIONS 
// ================================================
// ****            FOR GAME SCREEN             ****
// ================================================

#if DEBUG
.segmentdef BasicUpstart 						[start=UMEM_BASIC_UPSTART_ADDRESS]
#endif

.segmentdef Main 		 						[start=UMEM_MAIN_CODE_ADDRESS] 
.segmentdef Sprites 							[start=UMEM_SPRITE_DATA_START]
.segmentdef Screen 								[start=UMEM_GAME_SCREEN_DATA_START]
.segmentdef Tables								[start=UMEM_TABLES_DATA_START]
.segmentdef UtilityRoutines						[start=UMEM_UTILITY_ROUTINES_START]
.segmentdef Sounds 								[start=UMEM_SOUND_DATA_START]

// Output file map:
#if DEBUG
.segmentdef GameModeData						[start=UMEM_MODE_DATA_START]
.file [name=MAIN_FILE_NAME, 					segments="BasicUpstart, Main, Sprites, Screen, Tables, Sounds, UtilityRoutines, GameModeData"]
#else
.file [name=MAIN_FILE_NAME, 					segments="Main, Sprites, Screen, Tables, Sounds, UtilityRoutines"]
#endif