; BYTE magazine's Sieve benchmark

(setq size 8190)
(array a t (+ size 1))
(setq count 0)

(defun runsieve() (prog ()
    (setq i 0)
    (setq count 0)
    _nexti_
        (cond ((<= i size)
               (a t i)
               (setq i (add1 i))
               (go _nexti_))
        )

    (setq i 0)
    _nexti2_
        (cond ((<= i size)
               (cond ((a i)
                      (setq prime (+ i i 3))
                      (setq k (+ i prime))
                      (prog ()
                          _nextk_
                              (cond ((<= k size)
                                     (a nil k)
                                     (setq k (+ k prime))
                                     (go _nextk_))
                              )
                      )
                      (setq count (add1 count)))
               )
               (setq i (add1 i))
               (go _nexti2_))
        )
))

(defun main() (prog ()
    (setq startTime (sys:time))

    (setq l 1)
    _nextl_
        (cond ((<= l 10)
               (runsieve)
               (princ l) (princ " ")
               (setq l (add1 l))
               (go _nextl_))
        )

    (princ "count: ") (princ count) (princ "\n")
    (setq endTime (sys:time))
    (princ "\nelapsed seconds: ") (princ (- endTime startTime)) (princ "\n")
))

(main)
(exit)

