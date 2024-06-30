       identification division.
       program-id.  emplmain.
       environment division.
       input-output section.
       file-control.
	   select fd-empl-file assign to "empl.dat"
	   organization is line sequential.
       data division.
       file section.
       fd  fd-empl-file.
       01  fd-empl-rec           pic x(40).
      *
       working-storage section.
       01  ws-empl-healthcare	 pic x(16).
       01  ws-empl-rec.
	   05  ws-empl-nbr       pic x(3)  value spaces.
	   05  ws-empl-name	 pic x(24) value spaces.
	   05  ws-hire-date	 pic 9(6)  value zeroes.
	   05  ws-empl-status    pic x(8)  value spaces.
	   05  ws-empl-salary    pic 9(5)  value zeroes.
       01  ws-eof-sw             pic x(3)  value 'no'.

       procedure division.
	   open input fd-empl-file.
	   read fd-empl-file into ws-empl-rec
		at end move 'yes' to ws-eof-sw.
	   perform process-empl-recs until ws-eof-sw = 'yes'.
	   close fd-empl-file.
	   stop run.
       process-empl-recs.
	   if ws-empl-status is equal to "hourly"
	      call "emplhlth" using ws-empl-nbr, ws-empl-name,
				    ws-empl-healthcare
	      display  ws-empl-name " has coverage with "
		       ws-empl-healthcare.
	   read fd-empl-file into ws-empl-rec
		at end move 'yes' to ws-eof-sw.
