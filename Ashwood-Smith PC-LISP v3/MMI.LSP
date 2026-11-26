; BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
; integer version: + and * are PC-LISP's integer arithmetic. Its integers are
; wider than 16 bits, so the sum needs no base 10000 split.
; A is a list of rows and B a list of columns, and each element of C is the
; dot product of a row of A and a column of B.
; expected result: 465880
(defun dot (x y) (prog (s)
    (setq s 0)
 next
    (cond ((null x) (return s)))
    (setq s (+ s (* (car x) (car y))) x (cdr x) y (cdr y))
    (go next)))
(defun arow (i) (prog (j r)
    (setq j 20 r nil)
 next
    (cond ((= j 0) (return r)))
    (setq r (cons (+ i j) r) j (sub1 j))
    (go next)))
(defun bcol (j) (prog (k r)
    (setq k 20 r nil)
 next
    (cond ((= k 0) (return r)))
    (setq r (cons (/ (+ k j) j) r) k (sub1 k))
    (go next)))
(defun runmm () (prog (arows bcols i j s ra cb)
    (setq i 20 arows nil)
 ar
    (cond ((> i 0) (setq arows (cons (arow i) arows) i (sub1 i)) (go ar)))
    (setq j 20 bcols nil)
 bc
    (cond ((> j 0) (setq bcols (cons (bcol j) bcols) j (sub1 j)) (go bc)))
    (setq s 0 ra arows)
 rows
    (cond ((null ra) (go done)))
    (setq cb bcols)
 cols
    (cond ((null cb) (setq ra (cdr ra)) (go rows)))
    (setq s (+ s (dot (car ra) (car cb))) cb (cdr cb))
    (go cols)
 done
    (princ "summ is : ")
    (princ s)
    (terpri)))
(runmm)
(exit)
