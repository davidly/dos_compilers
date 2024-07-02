/********************************************

	dbgmap - conversion utily for
	Aztec C

	This utility converts an Aztec C
	symbol table file (.DBG) into a
	RDSD compatible symbol file (.MAP).

	Paul McClintock   April 21, 1987

	Last Edit         April 21, 1987

	(c) Lines Unlimited  April 1987

*******************************************/


/******************************************

The following definition of the Aztec .DBG 
file is the results of a phone coversation with
Tom Ferwick of Aztec.  The .DBG file is a 
complex binary symbol file containing substancially
more data then the Microsoft .MAP file is able
to contain.

The .DBG file format is based on 64 byte records.
Each record type has a unique structure.



HEADER RECORD :
    type_def		dw	13678		; 0356Eh
    num_struct		dw			; number of structure records
    start_struct	dw			; starting record # for struct

    num_strings		dw			; total # of strings
    total_string_lnth	dw			; total string table length
    start_string	dw			; starting record for strings

    num_src_line_rec 	dw			; number of src line records
    num_block_rec	dw			; number of block records
    num_sym_rec		dw			; number of symbol records

    						; offsets into symbol data
    s_abs_symbol	dw			; 1st aboslute symbol
    s_code_symbol	dw			; 1st code symbol
    s_data_symbol	dw			; 1st data symbol


SYMBOL RECORD :
    type_def		dw	15431		; 03C47h

    name_idx		dw			; name string subscript
    type_idx		dw			; type string subscript
    struct_idx		dw			; index into struct table
    add_offset		dw			; 
    add_segment		dw			; also used as a flag word

	    -2 = Auto variable     BP.[add_offset]
	    -3 = Register variable 
	         add_offset == 5 for SI
                 add_offset == 6 for DI
	    -4 = argument          BP.[add_offset]
	    -5 = argument, Register variable
	    -6 = TYPE DEF name




        Type Strings Modifers
	    *      = 16 Bit Pointer
	    #      = 32 Bit Pointer
	    [size  = size of array
	    (      = Near Function
	    {      = Far Function


	Base Type Characters
	    c      = char
	    C      = unsigned char
	    i      = int
	    I      = unsigned int
	    l      = long
	    L      = unsigned int
	    f      = float
	    D      = double
	    V      = void
	    :      = struct



SOURCE LINE RECORD :
    type_def		dw	12345		; 3039h

    add_offset		dw			; starting address offset
    add_segment		dw			; starting address segment
    file_name		dw			; file name string subscript
    line_number		dw			; starting source line number
    object_displacement	db			; obj code displacement / line

        Special flag bit
	    0FFH         == end of obj offsets array
	    00h to 07Fh  == 8 bit object code displacement
	    080h to 0FEh == 15 bit object code displacement




SYMBOL SCOPE DEF RECORD :
    type_def		dw	15432		; 03C48h (BLOCK)

    Unknown record format





STRUCT DEF RECORD :
						; no type_def
						; 
    name_idx		dw			; name string subscript
    type_idx		dw			; type string subscript
    struct_idx		dw			; index into struct table
    add_segment		dw			; also used as a flag word



*******************************************/

#include <stdio.h>

#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include <stdlib.h>

#include <malloc.h>
#include <string.h>


/*  .DBG  Header record  */

struct HEADER 
{
    unsigned int	type_def,		/* 13678 */
    			num_struct,		/* nuber of struct records */
			start_struct,		/* starting record for struct */

			num_strings,		/* total num of strings */
			tot_str_lnth,		/* total strings length */
			start_string,		/* starting record for string */

			num_src_rec,		/* total src records */
			num_block_rec,		/* total block records */
			num_sym_rec,		/* total symbol records */

			s_abs_sym,		/* starting abs symbol */
			s_code_sym, 		/* starting code symbol */
			s_data_sym; 		/* starting data symbol */

	unsigned int	fill[20];		/* total size of 64 bytes */

};


/*  Public Symbols */

struct SYMBOL 
{
    unsigned int	name_idx,		/* symbol name index */
			type_idx,		/* symbol type index */
			struct_idx,		/* index into struct table */
			add_offset,		/* address offset value */
			add_segment;		/* address segment value */
};

struct SYM_RECORD 
{
    unsigned int	type_def;		/* 15431 */
    struct SYMBOL	sym_data[6];
    unsigned int	fill[1];		/* total size of 64 bytes */
};


/*  Internal Format */

struct SYM_DATA
{
    struct SYM_DATA	*next;			/* linked list */

    unsigned int	name_idx,		/* symbol name index */
			type_idx,		/* symbol type index */
			add_offset,		/* address offset value */
			add_segment,		/* address segment value */
			struct_idx;		/* index into struct table */
};




#define RECORDSIZE 64
#define LINEENTRY (RECORDSIZE - 5*sizeof(short))


/*  Source Line numbers */

struct SRC_RECORD
{
    unsigned short	type_def,		/* 12345 */
    			add_offset,		/* address offset value */
			add_segment,		/* address segment value */
			file_idx,		/* function's src file index */
			line_num;		/* starting line number */

    unsigned char	obj_displ[LINEENTRY];	/* object code displacement */

};



/*  internal format  */
struct SRC_DATA
{
    struct SRC_DATA	*next;		/* linked list */

    unsigned int	file_idx,		/* src file index */
    			line_num,		/* specified line number */
			add_offset,
			add_segment;
};



/*  Global DATA */

struct HEADER 		dbg_header;			

struct SYM_DATA		*sym_list = NULL;	/* header for linked list */
int			sym_count = 0;		/* number of entries */
unsigned short		max_symbol ;		/* max valid symbol index */

struct SRC_DATA		*src_list = NULL;	/* header for linked list */
int			src_count = 0;		/* number of entries */

char			**str_idx, *str_buff;	/* string buffer pointers */
char			*dbg_file, *map_file;   /* file paths */

char	  		*filename() ;




main (argc, argv)
int	argc;		/* number of paramiters */
char	**argv;		/* array of paramiters */
{
    int		  count ;		/* loop counter */
    unsigned int  *buff ;		/* input buffer */

    int		  dbg ;			/* input file handle */
    int		  error ; 		/* file operations return value */

    FILE	*map ;			/* output map file */


    printf("\nAztec .DBG to Microsoft compatible .MAP symbol file converter");
    printf("\n(c) Lines Unlimited  8-24-87 \n");

    if (argc != 2)
    {
	printf("\n\nusage: dbgmap filename");
	exit(1);
    }

    ++argv;			/* skip command name */
    dbg_file = filename( *argv, ".dbg");
    map_file = filename( *argv, ".map");

    dbg = open( dbg_file, O_RDONLY | O_BINARY);
    if (dbg == -1)
        err_abort(dbg_file);		/* abort on error */

    /*  Read header record */
    error = read( dbg, &dbg_header, sizeof(struct HEADER) );
    if (error == -1)
      err_abort(dbg_file);		/* abort on read error */

    buff = (int *) malloc(64);			/* block buffer */
    if (buff == NULL)
        err_abort("buff - out of memory ");

    max_symbol = 0xffff	; 		/* initialize */


    /*  build data structures from the .DBG file */

    for (count = dbg_header.start_struct - 1 ; count ; --count)
    {
        error = read( dbg, buff, 64);
	if (error == -1)
	    err_abort( dbg_file);

	switch (*buff)			/* type_def */
	{
	    case 15431 :		/* SYMBOL RECORD */
	        save_symbols( buff);
		break;

	    case 12345 :		/* SOURCE LINE RECORD */
	        save_src_line( buff);
		break;

	}

    }

    free(buff);
    read_strings( dbg);			/* read in strings */


    /*  Time to generate the .MAP file */

    map = fopen ( map_file, "w");
    if (map == NULL)
        err_abort ( map_file);


    print_symbols ( map);
    print_src_data ( map);

    if ( fclose ( map) )
        err_abort( map_file);

    exit (0);


}


save_symbols ( buff)
struct SYM_RECORD *buff;
{
  int  			count;
  struct SYMBOL		*c_symbol;
  struct SYM_DATA	*tmp;


  c_symbol = buff->sym_data;

  for (count = 0 ; count < 6 ; ++count, ++c_symbol)
  {
      if ( c_symbol->name_idx < dbg_header.num_strings )
      {
          tmp = (struct SYM_DATA *) malloc(sizeof(struct SYM_DATA) );
	  if (tmp == NULL)
	      err_abort( "save_symbols - out of memory ");

	  tmp->name_idx    = c_symbol->name_idx;
	  tmp->type_idx    = c_symbol->type_idx;
	  tmp->add_offset  = c_symbol->add_offset;
	  tmp->add_segment = c_symbol->add_segment;
	  tmp->struct_idx  = c_symbol->struct_idx;

	  if ((tmp->type_idx < max_symbol) && (tmp->type_idx != 0 ) )
	      max_symbol = tmp->type_idx ; 	/* type strings follow global
	      					   symbols strings */

	  /*  add to linked list in memory */
	  tmp->next = sym_list;
	  sym_list = tmp;		/* update linked list */
	  ++sym_count;

      }
  }
}

print_symbols( map)
FILE *map;				/* output file descriptor */
{
    struct SYM_DATA **idx, **tmp, *cur;
    int		    count, tot_sym ;
    int		    sym_by_name(), sym_by_value();

    tmp = idx = (struct SYM_DATA **) 
          malloc( sizeof(struct SYM_DATA) * (sym_count + 1) ) ;
    if (idx == NULL)
        err_abort("print_symbols - out of memory ");


    /* generate index for quick sort */
    for ( tot_sym = 0 , cur = sym_list; cur != NULL ; cur = cur->next )
    {
        if ( ( cur->add_segment < (unsigned) -6 ) &&
	    (cur->name_idx  < max_symbol ) )
	{
            *tmp++ = cur ;
	    ++tot_sym ;
	}
    }
    *tmp = NULL ;

    fprintf ( map, "\n\n  Address         Publics by Name\n");
    qsort ( idx, tot_sym, sizeof(struct SYM_DATA *), sym_by_name );
    for ( tmp = idx; *tmp ; ++tmp)
    {
        fprintf( map, "\n %04X:%04X       %s", (*tmp)->add_segment, 
	    (*tmp)->add_offset, str_idx[ (*tmp)->name_idx] );

    }


    fprintf ( map, "\n\n  Address         Publics by Value\n");
    qsort ( idx, tot_sym, sizeof(struct SYM_DATA *), sym_by_value );
    for ( tmp = idx; (*tmp) ; ++tmp)
    {
        fprintf( map, "\n %04x:%04x       %s", (*tmp)->add_segment, 
	    (*tmp)->add_offset, str_idx[ (*tmp)->name_idx] );

    }

    free(idx);		/* return to free memory */
}


sym_by_name(a, b)
struct SYM_DATA **a, **b;
{
    return ( strcmp( str_idx[ (*a)->name_idx], str_idx[ (*b)->name_idx]) );
}

sym_by_value ( a, b)
struct SYM_DATA **a, **b;
{
    long  a_add, b_add, add_to_long() ;
    int   ret_value;

    a_add = add_to_long( (*a)->add_segment, (*a)->add_offset);
    b_add = add_to_long( (*b)->add_segment, (*b)->add_offset);

    (a_add == b_add) ? ( ret_value = 0) : 
        ((a_add < b_add) ?  (ret_value = -1) : (ret_value = 1) ) ;

    return (ret_value);

}

long  add_to_long ( segment, offset)
unsigned int  segment, offset;
{
    long  ret_value ;

    ret_value  = (long) segment << 4 ;
    ret_value += (long) offset ;

    return (ret_value);
}




save_src_line ( src)
struct SRC_RECORD *src;
{
    unsigned char	*obj_offset;
    int			cnt ;


    store_src ( src);		/* save start of function */

    /*  Process the source lines for this function */
    /*  each offset byte represents a source line  */

    for ( obj_offset = src->obj_displ , cnt = 0 ; cnt < LINEENTRY ;
          ++obj_offset, ++src->line_num, ++cnt )
    {
	if ( *obj_offset)
	{
	    if (*obj_offset == 0xff)
	        break ;					/* end of table */

            store_src ( src);

            if ( *obj_offset < 0x80 )
	        src->add_offset += *obj_offset ;	/* additional offset */
            else
	    {
	        /*  15 bit object code offset */

	        *obj_offset     &= 0x7f ;		/* mask off flag bit */
	        src->add_offset += ( *obj_offset++ << 8) ;/* high 7 bits */
	        src->add_offset += *obj_offset ;	/* low 8 bits  */
	    }
	}
    }
}


store_src ( src)
struct SRC_RECORD *src;
{
    struct SRC_DATA  *tmp;

    tmp = (struct SRC_DATA *) malloc( sizeof(struct SRC_DATA)) ;
    if (tmp == NULL)
        err_abort( "store_src - out of memory ");

    /*  copy to memory storage */

    tmp->add_offset  = src->add_offset ;
    tmp->add_segment = src->add_segment ;
    tmp->line_num    = src->line_num ;
    tmp->file_idx    = src->file_idx ;

    if (tmp->file_idx < max_symbol)
        max_symbol = tmp->file_idx; 		/* global symbols proceed
						   file names in the string
						   table  */

    /* add to linked list */
    tmp->next        = src_list ;
    src_list         = tmp ;
    ++src_count ;

}

print_src_data( map)
FILE  *map;
{
    struct SRC_DATA  **tmp, **idx, *cur;
    int		     src_data_cmp();
    char	     *src_file, *obj_file;
    int		     count ;

    /* generate source line data index  */
    tmp = idx = (struct SRC_DATA **) 
        malloc( sizeof(struct SRC_DATA *) * (src_count + 1) ) ;
    if (idx == NULL)
        err_abort("print_src_data - out of memory ");

    for ( cur = src_list ; cur != NULL ; cur = cur->next)
    {
        *tmp++ = cur ;
	*tmp   = NULL ;
    }

    qsort( idx, src_count, sizeof(struct SRC_DATA *), src_data_cmp);

    for ( tmp = idx; *tmp != NULL ; )
    {
        src_file =  str_idx[ (*tmp)->file_idx ] ;
	obj_file = filename( src_file, ".obj");

	fprintf( map,"\n\nLine numbers for %s(%s)\n\n",
	    obj_file, src_file);

	free( obj_file);	/* release free memory */

	/*  print line data for this source module */
	for ( count = 1 ; (*tmp != NULL) &&
	    (strcmp( src_file, str_idx[ (*tmp)->file_idx]) == 0 ) ;
	    ++tmp )
	{
	    if (( *(tmp + 1) == NULL) ||
	        ( (*tmp)->add_segment != (*(tmp + 1))->add_segment) || 
	        ( (*tmp)->add_offset != (*(tmp + 1))->add_offset) )
	    {
	        fprintf (map, "%6d %04X:%04X%s", (*tmp)->line_num,
	            (*tmp)->add_segment, (*tmp)->add_offset,
		    (count % 4) ? "" : "\n" );

	        ++count;
	    }
	}

    }

    fprintf (map, "\n\n");
    free(idx);
}

src_data_cmp ( a, b)
struct SRC_DATA  **a, **b;
{
    int  ret_value;

    ret_value = strcmp( str_idx[ (*a)->file_idx], str_idx[ (*b)->file_idx] );

    if ( ret_value == 0)
        ( (*a)->line_num < (*b)->line_num) ? 
	    ( ret_value = -1) : (ret_value = 1) ;

    return (ret_value);

}


char *filename( path, ext)
char	*path, *ext;
{
    char  *f_path, *bf;

    f_path = malloc( strlen(path) + 5);		/* get buffer space */
    if (f_path == NULL)
        err_abort("filename - out of memory ");

    strcpy( f_path, path);
    if ((bf = strchr( f_path, '.')) != NULL )
        *bf = '\0';				/* truncate extension */

    strcat( f_path, ext);			/* add the extension */

    return( f_path);

}

read_strings( dbg)
int  dbg ;			/* input file handle */
{
    char	**idx_ptr;		/* string index pointer */
    char	*s_ptr;
    int		count ;
    long        position ;		/* return value for lseek() */
    int		error ;			/* return value for file operations */

    /*  Read in strings  (symbol names ) */

    position = lseek( dbg, (long) dbg_header.start_string * 64, SEEK_SET);
    if (position == -1L)
        err_abort( dbg_file);

    s_ptr = str_buff = malloc( dbg_header.tot_str_lnth); /* get string buffer */
    if (str_buff == NULL)
        err_abort ("read_strings - out of memory ");

    error = read( dbg, str_buff, dbg_header.tot_str_lnth);
    if (error == -1)
        err_abort (dbg_file);

     /*  string index buffer */
     idx_ptr = str_idx = 
         (char **) malloc( sizeof(char *) * (dbg_header.num_strings + 2) );
     if (str_idx == NULL)
         err_abort ("read_strings - out of memory ");

     *idx_ptr++   = NULL;		/* string indexes are base 1 */
     for(  count = dbg_header.num_strings ; count ; --count)
     {
         *idx_ptr++ = s_ptr ;		/* current string starting address */
	 s_ptr += strlen( s_ptr) + 1 ;	/* advance to the next string */
     }
     *idx_ptr   = NULL;

}


err_abort(msg)
char	*msg;
{
    perror(msg);		/* display error message */
    exit (1);			/* abort */
}

/*  */


