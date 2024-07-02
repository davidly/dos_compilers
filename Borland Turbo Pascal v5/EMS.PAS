program Ems_Test;
{ *************************************************************
  * This program shows you how to use the basic functions of  *
  * the LIM Expanded Memory Specification. Since it does not  *
  * use any of the LIM EMS 4.0 function calls, you can also   *
  * use it on systems with EMS versions less than 4.0         *
  ************************************************************* }

{ Written by:
    Peter Immarco.
    Thought Dynamics
    Manhattan Beach, CA
    Compuserve ID# 73770,123
     *** Public Domain ***

  Used by permission of the author.
}

{ This program does the following:
  +------------------------------------------------------------+
  | * Makes sure the LIM Expanded Memory Manager (EMM) has     |
  |   been installed in memory                                 |
  | * Displays the version number of the EMM present in memory |
  | * Determines if there are enough pages (16k blocks) of     |
  |   memory for our test program's usage. It then displays    |
  |   the total number of EMS pages present in the system,     |
  |   and how many are available for our usage                 |
  | * Requests the desired number of pages from the EMM        |
  | * Maps a logical page onto one of the physical pages given |
  |   to us                                                    |
  | * Displays the base address of our EMS memory page frame   |
  | * Performs a simple read/write test on the EMS memory given|
  |   to us                                                    |
  | * Returns the EMS memory given to us back to the EMM, and  |
  |   exits                                                    |
  +------------------------------------------------------------|}


{ All the calls are structured to return the result or error
  code of the Expanded Memory function performed as an integer.
  If the error code is not zero, which means the call failed,
  a simple error procedure is called and the program terminates.}

uses Crt, Dos;

Type
  ST3  = string[3];
  ST80 = string[80];
  ST5 = string[5];

Const
  EMM_INT                   = $67;
  DOS_Int                   = $21;
  GET_PAGE_FRAME            = $41;
  GET_UNALLOCATED_PAGE_COUNT= $42;
  ALLOCATE_PAGES            = $43;
  MAP_PAGES                 = $44;
  DEALLOCATE_PAGES          = $45;
  GET_VERSION               = $46;

  STATUS_OK                 = 0;

  { We'll say we need 1 EMS page for our application }
  APPLICATION_PAGE_COUNT    = 1;

Var
  Regs: Registers;
  Emm_Handle,
  Page_Frame_Base_Address,
  Pages_Needed,
  Physical_Page,
  Logical_Page,
  Offset,
  Error_Code,
  Pages_EMS_Available,
  Total_EMS_Pages,
  Available_EMS_Pages: Word;
  Version_Number,
  Pages_Number_String: ST3;
  Verify: Boolean;

{ * --------------------------------------------------------- * }
  { The function Hex_String converts an Word into a four
    character hexadecimal number(string) with leading zeroes.   }
  Function Hex_String(Number: Word): ST5;
    Function Hex_Char(Number: Word): Char;
    Begin
      If Number<10 then
        Hex_Char:=Char(Number+48)
      else
        Hex_Char:=Char(Number+55);
    end; { Function Hex_Char }

  Var
    S: ST5;
  Begin
    S:='';
    S:=Hex_Char( (Number shr 1) div 2048);
    Number:=( ((Number shr 1) mod 2048) shl 1)+
            (Number and 1) ;
    S:=S+Hex_Char(Number div 256);
    Number:=Number mod 256;
    S:=S+Hex_Char(Number div 16);
    Number:=Number mod 16;
    S:=S+Hex_Char(Number);
    Hex_String:=S+'h';
  end; { Function Hex_String }

{ * --------------------------------------------------------- * }

  { The function Emm_Installed checks to see if the Expanded
    Memory Manager (EMM) is loaded in memory. It does this by
    looking for the string 'EMMXXXX0', which should be located
    at 10 bytes from the beginning of the code segment pointed
    to by the EMM interrupt, 67h                                }
  Function Emm_Installed: Boolean;
    Var
      Emm_Device_Name       : string[8];
      Int_67_Device_Name    : string[8];
      Position              : Word;
      Regs                  : registers;

  Begin
    Int_67_Device_Name:='';
    Emm_Device_Name   :='EMMXXXX0';
    with Regs do
    Begin
      { Get the code segment pointed to by Interrupt 67h, the EMM
      interrupt by using DOS call $35, 'get interrupt vector'     }
      AH:=$35;
      AL:=EMM_INT;
      Intr(DOS_int,Regs);

      { The ES pseudo-register contains the segment address pointed
        to by Interrupt 67h }
      { Create an 8 character string from the 8 successive bytes
        pointed to by ES:$0A (10 bytes from ES)                   }
      For Position:=0 to 7 do
        Int_67_Device_Name:=
          Int_67_Device_Name+Chr(mem[ES:Position+$0A]);
      Emm_Installed:=True;
      { Is it the EMM manager signature, 'EMMXXXX0'? then EMM is
        installed and ready for use, if not, then the EMM manager
        is not present                                            }
      If Int_67_Device_Name<>Emm_Device_Name
        then Emm_Installed:=False;
    end; { with Regs do }
  end;  { Function Emm_Installed }

{ * --------------------------------------------------------- * }

  { This function returns the total number of EMS pages present
    in the system, and the number of EMS pages that are
    available for our use                                       }
  Function EMS_Pages_Available
    (Var Total_EMS_Pages,Pages_Available: Word): Word;
  Var
    Regs: Registers;
  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-
        register                                                }
      AH:=Get_Unallocated_Page_Count;
      intr(EMM_INT,Regs);
      { The number of EMS pages available is returned in BX     }
      Pages_Available:=BX;
      { The total number of pages present in the system is
        returned in DX                                          }
      Total_EMS_Pages:=DX;
      { Return the error code                                   }
      EMS_Pages_Available:=AH
    end;
  end; { EMS_Pages_Available }

{ * --------------------------------------------------------- * }

  { This function requests the desired number of pages from the
    EMM                                                         }
  Function Allocate_Expanded_Memory_Pages
    (Pages_Needed: Word; Var Handle: Word   ): Word;
  Var
    Regs: Registers;
  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-
        register                                                }
      AH:= Allocate_Pages;
      { Put the desired number of pages in BX                   }
      BX:=Pages_Needed;
      intr(EMM_INT,Regs);
      { Our EMS handle is returned in DX                        }
      Handle:=DX;
      { Return the error code }
      Allocate_Expanded_Memory_Pages:=AH;
    end;
  end; { Function Allocate_Expanded_Memory_Pages }

{ * --------------------------------------------------------- * }

  { This function maps a logical page onto one of the physical
    pages made available to us by the
    Allocate_Expanded_Memory_Pages function                     }
  Function Map_Expanded_Memory_Pages
    (Handle,Logical_Page,Physical_Page: Word): Word;
  Var
    Regs: Registers;
  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-
        register                                                }
      AH:=Map_Pages;
      { Put the physical page number to be mapped into AL       }
      AL:=Physical_Page;
      { Put the logical page number to be mapped in    BX       }
      BX:=Logical_Page;
      { Put the EMS handle assigned to us earlier in   DX       }
      DX:=Handle;
      Intr(EMM_INT,Regs);
      { Return the error code }
      Map_Expanded_Memory_Pages:=AH;
    end; { with Regs do }
  end; { Function Map_Expanded_Memory_Pages }

{ * --------------------------------------------------------- * }

  { This function gets the physical address of the EMS page
    frame we are using. The address returned is the segment
    of the page frame.                                          }
  Function Get_Page_Frame_Base_Address
    (Var Page_Frame_Address: Word): Word;
  Var
    Regs: Registers;
  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-
        register                                                }
      AH:=Get_Page_Frame;
      intr(EMM_INT,Regs);
      { The page frame base address is returned in BX           }
      Page_Frame_Address:=BX;
      { Return the error code }
      Get_Page_Frame_Base_Address:=AH;
     end; { Regs }
  end; { Function Get_Page_Frame_Base_Address }

{ * --------------------------------------------------------- * }

  { This function releases the EMS memory pages allocated to
    us, back to the EMS memory pool.                            }
  Function Deallocate_Expanded_Memory_Pages
    (Handle: Word): Word;
  Var
    Regs: Registers;
  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-register }
      AH:=DEALLOCATE_PAGES;
      { Put the EMS handle assigned to our EMS memory pages in DX }
      DX:=Emm_Handle;
      Intr(EMM_INT,Regs);
      { Return the error code }
      Deallocate_Expanded_Memory_Pages:=AH;
    end; { with Regs do }
  end;  { Function Deallocate_Expanded_Memory_Pages }

{ * --------------------------------------------------------- * }

  { This function returns the version number of the EMM as
    a 3 character string.                                       }
  Function Get_Version_Number(Var Version_String: ST3): Word;
  Var
    Regs: Registers;
    Word_Part,Fractional_Part: Char;

  Begin
    with Regs do
    Begin
      { Put the desired EMS function number in the AH pseudo-register }
      AH:=GET_VERSION;
      Intr(EMM_INT,Regs);
      { See if call was successful }
      If AH=STATUS_OK then
      Begin
        { The upper four bits of AH are the Word portion of the
          version number, the lower four bits are the fractional
          portion. Convert the Word value to ASCII by adding 48. }
        Word_Part   := Char( AL shr 4 + 48);
        Fractional_Part:= Char( AL and $F +48);
        Version_String:= Word_Part+'.'+Fractional_Part;
      end; { If AH=STATUS_OK }
      { Return the function calls error code }
      Get_Version_Number:=AH;
    end; { with Regs do }
  end; { Function Get_Version_Number }

{ * --------------------------------------------------------- * }

  { This procedure prints an error message passed by the caller,
    prints the error code passed by the caller in hex, and then
    terminates the program with the an error level of 1         }

  Procedure Error(Error_Message: ST80; Error_Number: Word);
  Begin
    Writeln(Error_Message);
    Writeln('  Error_Number = ',Hex_String(Error_Number) );
    Writeln('EMS test program aborting.');
    Halt(1);
  end; { Procedure Error_Message }

{ * --------------------------------------------------------- * }

{ EMS_TEST }

{ This program is an example of the basic EMS functions that you
  need to execute in order to use EMS memory with Turbo Pascal  }

Begin
  ClrScr;
  Window(5,2,77,22);

  { Determine if the Expanded Memory Manager is installed, If
    not, then terminate 'main' with an ErrorLevel code of 1. }

  If not (Emm_Installed) then
  Begin
    Writeln('The LIM Expanded Memory Manager is not installed.');
    Halt(1);
  end;

  { Get the version number and display it }
  Error_Code:= Get_Version_Number(Version_Number);
  If Error_Code<>STATUS_OK then
    Error('Error trying to get the EMS version number ',
          Error_code)
  else
    Writeln('LIM Expanded Memory Manager, version ',
            Version_Number,' is ready for use.');
  Writeln;

  { Determine if there are enough expanded memory pages for this
    application. }
  Pages_Needed:=APPLICATION_PAGE_COUNT;
  Error_Code:=
    EMS_Pages_Available(Total_EMS_Pages,Available_EMS_Pages);
  If Error_Code<>STATUS_OK then
    Error('Error trying to determine the number of EMS pages available.',
          Error_code);

  Writeln('There are a total of ',Total_EMS_Pages,
          ' expanded memory pages present in this system.');
  Writeln('  ',Available_EMS_Pages,
          ' of those pages are available for your usage.');
  Writeln;

  { If there is an insufficient number of pages for our application,
    then report the error and terminate the EMS test program }
  If Pages_Needed>Available_EMS_Pages then
  Begin
    Str(Pages_Needed,Pages_Number_String);
    Error('We need '+Pages_Number_String+
          ' EMS pages. There are not that many available.',
          Error_Code);
  end; { Pages_Needed>Available_EMS_Pages }

  { Allocate expanded memory pages for our usage }
  Error_Code:= Allocate_Expanded_Memory_Pages(Pages_Needed,Emm_Handle);
  Str(Pages_Needed,Pages_Number_String);
  If Error_Code<>STATUS_OK then
    Error('EMS test program failed trying to allocate '+Pages_Number_String+
          ' pages for usage.',Error_Code);
  Writeln(APPLICATION_PAGE_COUNT,
          ' EMS page(s) allocated for the EMS test program.');
  Writeln;

  { Map in the required logical pages to the physical pages
    given to us, in this case just one page                     }
  Logical_Page :=0;
  Physical_Page:=0;
  Error_Code:=
    Map_Expanded_Memory_Pages(
      Emm_Handle,Logical_Page,Physical_Page);
  If Error_Code<>STATUS_OK then
    Error('EMS test program failed trying to map '+
          'logical pages onto physical pages.',Error_Code);

  Writeln('Logical Page ',Logical_Page,
          ' successfully mapped onto Physical Page ',
          Physical_Page);
  Writeln;

  { Get the expanded memory page frame address }
  Error_Code:= Get_Page_Frame_Base_Address(Page_Frame_Base_Address);
  If Error_Code<>STATUS_OK then
    Error('EMS test program unable to get the base Page'+
          ' Frame Address.',Error_Code);
  Writeln('The base address of the EMS page frame is - '+
          Hex_String(Page_Frame_Base_Address) );
  Writeln;

  { Write a test pattern to expanded memory }
  For Offset:=0 to 16382 do
    Mem[Page_Frame_Base_Address:Offset]:=Offset mod 256;

  { Make sure that what is in EMS memory is what we just wrote }
  Writeln('Testing EMS memory.');

  Offset:=1;
  Verify:=True;
  while (Offset<=16382) and (Verify=True) do
  Begin
    If Mem[Page_Frame_Base_Address:Offset]<>Offset mod 256 then
      Verify:=False;
    Offset:=Succ(Offset);
  end;  { while (Offset<=16382) and (Verify=True) }

  { If it isn't report the error }
  If not Verify then
    Error('What was written to EMS memory was not found during '+
          'memory verification  test.',0);
  Writeln('EMS memory test successful.');
  Writeln;

  { Return the expanded memory pages given to us back to the
    EMS memory pool before terminating our test program         }
  Error_Code:=Deallocate_Expanded_Memory_Pages(Emm_Handle);
  If Error_Code<>STATUS_OK then
    Error('EMS test program was unable to deallocate '+
          'the EMS pages in use.',Error_Code);
  Writeln(APPLICATION_PAGE_COUNT,
          ' page(s) deallocated.');
  Writeln;
  Writeln('EMS test program completed.');
end.
