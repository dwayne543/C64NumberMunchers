// ====================================================
// TABLES
// ====================================================
.segment Tables



Tbl_Sprite_Colors:
// *******************************************************
//							Color			IsMulticolor *
// *******************************************************			
Sprite_Color_ID_1:	.byte 	COLOR_BLACK,	TRUE
// *******************************************************


Tbl_Sprite_Color_Map:
// *************************************************
// 		Sprite 					SpriteColorID 	   *
// *************************************************
.word	Muncher_Idle,			Sprite_Color_ID_1
// *************************************************


Tbl_Screen_Grid_Map:
// **********************************************************
//  X 	Y 					Address	 					    *
// **********************************************************
/* 	0	0 	*/ 	.word 		get_grid_position_address(0, 0)
/* 	0	1 	*/ 	.word 		get_grid_position_address(0, 1)
/* 	0	2 	*/ 	.word 		get_grid_position_address(0, 2)
/* 	0	3 	*/ 	.word 		get_grid_position_address(0, 3)
/* 	0	4 	*/ 	.word 		get_grid_position_address(0, 4)
/* 	1	0 	*/ 	.word 		get_grid_position_address(1, 0)
/* 	1	1 	*/ 	.word 		get_grid_position_address(1, 1)
/* 	1	2 	*/ 	.word 		get_grid_position_address(1, 2)
/* 	1	3 	*/ 	.word 		get_grid_position_address(1, 3)
/* 	1	4 	*/ 	.word 		get_grid_position_address(1, 4)
/* 	2	0 	*/ 	.word 		get_grid_position_address(2, 0)
/* 	2	1 	*/ 	.word 		get_grid_position_address(2, 1)
/* 	2	2 	*/ 	.word 		get_grid_position_address(2, 2)
/* 	2	3 	*/ 	.word 		get_grid_position_address(2, 3)
/* 	2	4 	*/ 	.word 		get_grid_position_address(2, 4)
/* 	3	0 	*/ 	.word 		get_grid_position_address(3, 0)
/* 	3	1 	*/ 	.word 		get_grid_position_address(3, 1)
/* 	3	2 	*/ 	.word 		get_grid_position_address(3, 2)
/* 	3	3 	*/ 	.word 		get_grid_position_address(3, 3)
/* 	3	4 	*/ 	.word 		get_grid_position_address(3, 4)
/* 	4	0 	*/ 	.word 		get_grid_position_address(4, 0)
/* 	4	1 	*/ 	.word 		get_grid_position_address(4, 1)
/* 	4	2 	*/ 	.word 		get_grid_position_address(4, 2)
/* 	4	3 	*/ 	.word 		get_grid_position_address(4, 3)
/* 	4	4 	*/ 	.word 		get_grid_position_address(4, 4)
/* 	5	0 	*/ 	.word 		get_grid_position_address(5, 0)
/* 	5	1 	*/ 	.word 		get_grid_position_address(5, 1)
/* 	5	2 	*/ 	.word 		get_grid_position_address(5, 2)
/* 	5	3 	*/ 	.word 		get_grid_position_address(5, 3)
/* 	5	4 	*/ 	.word 		get_grid_position_address(5, 4)
// **********************************************************
