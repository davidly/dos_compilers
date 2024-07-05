
;
; Place n queens on a board (graphical version)
;  See Winston and Horn Ch. 11
; 
; Usage:
;       (queens <n>)
;          where <n> is an integer -- the size of the board - try (queens 4)
;
; I do not know who the original Author of this is but it was found with some
; XLISP example lisp programs. This has been slightly modified to run on   
; PC-LISP V2.13.
;
;               Peter Ashwood-Smith
;               August 22nd, 1986

; Do two queens threaten each other ?

(defun threat (i j a b)
  (or (= i a)                       ;Same row
      (= j b)                       ;Same column
      (= (- i j) (- a b))           ;One diag.
      (= (+ i j) (+ a b))))         ;the other diagonal

; Is poistion (n,m) on the board safe for a queen ?

(defun conflict (n m board)
  (cond ((null board) nil)
	((threat n m (caar board) (cadar board)) t)
	(t (conflict n m (cdr board)))))


; Place queens on a board of size SIZE

(defun queens (size)
  (prog (n m board soln)
	(setq soln 0)                   ;Solution #
	(setq board ())
	(setq n 1)                      ;Try the first row
   loop-n     
	(setq m 1)                      ;Column 1
   loop-m     
	(cond ((conflict n m board) (go un-do-m))) ;Check for conflict
	(setq board (cons (list n m) board))       ; Add queen to board
	(cond ((> (setq n (1+ n)) size)            ; Placed N queens ?
	       (print-board (reverse board) (setq soln (1+ soln))))) ; Print it
	(go loop-n)                                ; Next row which column?
   un-do-n     
	(cond ((null board) (return 'Done)))       ; Tried all possibilities
	(setq m (cadar board))                     ; No, Undo last queen placed
	(setq n (caar board))
	(setq board (cdr board))  
   un-do-m
	(cond ((> (setq m (1+ m)) size)          ; Go try next column
	       (go un-do-n))
	      (t (go loop-m)))))


;Print a board

(defun print-board  (board soln)
  (prog (size)
	(setq size (length board))            ;we can find our own size
	(princ "\f\n\t\tSolution: ")
	(princ soln)
	(princ "\n\n\t")
	(print-header size 1)
	(princ "\n")
	(print-board-aux board size 1)
	(princ "\n")
  )
)

; Put Column #'s on top

(defun print-header (size n)
  (cond ((> n size) (princ "\n"))
	(t (prog () (patom n)
		    (princ " ") 
		    (print-header size (1+ n))))))

(defun print-board-aux (board size row)
  (princ "\n")
  (cond ((null board) ())
	(t (prog () 
	     (princ row)                  ;print the row #
	     (princ "\t")
	     (print-board-row (cadar board) size 1) ;Print the row
	     (print-board-aux (cdr board) size (1+ row))))))  ;Next row

(defun print-board-row (column size n)
  (cond ((> n size)())
	(t (prog () 
	      (cond ((equal column n) (princ "Q"))
		    (t (princ ".")))
	      (princ " ") 
	      (print-board-row column size (1+ n))))))

