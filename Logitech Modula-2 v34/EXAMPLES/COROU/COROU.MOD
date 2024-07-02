MODULE Corou;

   FROM SYSTEM     IMPORT PROCESS	, ADDRESS	, NEWPROCESS , 
   			  TRANSFER 	;
   FROM Terminal   IMPORT WriteString	, WriteLn	;
   FROM Storage    IMPORT ALLOCATE	;

   FROM Keyboard   IMPORT KeyPressed	;
   FROM RTSMain    IMPORT Status	, Terminate	;

   CONST
       WorkSpaceSize	= 8000;		(* process workspace size *)

   VAR
       main		,
       coroutine1	,
       coroutine2	,
       coroutine3	: PROCESS;
       workSpacePtr1	,
       workSpacePtr2	,
       workSpacePtr3	: ADDRESS;
       

   PROCEDURE Message1;
   BEGIN
      LOOP
         WriteString ("In Coroutine # 1");
         WriteLn;
         TRANSFER (coroutine1, coroutine2);
      END;
   END Message1;


   PROCEDURE Message2;
   BEGIN
      LOOP
         WriteString ("In Coroutine # 2");
         WriteLn;
         TRANSFER (coroutine2, coroutine3);
      END;
   END Message2;


   PROCEDURE Message3;
   BEGIN
      LOOP
         WriteString ("In Coroutine # 3");
         WriteLn;

	 IF KeyPressed() THEN
	   WriteLn;
	   WriteString("Done!");
	   WriteLn;
	   Terminate(Normal);
	 END;

         TRANSFER (coroutine3, coroutine1);
      END;
   END Message3;


BEGIN (* main *)

  (* allocate the workspaces *)
  ALLOCATE(workSpacePtr1, WorkSpaceSize);
  ALLOCATE(workSpacePtr2, WorkSpaceSize);
  ALLOCATE(workSpacePtr3, WorkSpaceSize);

  (* create the new processes *)
  NEWPROCESS(Message1, workSpacePtr1, WorkSpaceSize, coroutine1);
  NEWPROCESS(Message2, workSpacePtr2, WorkSpaceSize, coroutine2);
  NEWPROCESS(Message3, workSpacePtr3, WorkSpaceSize, coroutine3);

  (* start the job *)
  TRANSFER(main, coroutine1);

END Corou.
