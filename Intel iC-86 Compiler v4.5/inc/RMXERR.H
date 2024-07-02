/* rmxerr.h - signal handling header file
 * $Version: 1.2 $
 * Copyright (c) 1989, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */


/* * * * * * * * * * * * * * * * * * * * * * * */
/*                                             */
/*   E N V I R O N M E N T A L    E R R O R S  */
/*                                             */
/* * * * * * * * * * * * * * * * * * * * * * * */

#ifndef EBUSY     /*  These mnemonics are also defined in ERRNO.H  */

#define EBUSY			0x3	 /* region is in use */
#define EEXIST			0x6	 /* token does not refer to an
					  * iRMX object */
#define EIO			0x2b	 /* io error */
#endif

 /* Nucleus exception codes */

#define EOK			0x0
#define ETIME			0x1	 /* TIME limit exceeded */
#define EMEM			0x2	 /* memory allocation exceeded */
#define ELIMIT			0x4	 /* some limit exceeded */
#define ECONTEXT		0x5	 /* request out of context */
#define ESTATE			0x7	 /* ready task resumed */
#define ENOTCONFIGURED		0x8
#define EINTERRUPTSATURATION	0x9	 /* interrupt task accumulated
					  * the maximum allowable
					  * number of SIGNAL$INTERRUPT
					  * requests */
#define EINTERRUPTOVERFLOW	0xa	 /* interrupt task accumulated
					  * more than the maximum
					  * allowable number of
					  * SIGNAL$INTERRUPT requests */
#define ETRANSMISSION		0xb	 /* error in message transmission */
#define ESLOT			0xc	 /* there are no available GDT slots */
#define EDATACHAIN		0xd	 /* buffer returned is a data chain */

 /* Nucleus Communication Service exception codes */

#define ECANCELLED		0xe1	 /* RSVP transaction cancelled
					  * by remote host */
#define EHOSTID			0xe2	 /* invalid host id parameter */
#define ENOLOCALBUFFER		0xe3	 /* insufficient buffer available
					  * on local host to receive message */
#define ENOREMOTEBUFFER		0xe4	 /* insufficient buffer available
					  * on remote host to receive message */
#define ERESOURCELIMIT		0xe6	 /* exceeded limit of number of
					  * simultaneous messages */
#define ETRANSID		0xe8	 /* invalid transaction id parameter */
#define EDISCONNECTED 		0xe9	 /* null socket parameter used
					  * with port that is not connected */
#define ETRANSLIMIT		0xea	 /* exceeded limit of number of
					  * simultaneous transactions */

 /* IOS exception codes */

#define EFEXIST			0x20	 /* file already exists */
#define EFNEXIST		0x21	 /* non-existant File  */
#define EDEVFD			0x22	 /* device and file driver
					  * incompatible */
#define ESUPPORT		0x23	 /* function not supported */
#define EEMPTYENTRY		0x24	 /* directory entry is empty */
#define EDIREND			0x25	 /* no more directory entries */
#define EFACCESS		0x26	 /* access to file denied */
#define EFTYPE			0x27	 /* invalid file type */
#define ESHARE			0x28	 /* file cannot be shared with others */
#define ESPACE			0x29	 /* insufficient space on volume */
#define EIDDR			0x2a	 /* bad device driver request */
#define EFLUSHING		0x2c	 /* other end of stream file
					  * is gone */
#define EILLVOL			0x2d	 /* illegal volume type */
#define EDEVOFFLINE		0x2e	 /* device is off line */
#define EIFDR			0x2f	 /* illegal file driver request */
#define EFRAGMENTATION 		0x30	 /* file too fragmented to extend */
#define EDIRNOTEMPTY		0x31	 /* directory not empty */
#define ENOTFILECONN		0x32	 /* not a file connection */
#define ENOTDEVICECONN		0x33	 /* not a device connection */
#define ECONNNOTOPEN		0x34	 /* connection is not open for
					  * requested operation */
#define ECONNOPEN		0x35	 /* connection already open */
#define EBUFFEREDCONN		0x36	 /* connection opened by EIOS
					  * but now accessed by BIOS */
#define EOUTSTANDINGCONNS       0x37	 /* specified soft detach has
					  * left device connections intact */
#define EALREADYATTACHED	0x38	 /* device already attached */
#define EDEVDETACHING		0x39	 /* specified file on a device
					  * in the process of being detached */
#define ENOTSAMEDEVICE		0x3a	 /* existing and new pathnames
					  * not on same device */
#define EILLOGICALRENAME	0x3b	 /* new pathname includes
					  * existing pathname */
#define ESTREAMSPECIAL		0x3c	 /* stream file request out
					  * of context */
#define EINVALIDFNODE		0x3d	 /* invalid file descriptor */
#define EPATHNAMESYNTAX		0x3e	 /* pathname null or contains
					  * invalid characters */
#define EFNODELIMIT		0x3f	 /* insufficient fnodes on volume */

 /*  EIOS exception codes  */

#define ELOGNAMESYNTAX		0x40	 /* invalid logical name */
#define ECANNOTCLOSE		0x41	 /* buffers cannot be flushed */
#define EIOMEM 			0x42	 /* IO system has insufficent memory */
#define EMEDIA			0x44	 /* no disk in drive */
#define ELOGNAMENEXIST		0x45	 /* logical name does not exist  */
#define ENOTOWNER		0x46	 /* user trying to detach a
					  * device is not the device's owner */
#define EIOJOB			0x47	 /* job is not a valid IO job */
#define EUDFFORMAT 		0x48	 /* udf is corrupted */
#define ENAMENEXIST		0x49	 /* user name not present in udf */
#define EUIDNEXIST		0x4a	 /* user token doesn't match udf */
#define EPASSWORDMISMATCH 	0x4b	 /* incorrect password */
#define EUDFIO			0x4c	 /* specified UDF file cannot
					  * be found */

 /* Expanded IO exception codes */

#define EIOUNCLASS		0x50	 /* an unclassified error has
					  * occured */
#define EIOSOFT 		0x51	 /* soft error has occured */
#define EIOHARD			0x52	 /* hard error has occured */
#define EIOOPRINT		0x53	 /* device is not ready */
#define EIOWRPROT		0x54	 /* write protected */
#define EIONODATA 		0x55	 /* no data on the next TAPE record */
#define EIOMODE			0x56	 /* a tape drive attempted
					  * a read/write operation
					  * before the previous one
					  * completed */
#define EIONOSPARES		0x57	 /* an attempt was made to assign
					  * an alternate track, but no
					  * more were available */
#define EIOALTASSIGNED		0x58	 /* an alternate was assigned
					  * during this I/O operation */

 /* Application Loader exception codes */

#define EBADHEADER		0x62	 /* an invalid object file header */
#define EEOF			0x65	 /* unexpected End of File
					  * while reading a record */
#define ENOLOADERMEM		0x67
#define ENOSTART		0x6c	 /* the Application Loader
					  * could not find the start
					  * address */
#define EJOBSIZE		0x6d	 /* The max. memory pool size of
					  * job being loaded is smaller
					  * than the amount required to
					  * load it */
#define EOVERLAY		0x6e	 /* the overlay name does not match */
#define ELOADERSUPPORT		0x6f	 /* The file requires features
					  * not supported by this
					  * configuration of the
					  * Application Loader */

 /* Human Interface exception codes */

#define ELITERAL		0x80	 /* literal with no closing
					  * quote detected while parsing */
#define ESTRINGBUFFER		0x81	 /* buffer too small for
					  * O.S. returned string */
#define ESEPARATOR		0x82	 /* illegal command separator */
#define ECONTINUED		0x83	 /* user parse buffer is continued */
#define EINVALIDNUMERIC		0x84	 /* invalid form of number */
#define ELIST			0x85	 /* missing value-list value */
#define EWILDCARD		0x86	 /* invalid wildcard character usage */
#define EPREPOSITION		0x87	 /* invalid preposition usage */
#define EPATH			0x88	 /* invalid path name */
#define ECONTROLC		0x89	 /* job cancelled via a control-C */
#define ECONTROL 		0x8a	 /* invalid control */
#define EUNMATCHEDLISTS		0x8b
#define EINVALIDDATE		0x8c
#define ENOPARAMETERS		0x8d	 /* no parameters found in
					  * command line */
#define EVERSION		0x8e	 /* version of entered command
					  * incompatible with system */
#define EGETPATHORDER		0x8f	 /* get$output$pathname called
					  * before get$input$pathname */
#define EPERMISSION		0x90	 /* do not have proper access */
#define EINVALIDTIME		0x91	 /* setting of time was invalid */

 /* UDI exception codes */

#define EUNKNOWNEXIT		0xc0	 /* normal termination */
#define EWARNINGEXIT		0xc1	 /* warning termination */
#define EERROREXIT		0xc2	 /* error termination */
#define EFATALEXIT		0xc3	 /* fatal error termination */
#define EABORTEXIT		0xc4	 /* user program aborted */
#define EUDIINTERNAL		0xc5	 /* unrecoverable internal error */

/* * * * * * * * * * * * * * * * * * * * */
/*                                       */
/*  P R O G R A M M I N G   E R R O R S  */
/*                                       */
/* * * * * * * * * * * * * * * * * * * * */

 /* Nucleus exception codes */

#define EZERODIVIDE		0x8000
#define EOVERFLOW		0x8001	 /* overflow interrupt occured */
#define ETYPE			0x8002	 /* token parameter is of
					  * invalid type */
#define EPARAM			0x8004	 /* parameter has an invalid value */
#define EBADCALL		0x8005	 /* An OS extension received an
					  * invalid code */
#define EARRAYBOUNDS		0x8006	 /* array overflow*/
#define ENDPERROR		0x8007	 /* NPX error has occured */
#define EILLEGALOPCODE		0x8008
#define EEMULATORTRAP		0x8009	 /* an ESC instruction was
					  * encountered with emulator
					  * bit set in MSW */
#define ECHECKEXCEPTION		0x800a	 /* a PASCAL task exceeded CASE
					  * statement boundary */
#define ECPUXFERDATALIMIT	0x800b	 /* the NPX tried to access an
					  * address that is out of
					  * segment bound */
#define EPROTECTION 		0x800d	 /* General Protection error */
#define ENOTPRESENT		0x800e	 /* A request to load a segment
					  * register whose segment is
					  * not present */
#define EBADADDR		0x800f	 /* Invalid logical address */

 /* Nucleus Communication Service exception codes */

#define EPROTOCOL		0x80e0	 /* port parameter is wrong
					  * protocol */
#define EPORTIDUSED 		0x80e1	 /* request port id is in use */
#define ENUCBADBUF		0x80e2	 /* invalid buffer pointer or
					  * insufficient buffer length */

 /* IOS exception codes */
 /* EIOS exception codes */

#define ENOUSER			0x8021	 /* no default user is defined */
#define ENOPREFIX		0x8022	 /* no default prefix is defined */
#define EBADBUFF		0x8023	 /* specified buffer too small
					  * for requested operation */
#define ENOTLOGNAME		0x8040	 /* the specified object is
					  * not a device or file connection */
#define ENOTDEVICE		0x8041	 /* the specified object is
					  * not a device connection */
#define ENOTCONNECTION		0x8042	 /* the specified object is
					  * not a file connection */

 /* Application Loader exception codes */

#define EJOBPARAM		0x8060	 /* maximum memory specified
					  * is less than the minimum
					  * memory specified */

 /* HI exception codes */

#define EPARSETABLES		0x8080	 /* internal error in parse tables */
#define EJOBTABLES		0x8081	 /* internal inconsistency
					  * in job tables */
#define EDEFAULTSO		0x8083	 /* default output name string
					  * specified is invalid */
#define ESTRING			0x8084	 /* Returned pathname exceeds
					  * 255 characters in length */
#define EERROROUTPUT		0x8085	 /* send$eo$response called
					  * when command connection
					  * allows only send$co$response */

 /* UDI exception codes */

#define ERESERVEPARAM		0x80c6	 /* calling program attempted
					  * to reserve more than 12
					  * files or buffers */
#define EOPENPARAM		0x80c7	 /* calling program attempted
					  * to open a file with more
					  * than two buffers */

