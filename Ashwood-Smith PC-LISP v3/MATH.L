
;================;           Bill Forseth
; TRIG FUNCTIONS ;           817 1/2 N. 10 ave E.
;    11.27.89    ;           Duluth, MN 55805
;================;           (218) 724-8910



; NOTES:  All function inputs evaluating to 'undefined' are returned as '0'.
; BUGS:   PC-LISP's sin and cos functions evaluate pi at 3.141. In increasing
;         the the length of the fractional part of pi cos and sin had to be
;         semi-redefined (via functions chkman and round, mostly). Thus the
;         angle functions return 0, -.5, .5, 1, -1, 2 etc. when they should -
;         BUT for very small angle differences (i +/- 0.00001 radians where
;         i is any integer) the result becomes rounded.
;         As far as I know the equations are accurate - they were checked with
;         formulas found in any standard algebra/trig/calc textbook.
; FUTURE: Elaboration of differentials, perhaps symbolic routines for
;         factoring standard and differential combinations.


;-------------------------------------------------
; PPOWER
; Returns x to the n-th (where x and n may be
; positive or negative, whole numbers or fractions).
; Attmepts at taking the root of a negative are headed
; off and the function returns the abs value.
; Syntax: (ppower <constant> <exponent>)
;     ie: (ppower 25 -0.5)
;--------------------------------------------------
(defun ppower (x n)
    (cond
        ((zerop x) 0) ((= 1 n) x)
        ((or (zerop n) (= 1 x)) 1)
        ((minusp n) (invert (ppower x (abs n))))
        ((> 1 n) (expt (abs x) n))
        (t
            (** x (ppower x (diff n 1))))))

;---------------------------------------
; LLOG
; Returns log(a) / log(b)
; Syntax: (llog <argument1> <argument2>)
;     ie: (llog 2 16)
;---------------------------------------
(defun llog (a b)
    (cond
        ((or (= 1 b) (= 1 a) (zerop a)
             (zerop b) (minusp a) (minusp b)) 0)
        (t (// (log b) (log a)))))

;----------------------------------------
; ADJRAD
; Puts x in the range of 0 <= x < 2pi,
; x in radians.
; Syntax: (adjrad <argument>)
;     ie: (adjrad 31.41)
;----------------------------------------
(defun adjrad (x)
    (cond
        ((= (abs x) (2pi)) 0)
        ((< x 0) (adjrad (add x (2pi))))
        ((> x (2pi)) (adjrad (diff x (2pi))))
        (t  x)))

;----------------------------------------
; ADJDEG
; Puts d in the range of 0 <= d < 360,
; d in degrees.
; Syntax: (adjdeg <argument>)
;     ie: (adjdeg -780)
;----------------------------------------
(defun adjdeg (d)
    (cond
        ((or (zerop d) (= (abs d) 360)) 0)
        ((> d 360) (adjdeg (diff d 360)))
        ((< d 0) (adjdeg (add d 360)))
        (t d)))

;-------------------------------
; D2R
; Converts degrees to radians.
; Syntax: (d2r <argument>)
;     ie: (d2r 180)
;-------------------------------
(defun d2r (x)
    (// (** (adjdeg x) (pi)) 180))

;-------------------------------
; R2D
; Converts radians to degrees.
; Syntax: (r2d <argument>)
;     ie: (r2d 3.14)
;-------------------------------
(defun r2d (x)
    (// (** (adjrad x) 180) (pi)))

;---------------------------------------
; PI functions
; All arguments in positive or negative,
; whole numbers or fractions.
;---------------------------------------

(defun pi () 3.141592)               ;Returns the value of pi to 6th place
                                     ;(not rounded)
                                     ;Syntax: (pi)

(defun pi/ (x) (// (pi) x))          ;Returns pi divided by x
                                     ;Syntax: (pi/ <argument>)

(defun pi* (x) (** (pi) x))          ;Returns pi times x
                                     ;Syntax: (pi* <argument>)

(defun pi*/ (n d)                    ;Returns pi times n/d
    (** (pi) (// n d)))              ;Syntax: (pi*/ <argument1> <argument2>)
(defun pi/* (n d)                    ;<-- forgiving function
    (** (pi) (// n d)))


;Shorthand pi functions for frequently used angles - -

(defun 2pi () (pi* 2))     ;360 deg.
(defun pi2 () (pi/ 2))     ;90   "
(defun pi3 () (pi/ 3))     ;60   "
(defun pi4 () (pi/ 4))     ;45   "
(defun pi6 () (pi/ 6))     ;30   "

;-----------------------------------------
; SINr
; Modified sin for the current value of pi
; Syntax: (sinr <argument>)
;-----------------------------------------
(defun sinr (x) (chkman (sin (adjrad x))))

;-----------------------------------------
; COSr
; Modified cos for the current value of pi
; Syntax: (cosr <argument>)
;-----------------------------------------
(defun cosr (x) (chkman (cos (adjrad x))))

;--------------------------------------
; TANr
; Returns the tangent of x, where x is
; in radians.
; Syntax: (tanr <argument>)
;--------------------------------------
(defun tanr (x)
    (cond
        ((or (zerop (cosr x)) (zerop (sinr x))) 0)
        (t (chkman (adjrad (// (sinr x) (cosr x)))))))

;-------------------------------
; SINd
; Returns sin of DEGREE argument
; Syntax: (sind <argument>)
;-------------------------------
(defun sind (d) (chkman (adjrad (sinr (d2r d)))))

;-------------------------------
; COSd
; Returns cos of DEGREE argument
; Syntax: (cosd <argument>)
;-------------------------------
(defun cosd (d) (chkman (adjrad (cosr (d2r d)))))

;---------------------------------------
; TANd
; Returns the tangent of DEGREE argument
; Syntax: (tand <argument>)
;---------------------------------------
(defun tand (d)
    (cond
        ((or (zerop (cosd d)) (zerop (sind d))) 0)
        (t (chkman (adjrad (// (sind d) (cosd d)))))))

;-----------------------------
; INVERSE functions
; Arguments (___r) in radians,
; (___d) in degrees.
;-----------------------------
(defun secr (x) (adjrad (invert (cosr x))))

(defun cscr (x) (adjrad (invert (sinr x))))

(defun cotr (x) (adjrad (invert (tanr x))))

(defun secd (d) (adjdeg (invert (cosd d))))

(defun cscd (d) (adjdeg (invert (sind d))))

(defun cotd (d) (adjdeg (invert (tand d))))


;--------------------------
; DERIVITIVE functions
; All arguments in radians.
;--------------------------
(defun sin_prime (x) (cosr x))

(defun cos_prime (x) (neg (sinr x)))

(defun tan_prime (x) (chkman (adjrad (ppower (secr x) 2))))

(defun sec_prime (x) (chkman (adjrad (** (secr x) (tanr x)))))

(defun csc_prime (x) (chkman (adjrad (neg (** (cscr x) (cotr x))))))

(defun cot_prime (x) (chkman (adjrad (ppower (cscr x) 2))))


;------------------------------------------------
; DOUBLE and HALF angles formulas.
; All arguments in radians.
; To use degrees use (d2r d) as the arguments.
; To have the return in degrees nest the function
; inside (r2d (<. . .>))
;-------------------------------------------------
(defun sinA+B (a b)
    (chkman (adjrad (add (** (sinr a) (cosr b)) (** (cosr a) (sinr b))))))

(defun sinA-B (a b)
    (chkman (adjrad (diff (** (sinr a) (cosr b)) (** (cosr a) (sinr b))))))

(defun cosA+B (a b)
    (chkman (adjrad (diff (** (cosr a) (cosr b)) (** (sinr a) (sinr b))))))

(defun cosA-B (a b)
    (chkman (adjrad (add (** (cosr a) (cosr b)) (** (sinr a) (sinr b))))))

(defun tanA+B (a b)
    (cond
        ((zerop (cosA+B a b)) 0)
        (t (chkman (adjrad (// (sinA+B a b) (cosA+B a b)))))))

(defun tanA-B (a b)
    (cond
        ((zerop (cosA-B a b)) 0)
        (t (chkman (adjrad (// (sinA-B a b) (cosA-B a b)))))))



(defun sin2A (a)
    (chkman (adjrad (** 2 (sinr a) (cosr a)))))

(defun cos2A (a)
    (chkman (adjrad (diff (ppower (cosr a) 2) (ppower (sinr a) 2)))))

(defun tan2A (a)
    (cond
        ((zerop (cos2A a)) 0)
        (t (chkman (adjrad (// (sin2A a) (cos2A a)))))))



(defun sinhalfA (a)
    (chkman (adjrad (sqrt (abs (// (diff 1 (cosr a)) 2))))))

(defun coshalfA (a)
    (chkman (adjrad (sqrt (abs (// (add 1 (cosr a)) 2))))))

(defun tanhalfA (a)
    (cond
        ((zerop (coshalfA a)) 0)
        (t (chkman (adjrad (// (sinhalfA a) (coshalfA a)))))))


;-------------------------
; MISC functions
;-------------------------

(defun invert (x)                          ;returns 1/x
    (cond ((zerop x) 0) (t (chkman (// 1 x)))))


(defun neg (x) (** -1 x))                  ;returns -x


(defun // fexpr(l) (eval (cons 'quotient l)))  ;shorthand div. of floats


(defun ** fexpr(l) (eval (cons 'times l)))     ;shorthand mult. of floats


(defun chkman (x)                          ;returns nearest whole number if
    (cond                                  ;fraction is very small or large
        ((< (abs (diff (abs x) (abs (round x)))) 0.00001)
            (round x))
        (t x)))


(defun round (x)                           ;rounding function
    (cond
        ((zerop x) 0)
        ((plusp x)
           (cond
                ((< (diff x (fix x)) .5) (fix x))
                (t (add 1 (fix x)))))
        (t (cond
                ((< (diff (abs x) (fix (abs x))) .5) (fix x))
                (t (neg (diff 1 (fix x))))))))



(defun gint (x)                            ;greatest integer function
    (cond
        ((zerop x) 0)
        ((plusp x) (fix x))
        ((minusp x)
            (cond
                ((= x (fix x)) x)
                (t (diff (fix x) 1))))
        (t x)))


(defun rangep (a x b)                      ;true if a <= x <= b
    (cond
        ((and (not (< x a)) (not (> x b))) t)
        (t nil)))

