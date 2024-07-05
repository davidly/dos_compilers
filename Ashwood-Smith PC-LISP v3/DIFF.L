;          DIFF.L FOR PC-LISP V2.13
;          ~~~~~~~~~~~~~~~~~~~~~~~~
;    This module is kind of fun, it takes an expression in a prefix lisp
; like form and will compute the derivative of the expression with respect
; to the indicated variable. After symbolic differentiation is done some
; folding is done to remove redundant stuff from the expression. Eg we get
; rid of things multiplied by zero, and fold things with 0 added to them,
; or things raised to the power 1. This reduces the output complexity  
; significantly.          
;
;          Peter Ashwood-Smith
;          September 1986.
;
; D(e,X) -
;          Will compute the symbolic derivative of expression e with respect
; to varible X. We take the expression in standard lisp prefix form and will
; use the following rules of differentiation.
;
;         D(x)    = 1
;         D(a)    = 0
;         D(ln u) = D(u)/u 
;         D(u+v)  = D(u)+D(v)
;         D(u-v)  = D(u)-D(v)
;         D(u*v)  = D(u)*v + u*D(v)
;         D(u/v)  = D(u)*v + (u*D(v))/v^2
;         D(v^u)  = (v^u)*(u*D(v)/v + D(u)*ln(v))
;
(defun  D(e X &aux u v)
 (cond ((equal e X) 1) 
       ((atom e) 0)           
       (t (setq u (cadr e) v (caddr e))
	  (caseq (car e)
		 (ln `(/ ,(D u X) ,u)) 
		 (+  `(+ ,(D u X) ,(D v X)))
		 (-  `(- ,(D u X) ,(D v X)))
		 (*  `(+  (* ,(D u X) ,v) (* ,(D v X) ,u)))
		 (/  `(-  (/ ,(D u X) ,v)
			  (/ (* ,u ,(D v X)) (^ ,v 2))))
		 (^  `(* ,e  (+ (/ (* ,v ,(D u X)) ,u)
				   (* ,(D v X) (ln ,u)))))
		 (t (princ "ERROR") (exit)]

;
; Fold(e) -
;         Will traverse the expression 'e' and construct a new expression.
; It checks for things like (* 1 <exp>), (* <exp> 0), (^ <exp> 1), (+ <exp> 0)
; and replaces them with the appropriate things <exp>,0,<exp> and <exp>
; respectively. These simple algabraic modifications greatly reduce the output
; complexity but do not do a complete job by any means. We use the macros
; ?times, ?plus and ?power to do the dirty work for us. We set displace-macros
; to t to cause PC-LISP to substitute the code into the body of Fold thus
; making it much faster.
;

(setq displace-macros t)
 
(defmacro ?times(v e)
       `(and (eq (car ,e) '*) (member ,v ,e] 
 
(defmacro ?plus(v e)
       `(and (eq (car ,e) '+) (member ,v ,e] 
(defmacro ?power(v e)
       `(and (eq (car ,e) '^) (eq (caddr ,e) ,v] 

(defun Fold(e)
       (cond ((atom e) e)
	     (t (setq e (cons (Fold (car e)) (Fold (cdr e))))
		(cond ((?times 0 e) 0)
		      ((?times 1 e) (cond ((eq (cadr e) 1) (caddr e))
					  (t (cadr e))))
		      ((?power 1 e) (cadr e))
		      ((?plus  0 e) (cond ((eq (cadr e) 0) (caddr e))
					  (t (cadr e))))
		      (t e]

(defun Differentiate(e x)
       (Fold (D e x)] 

; ----------------- end if differentiate module ------------------


(princ "\t\tSYMBOLIC DIFFERENCIATION\n\n")
(princ "Following is the Input Expression Y\n")
(setq y '(* x (ln (+ x a))))
(pp-form y)

(princ "\nComputing 1st Derivitive of Y with respect to x, Y'\n")
(setq Dy (Differentiate y 'x))
(pp-form Dy)

(princ "\nComputing 2nd Derivitive of Y with respect to x, Y''\n")
(setq DDy (Differentiate Dy 'x))
(pp-form DDy)

(princ "\nComputing 3rd Derivitive of Y with respect to x, Y'''\n")
(setq DDDy (Differentiate DDy 'x))
(pp-form DDDy)

(princ "\nComputing 4th Derivitive of Y with respect to x, Y''''\n")
(setq DDDDy (Differentiate DDDy 'x))
(pp-form DDDDy)

(princ "\nComputing 5th Derivitive of Y with respect to x, Y'''''\n")
(setq DDDDDy (Differentiate DDDDy 'x))
(pp-form DDDDDy)

(princ "\n\nDone (finally)\n")
