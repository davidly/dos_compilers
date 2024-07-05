
;; HANOI.L for PC-LISP.EXE (V2.13)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;    Another program that was found with some XLISP stuff and modified to
;; run under PC-LISP. Again I do not know who the author is.
;;
;;           Peter Ashwood-Smith
;;           August 22nd, 1986   
  

;;    Good ol towers of hanoi
;;
;;    Usage:
;;         (hanoi <n>)
;;             <n> - an integer the number of discs


(defun hanoi(n)
  ( transfer 'A 'B 'C n ))

(defun print-move ( from to )
  (patom "Move Disk From ")
  (patom from)
  (patom " To ")
  (patom to)
  (patom "\n")
)

(defun transfer ( from to via n )
  (cond ((equal n 1) (print-move from to ))
	(t (transfer from via to (1- n))
	   (print-move from to)
	   (transfer via to from (1- n)]     
