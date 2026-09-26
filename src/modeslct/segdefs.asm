// ================================================
// SEGMENT DEFINITIONS 
// ================================================
// ****         FOR MODESEL SCREEN             ****
// ================================================

.segmentdef BasicUpstart 						[start=UMEM_BASIC_UPSTART_ADDRESS]
.segmentdef Main 		 						[start=UMEM_MAIN_CODE_ADDRESS] 
.segmentdef Tables								[start=UMEM_TABLES_DATA_START]
.segmentdef UtilityRoutines						[start=UMEM_UTILITY_ROUTINES_START]

// Output file map:
.file [name=MODESEL_FILE_NAME, 					segments="BasicUpstart, Main, Tables, UtilityRoutines"]