       identification division.
       program-id. pentot2.
       environment division.
       input-output section.
       file-control.
	   select fd-empl-file assign to "salary.dat"
	   organization is line sequential.
       data division.
       file section.
       fd  fd-empl-file.
       01  fd-empl-rec		pic x(32).
       working-storage section.
       01  ws-empl-rec.
	   05  ws-empl-nbr	pic x(3)  value spaces.
	   05  ws-empl-name	pic x(24) value spaces.
	   05  ws-empl-salary	pic 9(5)  value zeroes.
       01  ws-emp-pension	pic 9(4)  value zeroes.
       01  ws-total-pension	pic 9(5)  value zeroes.
       01  ws-eof-sw		pic 9(3)  value 'no'.
       procedure division.
	   open input fd-empl-file.
	   perform process-empl-recs until ws-eof-sw = 'yes'.
	   display spaces upon crt.
	   display "Total pension for employees: " ws-total-pension.
	   close fd-empl-file.
	   stop run.
       process-empl-recs.
	   read fd-empl-file into ws-empl-rec
		at end move 'yes' to ws-eof-sw.
	   compute ws-empl-pension = ws-empl-salary * .05.
	   compute ws-total-pension = ws-total-pension + ws-empl-pension.
	   move zeroes to ws-empl-pension.
