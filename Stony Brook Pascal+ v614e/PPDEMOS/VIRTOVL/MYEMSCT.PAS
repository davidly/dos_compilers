(*
   This file is to be linked into any program that uses MYEMS.PAS in conjunc-
   tion with MYEMSUSE.PAS.  It defines a constant variable that gets set by
   code in MYEMS, and is used by Example #1 in MYEMSUSE.  This unit DOES NOT
   have to be linked into a program that uses Example #2 in MYEMSUSE.
*)

{$D-,L-}
{$//NOMODINIT//NOLIBRARY}

unit MyEmsCt;

interface

type
  CheckEmsRec = record
    Pages, Handles: word;
  end;

const
  WhatsAvailable: CheckEmsRec = (Pages:0; Handles:0);

implementation
end.
