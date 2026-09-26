#if DEBUG
#else
	#import "../../../common/const.asm"
	.segmentdef GameModeData [start=UMEM_MODE_DATA_START]
	.file [name=MULTIPLES_MODE_DATA_FILE_NAME, segments="GameModeData"]
#endif

.segment GameModeData

Game_Mode_Data:
	
// **********************************************************************
// Level 			Correct Address Start		Incorrect Address Start *
// **********************************************************************
/* 01   */	.word	Level_1_Correct, 			Level_1_Incorrect
/* 02   */	.word	Level_2_Correct, 			Level_2_Incorrect
// **********************************************************************

Level_1_Correct:	
	.text "  2  " + "  4  " + "  6  " + "  8  " + "  10 " + "  12 " + "  14 " + "  16 " + "  18 " + "  20 "
Level_1_Incorrect:
	.text "  3  " + "  5  " + "  7  " + "  9  " + "  11 " + "  13 " + "  15 " + "  17 " + "  19 " + "  21 "

Level_2_Correct:	
	.text "  3  " + "  6  " + "  9  " + "  12  " + "  15 " + "  18 " + "  21 " + "  24 " + "  27 " + "  30 "
Level_2_Incorrect:
	.text "  4  " + "  5  " + "  7  " + "  8  " + "  10 " + "  11 " + "  13 " + "  14 " + "  16 " + "  17 " 
	.text "  19 " + "  20 " + "  22 " + "  23 " + "  25 " + "  26 " + "  28 " + "  29 " + "  31 " + "  32 "