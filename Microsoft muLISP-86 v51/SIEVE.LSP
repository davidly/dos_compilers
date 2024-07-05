; BYTE magazine's Sieve benchmark

(setq size 8190)
(setq a (make-array (+ size 1) :initial-element 0 ))
(setq count 0)

(defun kloop(k prime)
    (loop
        (when (> k size) (return 0))
        (setf (aref a k) nil)
        (setq k (+ k prime))
    )
)

(defun runsieve() (prog ()
    (setq i 0)
    (setq count 0)
    _nexti_
        (cond ((<= i size)
               (setf (aref a i) t)
               (setq i (add1 i))
               (go _nexti_))
        )

    (setq i 0)
    _nexti2_
        (cond ((<= i size)
               (cond ((aref a i)
                      (setq prime (+ i i 3))
                      (kloop (+ i prime) prime)
                      (setq count (add1 count)))
               )
               (setq i (add1 i))
               (go _nexti2_))
        )
))

(defun main() (prog ()
    (princ "running...")
    (setq startTime (time))

    (dotimes (z 10) (runsieve))
    (princ "count: ") (princ count)
    (princ "elapsed hundredths of a second: ") (- (time) startTime)
))

(main)
(system)

