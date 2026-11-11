; 192 digits of e, using the original 200-cell factorial spigot.
; Reversed list tails avoid array lookup on every inner step.
; 7-digit blocks keep all intermediates below 2,000,000,000.
(defun rune () (prog (a tail high n x q left width divisor)
    (setq a '(2 0) n 198 x 0 high 206 left 192)
 init
    (setq a (cons 1 a) n (sub1 n))
    (cond ((> n 0) (go init)))
 outer
    (setq high (- high 7) n high tail (nthcdr (- 199 high) a))
 inner
    (setq q (/ x n))
    (rplaca tail (- x (* q n)))
    (setq x (+ (* 10000000 (cadr tail)) q)
          tail (cdr tail) n (sub1 n))
    (cond ((> n 0) (go inner)))
    (setq width 7)
    (cond ((= left 192) (setq width 8)))
    (cond ((< left width)
        (setq x (/ x (expt 10 (- width left))) width left)))
    (setq divisor (expt 10 (sub1 width)))
 pad
    (cond ((> divisor 1)
        (cond ((< x divisor) (princ "0")))
        (setq divisor (/ divisor 10))
        (go pad)))
    (princ x)
    (setq left (- left width))
    (cond ((> left 0) (go outer)))
    (terpri)))
(rune)
(exit)
