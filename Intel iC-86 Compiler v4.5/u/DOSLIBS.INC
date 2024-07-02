$save

/***********************************************************************/
  dos_std_in: PROCEDURE BYTE EXTERNAL;
  END dos_std_in;
/***********************************************************************/
  dos_std_out: PROCEDURE(ch) EXTERNAL;
    DECLARE ch BYTE;
  END dos_std_out;
/***********************************************************************/
  dos_aux_in: PROCEDURE BYTE EXTERNAL;
  END dos_aux_in;
/***********************************************************************/
  dos_aux_out: PROCEDURE(ch) EXTERNAL;
    DECLARE ch BYTE;
  END dos_aux_out;
/***********************************************************************/
  dos_prn_out: PROCEDURE(ch) EXTERNAL;
    DECLARE ch BYTE;
  END dos_prn_out;
/***********************************************************************/
  dos_direct_in: PROCEDURE BYTE EXTERNAL;
    /* 0FFh if input not ready, 0-0FEh otherwise */
  END dos_direct_in;
/***********************************************************************/
  dos_direct_out: PROCEDURE(ch) EXTERNAL;
    DECLARE ch BYTE;
    /* ch <> 0FFh */
  END dos_direct_out;
/***********************************************************************/
  dos_direct_in_noecho: PROCEDURE BYTE EXTERNAL;
  END dos_direct_in_noecho;
/***********************************************************************/
  dos_std_in_noecho: PROCEDURE BYTE EXTERNAL;
  END dos_std_in_noecho;
/***********************************************************************/
  dos_std_string_out: PROCEDURE(str) EXTERNAL;
    DECLARE str POINTER;
    DECLARE st$ based str (*) BYTE;
  END dos_std_string_out;
/***********************************************************************/
  dos_buffered_std_in: PROCEDURE(str) EXTERNAL;
    DECLARE str POINTER;
    DECLARE stc based str structure(
      len_in BYTE,  /* n+1 */
      len_out BYTE,  /* 1..n */
      str (1) BYTE,  /* string read */
      cr BYTE);  /* CR */
  END dos_buffered_std_in;
/***********************************************************************/
  dos_check_std_in: PROCEDURE BYTE EXTERNAL;
    /* 0FFh if input ready, 0 otherwise */
  END dos_check_std_in;
/***********************************************************************/
  dos_clear_and_std_in: PROCEDURE(type) BYTE EXTERNAL;
    DECLARE type BYTE;
    /* type = 1, 6, 7, 8, 0Ah */
  END dos_clear_and_std_in;
/***********************************************************************/
  dos_get_disk_transfer_address: PROCEDURE DWORD EXTERNAL;
  END dos_get_disk_transfer_address;
/***********************************************************************/
  dos_set_disk_transfer_address: PROCEDURE(dta) EXTERNAL;
    DECLARE dta POINTER;
  END dos_set_disk_transfer_address;
/***********************************************************************/
  dos_get_date: PROCEDURE(date) BYTE EXTERNAL;
    /* day of week, 0=sun..6=sat */
    DECLARE date POINTER;
    DECLARE dat based date structure(
      day BYTE,  /* 1..31 */
      month BYTE,  /* 1..12 */
      year WORD);  /* 1980..2099 */
  END dos_get_date;
/***********************************************************************/
  dos_set_date: PROCEDURE(date) BYTE EXTERNAL;
    /* 0FFh if date invalid, 0 otherwise */
    DECLARE date POINTER;
    DECLARE dat based date structure(
      day BYTE,  /* 1..31 */
      month BYTE,  /* 1..12 */
      year WORD);  /* 1980..2099 */
  END dos_set_date;
/***********************************************************************/
  dos_get_time: PROCEDURE(time) EXTERNAL;
    DECLARE time POINTER;
    DECLARE tim based time structure(
      hundredeths BYTE,  /* 0..99 */
      seconds BYTE,  /* 0..59 */
      minutes BYTE,  /* 0..59 */
      hours BYTE);  /* 0..23 */
  END dos_get_time;
/***********************************************************************/
  dos_set_time: PROCEDURE(time) BYTE EXTERNAL;
    /* 0FFh if time invalid, 0 otherwise */
    DECLARE time POINTER;
    DECLARE tim based time structure(
      hundredeths BYTE,  /* 0..99 */
      seconds BYTE,  /* 0..59 */
      minutes BYTE,  /* 0..59 */
      hours BYTE);  /* 0..23 */
  END dos_set_time;
/***********************************************************************/
  dos_get_verify: PROCEDURE BYTE EXTERNAL;
    /* 1 if verify is on, 0 otherwise */
  END dos_get_verify;
/***********************************************************************/
  dos_set_verify: PROCEDURE(mode) EXTERNAL;
    DECLARE mode BYTE;
    /* mode = 1 to turn on, 0 to turn off */
  END dos_set_verify;
/***********************************************************************/
  dos_version: PROCEDURE WORD EXTERNAL;
  END dos_version;
/***********************************************************************/
  dos_get_ctrl_break: PROCEDURE BYTE EXTERNAL;
    /* 1 if ctrl-break check is on, 0 otherwise */
  END dos_get_ctrl_break;
/***********************************************************************/
  dos_set_ctrl_break: PROCEDURE(mode) EXTERNAL;
    DECLARE mode BYTE;
    /* mode = 1 to turn on, 0 to turn off */
  END dos_set_ctrl_break;
/***********************************************************************/
  dos_get_vector: PROCEDURE(vector) DWORD EXTERNAL;
    DECLARE vector BYTE;
  END dos_get_vector;
/***********************************************************************/
  dos_set_vector: PROCEDURE(vector, handler) EXTERNAL;
    DECLARE vector BYTE, handler DWORD;
  END dos_set_vector;
/***********************************************************************/
  dos_get_disk_free_space: PROCEDURE(drive, info) WORD EXTERNAL;
    /* 0FFFFh if drive invalid, 0 otherwise */
    DECLARE drive BYTE, info POINTER;
    DECLARE inf based info structure(
      avail_clusters WORD,
      total_clusters WORD,
      bytes_per_sector WORD,
      sectors_per_cluster WORD);
  END dos_get_disk_free_space;
/***********************************************************************/
  dos_create_dir: PROCEDURE(name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_create_dir;
/***********************************************************************/
  dos_delete_dir: PROCEDURE(name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_delete_dir;
/***********************************************************************/
  dos_change_dir: PROCEDURE(name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_change_dir;
/***********************************************************************/
  dos_get_dir: PROCEDURE(drive, name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE drive BYTE, name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_get_dir;
/***********************************************************************/
  dos_create: PROCEDURE(file, name, attr) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file POINTER, name POINTER, attr WORD;
    DECLARE fil based file WORD;
    DECLARE nam based name (*) BYTE;
  END dos_create;
/***********************************************************************/
  dos_open: PROCEDURE(file, name, mode) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file POINTER, name POINTER, mode WORD;
    DECLARE fil based file WORD;
    DECLARE nam based name (*) BYTE;
    /* mode = 0 for read, 1 for write, 2 for update */
  END dos_open;
  DECLARE OPEN_READ_ONLY  LITERALLY '0';
  DECLARE OPEN_WRITE_ONLY LITERALLY '1';
  DECLARE OPEN_READ_WRITE LITERALLY '2';
/***********************************************************************/
  dos_close: PROCEDURE(file) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file WORD;
  END dos_close;
/***********************************************************************/
  dos_read: PROCEDURE(file, buff, count, actual) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file WORD, buff POINTER, count WORD, actual POINTER;
    DECLARE buf based buff (*) BYTE;
    DECLARE act based actual WORD;
  END dos_read;
/***********************************************************************/
  dos_write: PROCEDURE(file, buff, count, actual) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file WORD, buff POINTER, count WORD, actual POINTER;
    DECLARE buf based buff (*) BYTE;
    DECLARE act based actual WORD;
  END dos_write;
/***********************************************************************/
  dos_delete: PROCEDURE(name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_delete;
/***********************************************************************/
  dos_seek: PROCEDURE(file, mode, offset, actual) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE file WORD, mode BYTE, offset DWORD, actual POINTER;
    DECLARE act based actual DWORD;
    /* mode = 0 for beginning of file relative, 1 for current position */
    /* relative, and 2 for end of file relative */
  END dos_seek;
  DECLARE SEEK_FROM_BEG LITERALLY '0';
  DECLARE SEEK_RELATIVE LITERALLY '1';
  DECLARE SEEK_FROM_END LITERALLY '2';
/***********************************************************************/
  dos_get_attribute: PROCEDURE(name, attr) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER, attr POINTER;
    DECLARE nam based name (*) BYTE;
    DECLARE att based attr WORD;
  END dos_get_attribute;
  DECLARE ATTR_READ_ONLY LITERALLY '1';
  DECLARE ATTR_HIDDEN    LITERALLY '2';
/***********************************************************************/
  dos_set_attribute: PROCEDURE(name, attr) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER, attr WORD;
    DECLARE nam based name (*) BYTE;
  END dos_set_attribute;
/***********************************************************************/
  dos_allocate: PROCEDURE(segment, paragraphs, max_block) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE segment POINTER, paragraphs WORD, max_block POINTER;
    DECLARE seg based segment SELECTOR;
    DECLARE max based max_block WORD;
  END dos_allocate;
/***********************************************************************/
  dos_free: PROCEDURE(segment) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE segment SELECTOR;
  END dos_free;
/***********************************************************************/
  dos_set_block: PROCEDURE(segment, paragraphs, max_block) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE segment SELECTOR, paragraphs WORD, max_block POINTER;
    DECLARE max based max_block WORD;
  END dos_set_block;
/***********************************************************************/
  dos_exec: PROCEDURE(mode, name, parm) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE mode BYTE, name POINTER, parm POINTER;
    DECLARE nam based name (*) BYTE;
    DECLARE par based parm BYTE; /* depends on mode */
    /* mode = 0 to load and execute program, 3 to load overlay */
  END dos_exec;
  DECLARE EXEC_EXEC LITERALLY '0';
  DECLARE EXEC_LOAD LITERALLY '3';
/***********************************************************************/
  dos_exit: PROCEDURE(code) EXTERNAL;
    DECLARE code WORD;
  END dos_exit;
/***********************************************************************/
  dos_wait: PROCEDURE WORD EXTERNAL;
    /* exit code of sub-process */
  END dos_wait;
/***********************************************************************/
  dos_find_first: PROCEDURE(name, attr) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER, attr WORD;
    DECLARE nam based name (*) BYTE;
  END dos_find_first;
/***********************************************************************/
  dos_find_next: PROCEDURE(name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE name POINTER;
    DECLARE nam based name (*) BYTE;
  END dos_find_next;
/***********************************************************************/
  dos_rename: PROCEDURE(old_name, new_name) WORD EXTERNAL;
    /* 0 if successful, error code otherwise */
    DECLARE old_name POINTER, new_name POINTER;
    DECLARE old based old_name (*) BYTE;
    DECLARE new based new_name (*) BYTE;
  END dos_rename;
/***********************************************************************/
  dos_get_cs: PROCEDURE SELECTOR EXTERNAL;
    /* current cs register value */
  END dos_get_cs;
/***********************************************************************/
  dos_get_ds: PROCEDURE SELECTOR EXTERNAL;
    /* current ds register value */
  END dos_get_ds;
/***********************************************************************/
  dos_get_ss: PROCEDURE SELECTOR EXTERNAL;
    /* current ss register value */
  END dos_get_ss;
/***********************************************************************/
  dos_get_psp: PROCEDURE SELECTOR EXTERNAL;
    /* program segment prefix */
  END dos_get_psp;
/***********************************************************************/

$restore
