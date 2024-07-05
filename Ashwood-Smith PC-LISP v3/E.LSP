; Compute e to 192 digits

(setq digits 200)
(array a t digits)
(setq high digits)
(setq count 0)
(setq x 0)
(setq n (- high 1))

(defun rune() (prog ()
    _nextn_
        (a 1 n)
        (cond ((plusp n)
               (setq n (sub1 n))
               (go _nextn_))
        )

    (a 2 1)
    (a 0 0)

    _nexthigh_
        (setq high (sub1 high))
        (setq n high)
        _nextn2_
            (a (mod x n) n)
            (setq x (+ (* 10 (a (sub1 n))) (/ x n)))
            (cond ((> n 1)
                   (setq n (sub1 n))
                   (go _nextn2_))
            )
        (princ x)
        (cond ((> high 9)
               (go _nexthigh_))
        )

    (return 0)
))

(setq startTime (sys:time))
(rune)
(setq endTime (sys:time))
(princ "\nelapsed seconds: ") (princ (- endTime startTime)) (princ "\n")

(exit)
