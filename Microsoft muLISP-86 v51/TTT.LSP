; Prove you can't win at tic-tac-toe if the opponent is competent.
; written for Microsoft Lisp v5 (muLISP-86)
; requires common.lsp and structur.lsp to have been loaded

(setq score-win 6)
(setq score-tie 5)
(setq score-lose 4)
(setq score-max 9)
(setq score-min 2)
(setq piece-blank 0)
(setq piece-x 1)
(setq piece-o 2)
(setq moves 0)
(setq board (make-array 9 :initial-element 0 ))
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
    (cond ((or (and (= x (aref board 1)) (= x (aref board 2)))
               (and (= x (aref board 3)) (= x (aref board 6)))
               (and (= x (aref board 4)) (= x (aref board 8))))
           x) (t piece-blank))
)

(defun proc1(x)
    (cond ((or (and (= x (aref board 0)) (= x (aref board 2)))
               (and (= x (aref board 4)) (= x (aref board 7))))
           x) (t piece-blank))
)

(defun proc2(x)
    (cond ((or (and (= x (aref board 0)) (= x (aref board 1)))
               (and (= x (aref board 5)) (= x (aref board 8)))
               (and (= x (aref board 4)) (= x (aref board 6))))
           x) (t piece-blank))
)

(defun proc3(x)
    (cond ((or (and (= x (aref board 4)) (= x (aref board 5)))
               (and (= x (aref board 0)) (= x (aref board 6))))
           x) (t piece-blank))
)

(defun proc4(x)
    (cond ((or (and (= x (aref board 0)) (= x (aref board 8)))
               (and (= x (aref board 2)) (= x (aref board 6)))
               (and (= x (aref board 1)) (= x (aref board 7)))
               (and (= x (aref board 3)) (= x (aref board 5))))
           x) (t piece-blank))
)

(defun proc5(x)
    (cond ((or (and (= x (aref board 3)) (= x (aref board 4)))
               (and (= x (aref board 2)) (= x (aref board 8))))
           x) (t piece-blank))
)

(defun proc6(x)
    (cond ((or (and (= x (aref board 7)) (= x (aref board 8)))
               (and (= x (aref board 0)) (= x (aref board 3)))
               (and (= x (aref board 2)) (= x (aref board 4))))
           x) (t piece-blank))
)

(defun proc7(x)
    (cond ((or (and (= x (aref board 6)) (= x (aref board 8)))
               (and (= x (aref board 1)) (= x (aref board 4))))
           x) (t piece-blank))
)

(defun proc8(x)
    (cond ((or (and (= x (aref board 6)) (= x (aref board 7)))
               (and (= x (aref board 2)) (= x (aref board 5)))
               (and (= x (aref board 0)) (= x (aref board 4))))
           x) (t piece-blank))
)

(defun mmMax (alpha beta depth move) (prog (i value nextDepth) ; this is how local variables are declared
    (setq moves (+ 1 moves))
    ;(princ "max: ") (princ board) (princ " ") (princ alpha) (princ " ") (princ beta) (princ " ") (princ move) (princ " ") (princ depth) (princ "\n")

    (cond ((> depth 3)
           ;(setq win (winner)) ; almost 2x slower than using procs
           ;(setq win (funcall (concat 'proc move) piece-o)) ; slower than using the procs hunk
           (setq win (funcall (aref procs move) piece-o))
           (cond ((= win piece-o) (return score-lose))))
    )

    (setq value score-min)
    (setq nextDepth (+ 1 depth))
    (setq i 0)
    _nexti_
    (cond ((= (aref board i) piece-blank)
           (setf (aref board i) piece-x)
           (setq score (mmMin alpha beta nextDepth i))
           (setf (aref board i) piece-blank)
                                       
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
           (setq win (funcall (aref procs move) piece-x))
           (cond ((= win piece-x) (return score-win))
                 ((= depth 8) (return score-tie))
           ))
    )

    (setq value score-max)
    (setq nextDepth (+ 1 depth))
    (setq i 0)
    _nexti_
    (cond ((= (aref board i) piece-blank)
           (setf (aref board i) piece-o)
           (setq score (mmMax alpha beta nextDepth i))
           (setf (aref board i) piece-blank)

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
    (setf (aref board position) piece-x)
    (mmMin score-min score-max 0 position)
    (setf (aref board position) piece-blank)
    (return "")
)

(setq procs (make-array 9))
(setf (aref procs 0) proc0)
(setf (aref procs 1) proc1)
(setf (aref procs 2) proc2)
(setf (aref procs 3) proc3)
(setf (aref procs 4) proc4)
(setf (aref procs 5) proc5)
(setf (aref procs 6) proc6)
(setf (aref procs 7) proc7)
(setf (aref procs 8) proc8)

(defun runall ()
    (runmm 0)
    (runmm 1)
    (runmm 4)                      
)

(clear-screen)
(setq startTime (time))
(princ "running...")
(dotimes (z 10) (runall))

(write-string "moves: ") (princ moves) ; should be 6493
(princ "elapsed hundredths of a second: ") (- (time) startTime) (TERPRI)

;(princ "memstat:         ") (princ (memstat)) (princ "\n")
;(gc)
;(princ "memstat post gc: ") (princ (memstat)) (princ "\n")

(system)

