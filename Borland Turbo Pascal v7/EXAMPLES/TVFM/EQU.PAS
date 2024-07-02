{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Equ;  { Equates for TVFM }

interface

uses Views;

const

  evIdle              = $0400;     { Idle event type }

  { File menu commands }
  cmNewWindow         = 100; { Sent when a new window is created }
  cmDosShell          = cmNewWindow + 1;
  cmRun               = cmDosShell + 1;

  { commands depending on the file list being focused }
  cmExecute           = 103;
  cmViewAsHex         = cmExecute + 1;
  cmViewAsText        = cmViewAsHex + 1;
  cmViewCustom        = cmViewAsText + 1;
  cmAssociate         = cmViewCustom + 1;
  cmCopy              = cmAssociate + 1;
  cmDelete            = cmCopy + 1;
  cmRename            = cmDelete + 1;
  cmChangeAttr        = cmRename + 1;
  cmReverseTags       = cmChangeAttr + 1;
  cmClearTags         = cmReverseTags + 1;
  cmTagPerCard        = cmClearTags + 1;

  cmExitHere          = cmTagPerCard + 1;  { exit to current directory }
  cmGetCurrentDir     = cmExitHere + 1;  { broadcast looking for current directory }
  cmBeginSearch       = cmGetCurrentDir + 1;


  { Options menu commands }
  cmVideoMode         = cmBeginSearch + 1;
  cmInstallViewer     = cmVideoMode + 1;
  cmDisplayOptions    = cmInstallViewer + 1;
  cmSaveConfig        = cmDisplayOptions + 1;
  cmColorChange       = cmSaveConfig + 1;

  cmStatusUpdate      = 3000; { sent to update the status window }

  { broadcasts used to update the file list display }
  cmRefreshDisplay    = 3100; { used when sorting/display options change }
  cmRescan            = 3101; { used to rescan the current directory }
  cmScanComplete      = 3102; { sent when a directory scan if finished }
  cmNewDir            = 3103; { used to begin scanning a new directory }
  cmTagChanged        = 3104; { sent when a file's tag status changes }

  cmInvalidDir        = 3200; { invalidate a dir, causing it to be rescanned }

  cmTopWindow         = 3300; { get the address of the top window }
  cmFileListFocused   = 3301; { is the File list focused in the top window? }

  cmItemDropped       = 4000; { an item has been dropped }

  cmFileFound         = 4100; { a file was found by file search }
  cmStopSearch        = 4101; { interrupt the file search }


  { help contexts }

  hcFileMenu          = 6000;
  hcViewSubMenu       = hcFileMenu + 1;
  hcTagSubMenu        = hcViewSubMenu + 1;
  hcOptionsMenu       = hcTagSubMenu + 1;
  hcWindowMenu        = hcOptionsMenu + 1;

  hcDisplayFields     = hcWindowMenu + 1;
  hcQuit              = hcDisplayFields + 1;


  hcNewWindow         = cmNewWindow;
  hcExecute           = cmExecute;
  hcViewAsText        = cmViewAsText;
  hcViewAsHex         = cmViewAsHex;
  hcViewCustom        = cmViewCustom;
  hcAssociate         = cmAssociate;
  hcCopy              = cmCopy;
  hcDelete            = cmDelete;
  hcRename            = cmRename;
  hcChangeAttr        = cmChangeAttr;
  hcBeginSearch       = cmBeginSearch;
  hcReverseTags       = cmReverseTags;
  hcClearTags         = cmClearTags;
  hcTagPerCard        = cmTagPerCard;
  hcRun               = cmRun;
  hcDosShell          = cmDosShell;
  hcExitHere          = cmExitHere;

  hcVideoMode         = cmVideoMode;
  hcInstallViewer     = cmInstallViewer;
  hcDisplayOptions    = cmDisplayOptions;
  hcSaveConfig        = cmSaveConfig;
  hcColorChange       = cmColorChange;

  { other assorted program strings }
  sNoFiles            = 10000;
  sPleaseWait         = sNoFiles + 1;
  sSameNameErr        = sPleaseWait + 1;
  sRenameErr          = sSameNameErr + 1;
  sSetAttrErr         = sRenameErr + 1;
  sNoAssociation      = sSetAttrErr + 1;
  sPressAnyKey        = sNoAssociation + 1;
  sExecErr            = sPressAnyKey + 1;
  sExecRetCode        = sExecErr + 1;
  sNoViewerErr        = sExecRetCode + 1;
  sInvokeErr          = sNoViewerErr + 1;
  sNoDrivesErr        = sInvokeErr + 1;
  sAccessErr          = sNoDrivesErr + 1;
  sFileIsReadOnly     = sAccessErr + 1;
  sDeleteErr          = sFileIsReadOnly + 1;
  sDeleting           = sDeleteErr + 1;
  sReadAttrErr        = sDeleting + 1;
  sCustomViewer       = sReadAttrErr + 1;
  sPathAndName        = sCustomViewer + 1;
  sCantLocateOnPath   = sPathAndName + 1;
  sFileNotAnExe       = sCantLocateOnPath + 1;
  sWriteCfgErr        = sFileNotAnExe + 1;
  sInvalidCfgErr      = sWriteCfgErr + 1;
  sReading            = sInvalidCfgErr + 1;
  sWriting            = sReading + 1;
  sScanning           = sWriting + 1;
  sDelSingle          = sScanning + 1;
  sDelMult            = sDelSingle + 1;

implementation

end. { unit }
