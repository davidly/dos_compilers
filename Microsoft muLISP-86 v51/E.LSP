; 192 digits of e using the original 200-cell factorial spigot.
; Reversed list tails make each inner step constant-time.
; 96-digit integer blocks reduce the number of complete sweeps.
(defun rune (a tail high n x q left width divisor)
    (setq a '(2 0) n 198 x 0 high 295 left 192)
    (loop ((zerop n)) (setq a (cons 1 a) n (sub1 n)))
    (loop
        ((zerop left))
        (setq high (- high 96) n high tail (nthcdr (- 199 high) a))
        (loop
            ((zerop n))
            (setq q (truncate x n))
            (rplaca tail (- x (* q n)))
            (setq x (+ (* 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 (cadr tail)) q)
                  tail (cdr tail) n (sub1 n)))
        (setq width 96)
        (cond ((= left 192) (setq width 97)))
        (cond ((< left width)
            (setq x (truncate x (expt 10 (- width left))) width left)))
        (setq divisor (expt 10 (sub1 width)))
        (loop ((<= divisor 1))
            (cond ((< x divisor) (princ "0")))
            (setq divisor (truncate divisor 10)))
        (princ x)
        (setq left (- left width)))
    (terpri))
(rune)
(system)
