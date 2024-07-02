/*
 * dpmi.h
 *
 * high level interface to dpmi
 *
 * written by: G. Eric Engstrom
 */

#if __cplusplus
extern "C"
  {
#endif

#pragma ZTC align 1

typedef struct TINFO
  {
  unsigned short	BufferSize;
  void _far *		(*RealModeSaveFunction)(unsigned short Operation,void _far *Buffer);
  void _far *		(*PModeSaveFunction)(unsigned short Operation,void _far *Buffer);
  }
Info_t;

typedef struct TMEMINFO
  {
  unsigned long	LargestContiguousBlock;
  unsigned long	MaxunloackedPageAllocation;
  unsigned long	MaxLoackedPageAllocation;
  unsigned long	PagesOfLinearSpace;
  unsigned long	TotalUnlockedPages;
  unsigned long	TotalFreePages;
  unsigned long	TotalPhysicalPages;
  unsigned long	FreePagesOfLinearSpace;
  unsigned long	SizeOfPagingPartition;
  unsigned long	Reserved[3];
  }
MemInfo_t;

typedef struct TSWITCHTABLE
  {
  unsigned short	newDS;
  unsigned short	newES;
  unsigned short	newSS;
  unsigned short	newCS;
  unsigned long		newIP;	/* upper 16 bits invalid in 16-bit mode */
  unsigned long		newSP;	/* upper 16 bits invalid in 16-bit mode */
  }
SwitchTable_t;

typedef struct TSWITCHFUNCTION
  {
  void _far *	(*RealModeSwitchFunction)(void _far *SwitchTable);
  void _far *	(*PModeSwitchFunction)(void _far *SwitchTable);
  }
SwitchFunction_t;

typedef struct TENVIRON
  {
  unsigned char 	MajorVersion;
  unsigned char 	MinorVersion;
  unsigned short	Flags;
  unsigned char 	ProcessorType;
  unsigned char 	MasterPICInterrupt;
  unsigned char 	SlavePICInterrupt;
  }
Environ_t;

typedef struct TLINEAR
  {
  unsigned long 	Handle;
  unsigned long 	LinearAddress;
  }
Linear_T;

#pragma ZTC align

/* descriptor management services */
short           dpmi_IsRealMode(void);
short           dpmi_AllocLDTDescriptors(unsigned short count);
short           dpmi_SegToDescriptor(unsigned short segment);
short           dpmi_FreeDescriptor(unsigned short segment);
short           dpmi_GetNextDescriptorIncrement(void);
void _far *     dpmi_GetBaseAddress(unsigned short segment);
short           dpmi_SetBaseAddress(unsigned short segment,void _far *linearaddr);
short           dpmi_SetSegLimit(unsigned short segment,unsigned long linearlen);
short           dpmi_SetDescriptorRights(unsigned short segment,unsigned short rights);
short           dpmi_CreateCodeSegAlias(unsigned short segment);
void _far *     dpmi_GetDescriptor(unsigned short segment,void _far *descriptortable);
void _far *     dpmi_SetDescriptor(unsigned short segment,void _far *descriptortable);
short           dpmi_AllocThisLDTDescriptor(unsigned short segment);

/* dos memory management services */
short		dpmi_DOSAlloc(unsigned short paragraphs,void _far *results);
short		dpmi_DOSFree(unsigned short segment);
short		dpmi_DOSRealloc(unsigned short segment,unsigned short paragraphs,void _far *results);

/* interrupt services */
void _far *	dpmi_GetRealModeVector(unsigned short vector);
short		dpmi_SetRealModeVector(unsigned short vector,void _far *handler);
void _far *	dpmi_GetExceptionHandler(unsigned short exception);
short		dpmi_SetExceptionHandler(unsigned short exception,void _far *handler);
void _far *	dpmi_GetProtectedModeVector(unsigned short exception);
short		dpmi_SetProtectedModeVector(unsigned short exception,void _far *handler);

/* translation services */
void _far *	dpmi_SimRealModeInterrupt(unsigned short vector,unsigned short flags,unsigned short commonstack,void _far *callstruct);
void _far *	dpmi_CallRealModeProcWithFarRet(unsigned short flags,unsigned short commonstack,void _far *callstruct);
void _far *	dpmi_CallRealModeProcWithIRet(unsigned short flags,unsigned short commonstack,void _far *callstruct);
void _far *	dpmi_RealModeCallBackAlloc(void _far *funcptr,void _far *callstruct);
short		dpmi_RealModeCallBackFree(void _far *realmodefuncptr);
short		dpmi_GetStateSaveRestoreInfo(void _far *statesavestruct);
short		dpmi_GetRawModeSwitchInfo(void _far *switchstruct);
short		dpmi_GetVersionInfo(void _far *versionstruct);
short		dpmi_GetFreeMemInfo(void _far *freememstruct);
short		dpmi_MemBlockAlloc(unsigned long size,void _far *newmemstruct);
short		dpmi_MemBlockFree(unsigned long memhandle);
short		dpmi_MemBlockRealloc(unsigned long size,unsigned long memhandle,void _far *newmemstruct);

/* page locking services */
short		dpmi_LockLinearRegion(void _far *regionptr,unsigned long regionsize);
short		dpmi_UnlockLinearRegion(void _far *regionptr,unsigned long regionsize);
short		dpmi_LockRealModeRegion(void _far *regionptr,unsigned long regionsize);
short		dpmi_UnlockRealModeRegion(void _far *regionptr,unsigned long regionsize);
unsigned long	dpmi_IsPageSize(void);

/* demand paging performance tuning */
short		dpmi_MarkAsDemandPage(void _far *regionptr,unsigned long regionsize);
short		dpmi_DiscardPage(void _far *regionptr,unsigned long regionsize);

/* physical address mapping */
short		dpmi_IsLinearAddress(void _far *physicalptr,unsigned long regionsize);

/* virtual interrupt state functions */
short		dpmi_DisableVirtualInterruptState(void);
short		dpmi_EnableVirtualInterruptState(void);
short		dpmi_IsVirtualIntteruptState(void);

/* vendor specific extensions */
void _far *	dpmi_GetVendorAPI(char _far *zstringvendorname);

/* debug support */
short		dpmi_SetDebugWatchPoint(void _far *regionptr,short watchpointsize,short watchpointtype);
short		dpmi_ClearDebugWatchPoint(short watchpointhandle);
short		dpmi_IsDebugWatchPointState(short watchpointhandle);
short		dpmi_ResetDebugWatchPoint(short watchpointhandle);

#if __cplusplus
  }
#endif
