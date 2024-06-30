       identification division.
       program-id. emplhlth.
       environment division.
       input-output section.
       file-control.
	   select fd-health-file assign to "health.dat"
	   organization is line sequential.
       data division.
       file section.
       fd  fd-health-file.
       01  fd-health-rec.
	   05  fd-empl-nbr       pic x(3)  value spaces.
	   05  fd-empl-name      pic x(24) value spaces.
	   05  fd-health-plan	 pic x(16) value spaces.
     *
       Working-storage section.
       01  ws-eof-sw             pic x(3)  value 'no'.
      *
       Linkage Section.
       01  ws-empl-nbr		 pic x(3)  value spaces.
       01  ws-empl-name 	 pic x(24) value spaces.
       01  ws-empl-healthcare	 pic x(16) value spaces.
      *
       procedure division using ws-empl-nbr, ws-empl-name,
			ws-empl-healthcare.
	   open input fd-health-file.
	   perform process-health-recs
	     until fd-empl-name is equal to ws-empl-name
		or ws-eof-sw = 'yes'.
	   close fd-health-file.
	   exit program.
	   stop run.
       process-health-recs.
	   read fd-health-file
		at end move 'yes' to ws-eof-sw.
	   If ws-eof-sw is equal to 'yes'
	      next sentence
	   else
	   if fd-empl-name is equal to ws-empl-name
	      move fd-health-plan to ws-empl-healthcare.
