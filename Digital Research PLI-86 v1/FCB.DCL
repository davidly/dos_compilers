/******************************************************************************
* I B M   D O S   F i l e   C o n t r o l   B l o c k   D e c l a r a t i o n *
******************************************************************************/
/* Change FCB names as necessary; types should not be changed */
	1 fcb based(fcb_ptr),
		2 drive           fixed(7),
		2 name            character(8),
		2 type            character(3),
		2 current_block   bit(16),
		2 record_size     bit(16),
		2 file_size(2)    bit(16),
		2 date            bit(16),
		2 reserved(10)    bit(8),
		2 current_rec     bit(8),
		2 rand_rec_no(2)  bit(16);
