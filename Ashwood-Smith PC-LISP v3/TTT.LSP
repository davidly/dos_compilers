; Prove you can't win at tic-tac-toe if the opponent is competent.
; Tested with PC-LISP V3.00. Likely won't work with more modern LISP implementations.
; This takes roughly 20 minutes to run on a 4.77Mhz 8086.
; This runs in about 2.2 seconds in the NTVDM emulator on an Intel i9-14900KF.
; I am not proficient in LISP; there are likely easy ways to improve performance.
; More recent versions of LISP have helpful functions including:
;    /= not equal
;    bitwise operators like logand
;    byte datatype instead of 4-byte integers
; But Common LISP doesn't seem to have hunks.

(setq score-win 6)
(setq score-tie 5)
(setq score-lose 4)
(setq score-max 9)
(setq score-min 2)
(setq piece-blank 0)
(setq piece-x 1)
(setq piece-o 2)
(setq moves 0)
(setq board (hunk 0 0 0 0 0 0 0 0 0))
(setq winpiece piece-blank)

(defun iswin (x y z)
    (setq winpiece (cxr x board))
    (cond ((and (not (= winpiece piece-blank)) (= winpiece (cxr y board)) (= winpiece (cxr z board)))))
)

(defun winner()
    (cond ((or (iswin 0 1 2)
               (iswin 0 3 6)
               (iswin 1 4 7)
               (iswin 2 5 8)
               (iswin 3 4 5)
               (iswin 4 0 8)
               (iswin 4 2 6)
               (iswin 6 7 8))
            winpiece)
          (t piece-blank)
    )
)

(defun proc0(x)
    (cond ((or (and (= x (cxr 1 board)) (= x (cxr 2 board)))
               (and (= x (cxr 3 board)) (= x (cxr 6 board)))
               (and (= x (cxr 4 board)) (= x (cxr 8 board))))
           x) (t piece-blank))
)

(defun proc1(x)
    (cond ((or (and (= x (cxr 0 board)) (= x (cxr 2 board)))
               (and (= x (cxr 4 board)) (= x (cxr 7 board))))
           x) (t piece-blank))
)

(defun proc2(x)
    (cond ((or (and (= x (cxr 0 board)) (= x (cxr 1 board)))
               (and (= x (cxr 5 board)) (= x (cxr 8 board)))
               (and (= x (cxr 4 board)) (= x (cxr 6 board))))
           x) (t piece-blank))
)

(defun proc3(x)
    (cond ((or (and (= x (cxr 4 board)) (= x (cxr 5 board)))
               (and (= x (cxr 0 board)) (= x (cxr 6 board))))
           x) (t piece-blank))
)

(defun proc4(x)
    (cond ((or (and (= x (cxr 0 board)) (= x (cxr 8 board)))
               (and (= x (cxr 2 board)) (= x (cxr 6 board)))
               (and (= x (cxr 1 board)) (= x (cxr 7 board)))
               (and (= x (cxr 3 board)) (= x (cxr 5 board))))
           x) (t piece-blank))
)

(defun proc5(x)
    (cond ((or (and (= x (cxr 3 board)) (= x (cxr 4 board)))
               (and (= x (cxr 2 board)) (= x (cxr 8 board))))
           x) (t piece-blank))
)

(defun proc6(x)
    (cond ((or (and (= x (cxr 7 board)) (= x (cxr 8 board)))
               (and (= x (cxr 0 board)) (= x (cxr 3 board)))
               (and (= x (cxr 2 board)) (= x (cxr 4 board))))
           x) (t piece-blank))
)

(defun proc7(x)
    (cond ((or (and (= x (cxr 6 board)) (= x (cxr 8 board)))
               (and (= x (cxr 1 board)) (= x (cxr 4 board))))
           x) (t piece-blank))
)

(defun proc8(x)
    (cond ((or (and (= x (cxr 6 board)) (= x (cxr 7 board)))
               (and (= x (cxr 2 board)) (= x (cxr 5 board)))
               (and (= x (cxr 0 board)) (= x (cxr 4 board))))
           x) (t piece-blank))
)

(defun mmMax (alpha beta depth move) (prog (i value nextDepth) ; this is how local variables are declared
    (setq moves (+ 1 moves))
    ;(princ "max: ") (princ board) (princ " ") (princ alpha) (princ " ") (princ beta) (princ " ") (princ move) (princ " ") (princ depth) (princ "\n")

    (cond ((> depth 3)
           ;(setq win (winner)) ; almost 2x slower than using procs
           ;(setq win (funcall (concat 'proc move) piece-o)) ; slower than using the procs hunk
           (setq win (funcall (cxr move procs) piece-o))
           (cond ((= win piece-o) (return score-lose))))
    )

    (setq value score-min)
    (setq nextDepth (+ 1 depth))
    (setq i 0)
    _nexti_
    (cond ((= (cxr i board) piece-blank)
           (rplacx i board piece-x)
           (setq score (mmMin alpha beta nextDepth i))
           (rplacx i board piece-blank)

           (cond ((= score score-win) 
                  (return score-win)) 
                 ((> score value)
                  (setq value score)
                  (cond ((>= value beta)
                         (return value))
                        ((> value alpha)
                         (setq alpha value))))
           ))
    )

    (cond ((< i 8)
           (setq i (+ i 1))
           (go _nexti_))
    )

    (return value)
))

(defun mmMin (alpha beta depth move) (prog (i value nextDepth) ; this is how local variables are declared
    (setq moves (+ 1 moves))
    ;(princ "min: ") (princ board) (princ " ") (princ alpha) (princ " ") (princ beta) (princ " ") (princ move) (princ " ") (princ depth) (princ "\n")

    (cond ((> depth 3)
           ;(setq win (winner)) ; almost 2x slower than using procs
           ;(setq win (funcall (concat 'proc move) piece-x)) ; slower than using the procs hunk
           (setq win (funcall (cxr move procs) piece-x))
           (cond ((= win piece-x) (return score-win))
                 ((= depth 8) (return score-tie))
           ))
    )

    (setq value score-max)
    (setq nextDepth (+ 1 depth))
    (setq i 0)
    _nexti_
    (cond ((= (cxr i board) piece-blank)
           (rplacx i board piece-o)
           (setq score (mmMax alpha beta nextDepth i))
           (rplacx i board piece-blank)

           (cond ((= score score-lose) 
                  (return score-lose)) 
                 ((< score value)
                  (setq value score)
                  (cond ((<= value alpha)
                         (return value)) 
                        ((< value beta)
                         (setq beta value))))
           ))
    )

    (cond ((< i 8)
           (setq i (+ i 1))
           (go _nexti_))
    )

    (return value)
))

(defun runmm (position)
    (rplacx position board piece-x)
    (mmMin score-min score-max 0 position)
    (rplacx position board piece-blank)
)

(setq procs (hunk proc0 proc1 proc2 proc3 proc4 proc5 proc6 proc7 proc8))

; solve for each of the 3 unique (after reflections) opening moves
(setq startTime (sys:time))
(runmm 0)
(runmm 1)
(runmm 4)
(setq endTime (sys:time))

(princ "moves: ") (princ moves) (princ "\n") ; should be 6493
(princ "elapsed seconds: ") (princ (- endTime startTime)) (princ "\n")

;(princ "memstat:         ") (princ (memstat)) (princ "\n")
;(gc)
;(princ "memstat post gc: ") (princ (memstat)) (princ "\n")

(exit)
