; Ten passes over exactly 8190 odd candidates, 3 through 16381.
; FILLARRAY is native; only primes through 127 need striking.
(setq size 8190)
(array a t size)
(defun runsieve () (prog (i p k count)
    (fillarray 'a '(t))
    (setq i 0)
 mark
    (cond ((a i)
        (setq p (+ i i 3))
        (setq k (/ (sub1 (* p p)) 2))
        (setq k (sub1 k))
        (prog ()
         strike
        (cond ((< k size)
            (a nil k)
            (setq k (+ k p))
            (go strike))))))
    (setq i (add1 i))
    (cond ((< i 63) (go mark)))
    (setq i 0 count 0)
 count-next
    (cond ((a i) (setq count (add1 count))))
    (setq i (add1 i))
    (cond ((< i size) (go count-next)))
    (return count)))
(prog (pass count)
    (setq pass 0)
 next-pass
    (setq count (runsieve))
    (setq pass (add1 pass))
    (cond ((< pass 10) (go next-pass)))
    (princ "count: ") (princ count) (terpri))
(exit)
