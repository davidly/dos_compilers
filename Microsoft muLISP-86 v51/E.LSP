; Compute e to 192 digits

(setq digits 200)
(setq high digits)
(setq count 0)
(setq x 0)
(setq n (- high 1))

(defmacro m-ignore (fun &body body)
"ignores the return value of a function"
  `(progn (,fun ,@body)
  (values)))

(defun rune() (prog ()
    _nextn_
        (setf (aref a n) 1)
        (cond ((plusp n)
               (setq n (sub1 n))
               (go _nextn_))
        )

    (setf (aref a 1) 2)
    (setf (aref a 0) 0)

    _nexthigh_
        (setq high (sub1 high))
        (setq n high)
        _nextn2_
            (setf (aref a n) (mod x n))
            (setq x (+ (* 10 (aref a (sub1 n))) (truncate (/ x n))))
            (cond ((> n 1)
                   (setq n (sub1 n))
                   (go _nextn2_))
            )
        (princ x)
        (cond ((> high 9)
               (go _nexthigh_))
        )
    (return "")
))

(setq a (make-array digits :initial-element 0 ))
(setq startTime (time))
(clear-screen)
(rune)
(princ "elapsed hundredths of a second: ") (- (time) startTime) (TERPRI)

(system)
