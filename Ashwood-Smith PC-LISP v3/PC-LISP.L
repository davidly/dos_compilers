;; PC-LISP.L  for PC-LISP.EXE V2.15                                
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                                     
;;     A small library of functions to help fill in the gap between PC and      
;; Franz Lisp. These functions are not documented in the PC-LISP.DOC file but 
;; any Franz manual will cover them in detail. Especially the backquote 
;; and other macro definitions towards the end of the file. These functions
;; were written pretty hastily so there could be bugs. Check them out for
;; yourself to make sure they behave in the way you are used to with Franz.
;;
;;    This file is automatically loaded by PC-LISP.EXE. It should either    
;; be located in the current working directory, or in a library directory
;; whose path is set in the LISP_LIB environment variable. All load files
;; should be put in one of your LISP_LIB directories. You could also strip 
;; comments and white space from this file to make it load faster. This
;; is important if you load this file every time you run PC-LISP. 
;;      
;;              Peter Ashwood-Smith
;;                November 1986
;;
;; Pretty Print: (pp [(F file) (E expr) (P port)] symbol)
;; ~~~~~~~~~~~~
;;    Print in a readable way the function associated with 'symbol'. If
;; the parameter (F file) is specified the output goes to file 'file. If
;; the parameter (P port) is specified the output goes to the open port
;; 'port'. If the parameter (E expr) is specified the expression 'expr'
;; is evaluated before the function is pretty printed. Makes use of the
;; predefined symbol poport whose binding is 'stdout'.

(setq displace-macros t)        ; override Franz default (faster do loops)

(defun pp fexpr(l)
       (prog (expr name port alt)
	     (setq port poport)
	     (cond ((= (length l) 1) (setq name (car l)))
		   ((= (length l) 2) (setq name (cadr l) alt (car l)))
		   (t (return nil))
	     )
	     (cond ((null (getd name)) (return nil)))
	     (setq expr (cons 'def (cons name (list (getd name)))))
	     (cond ((null alt) (go SKIP)))   
	     (cond ((eq (car alt) 'F) (setq port (fileopen (cadr alt) 'w)))
		   ((eq (car alt) 'P) (setq port (cadr alt)))
		   ((eq (car alt) 'E) (eval (cadr alt)))
		   (t (return nil)))
	     (cond ((null port) (patom "cannot open port\n") (return nil)))
       SKIP  (pp-form expr port 0)
	     (cond ((not (equal port poport)) (close port)))
	     (return t)
       )
)

;; _SCL_ Spit Character Loop 
;; ~~~~~~~~~~~~~~~~~~~~~~~~~
;; Prints 'char' 'n' times on port 'port', used by msg for (N) and (B)
  
(defun _SCL_(port char n)
       (prog nil
	 nxt: (cond ((zerop n) (return)))
	      (patom char port)
	      (setq n (1- n))
	      (go nxt:)
       )
)     

;; (msg [B|N|D] [ (P pt) (B n) | (N n)] s*)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; Prints a message on standard output port 'poport'. Where N is a new
;; line, (N n) means n new lines. B is a blank, (B n) means n blanks 
;; D means (Dran port) unsupported in PC-LISP. (P pt) means switch output
;; to port pt rather than poport. s, is any s expression which will be 
;; evaluated and then printed on current output port.

(defun msg fexpr(l)
       (prog (s op)
	     (setq op poport)   
	nxt: (cond ((null l)(return)))
	     (setq s (car l) l (cdr l))
	     (cond ((eq s 'N) (patom "\n" op))
		   ((eq s 'B) (patom " " op))
		   ((eq s 'D) (patom "msg : Drain unsupported\n"))
		   ((listp s)
		       (cond ((eq (car s) 'P)(setq op (cadr s)))
			     ((eq (car s) 'B)(_SCL_ op " " (cadr s)))
			     ((eq (car s) 'N)(_SCL_ op "\n" (cadr s)))
			     (t (patom (eval s) op)) 
		       )
		   )
		   (t (patom (eval s) op))
	     )
	     (go nxt:)
       )
) 

;; (lineread [port])
;; ~~~~~~~~~~~~~~~~~
;; Very simple line read function. Takes atoms from the piport or port until
;; a new line is encountered. It returns these atoms or S-expressions as a
;; list 'ret. 

(defun lineread fexpr(l)
       (prog (port ret)
	     (setq port piport)   
	     (cond ((not (null l)) (setq port (eval (car l)))))
	     (setq ret (list (read port)))
	nxt: (cond ((eq (readc port) '|\n|)(return ret)))
	     (setq ret (append ret (list (read port))))
	     (go nxt:)
       )
)

;; ----------- ASSORTED SMALL FUNCTIONS ------------

(defun tailp(l1 l2)(cond ((null l2) nil)((eq l1 l2) l1)(t(tailp l1(cdr l2]  
(defun bcdp(x) nil)             
(defun bigp(x) nil)             
(defun dtpr(x) (and (listp x) (not (null x))))  
(defun consp(x) (and (listp x) (not (null x))))
(defun litatom(n) (and(atom n)(not(floatp n]   
(defun purep(n) nil)
(defun symbolp(n) (litatom n))                  
(defun valuep(n) nil)
(defun vectorp(n) nil)
(defun typep(n)(type n))
(defun eqstr(a b)(equal a b))
(defun neq(a b)(not(eq a b)))
(defun nequal(a b)(not(equal a b)))
(defun append1(a b)(append a (list b)))
(defun ncons(a)(cons a nil))
(defun xcons(a b)(cons b a))
(defun nthelem(n l) (nth (1- n) l))
(defun minus(n)(- 0 n))
(defun onep(n)(= 1 n))
(defun infile(f)(fileopen f 'r)) 
(defun pntlen(a) (flatsize a))
(defun probef(f &aux tmp)(setq tmp (fileopen f 'r))(and tmp (close tmp)))
(defun shell()(exec "COMMAND.COM"))     ; must have a COMMAND.COM on PATH!

(defun error n
       (cond ((= n 1) (patom (arg 1)) (terpri) (err nil))
	     ((= n 2) (patom (arg 1)) (patom (arg 2)) (terpri) (err nil))
	     (t (error "error bad args"))]

(defun signp(test exp)
       (cond ((eq test 'ge) (or (zerop exp)(plusp exp)))
	     ((eq test 'g ) (plusp exp))
	     ((eq test 'n ) (not (zerop exp)))
	     ((eq test 'e ) (zerop exp))
	     ((eq test 'le) (or (zerop exp)(minusp exp)))
	     ((eq test 'l)  (minusp exp))
	     (t (princ "-- error signp bad test ---\n"))))

;; ----------- ASSORTED SMALL MACROS --------------

(defun >&  macro(l) (cons '> (cdr l)))                
(defun >=  macro(l) (cons 'not (list (cons '< (cdr l))))) 
(defun >=& macro(l) (cons 'not (list (cons '< (cdr l)))))
(defun <&  macro(l) (cons '< (cdr l)))
(defun <=  macro(l) (cons 'not (list (cons '> (cdr l)))))
(defun <=& macro(l) (cons 'not (list (cons '> (cdr l)))))
(defun =&  macro(l) (cons '= (cdr l)))

(defun terpri macro(l)                      ; makes (terpri [port])
      (append (list 'princ "\n")(cdr l)))   ; into  (princ "\n" [port])
(defun tyo macro(l)                         ; makes (princ (asci f) [port])
      (cons 'princ (cons (cons 'ascii (list (cadr l))) (cddr l))))
(defun store macro(l)                       ; makes (store (x -dims-) exp)
      (cons (caadr l)                       ; into  (x exp -dims-)
	    (append (cddr l) (cdadr l))))
(defun arraycall macro(l)                   ; makes (arraycall f a -n-)
      (cddr l))                             ; into  (a -n-)

;; BACKQUOTE READ MACRO AND PARTS  
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;      This  file  describes  the back quote macro for PC-LISP. It works in
;; exactly the same way as the  FRANZ  backquote  macro works. Basically the
;; backquote macro ` is supposed to  work  together  with the comma , and at
;; @ macros. As follows: Backquote  has the same effect as ' except that any
;; elements or  sub  elements  that  are preceeded by , are evaluated. If an
;; element  is  preceeded  by  ,@  then  the element is evaluated and should 
;; evaluate to  a  list.  This  list  is  spliced into the built list. I use 
;; cons  to  do  list  building  and append to do list splicing. For example
;; the  input:  `(a ,b c)  will  be  read in  as  (a (*unquote* b) c) by the
;; back quote read macro because the  comma  macro  will have read the b and
;; built up the list (*unquote* b). Next the back quote macro passes control
;; to the _BQB_ function (Back Quote  Builder). This will construct the list
;; (cons 'a (cons b (cons 'c nil)))  which  when evaluated gives the desired    
;; result. If the , were  followed  by  an @ then the @ would build the form
;; (*splice* b). Then the  , would get this form and the function _CB_ comma
;; builder would then make  then pass the form unchanged. Next the backquote
;; builder  _BQB_  would  get the form (a (*splice* b) c) and build the form
;; (cons 'a (append b (cons 'c nil)))  which will cause the value of b to be
;; spliced into the list rather than forming a sublist element as desired.

(defun _BQB_(Sexp) 
       (cond ((null Sexp) Sexp)
	     ((atom Sexp) (list 'quote Sexp))
	     ((eq (car Sexp) '*unquote*)
		  (cadr Sexp))
	     ((and(listp (car Sexp)) (eq (caar Sexp) '*splice*))
		  (list 'append (cadar Sexp)
			     (_BQB_ (cdr Sexp))))
	     ( t (list 'cons (_BQB_ (car Sexp))
			     (_BQB_ (cdr Sexp))))
       )
)

(defun _CB_(Sexp)
       (cond ((null Sexp) Sexp)
	     ((atom Sexp) (list '*unquote* Sexp))
	     ((eq (car Sexp) '*splice*) Sexp)
	     (t (list '*unquote* Sexp))
       )
)

(setsyntax '|`| 'vmacro '(lambda()(_BQB_ (read))))
(setsyntax '|,| 'vmacro '(lambda()(_CB_  (read))))
(setsyntax '|@| 'vmacro '(lambda()(list '*splice* (read))))


;; macro  : (let ((p1 v1)(p2 v2)...(pn vn)) e1 e2 ... en)
;; ~~~~~  
;;      Let macro introduces local variables. Much used in Franz code it
;; basically creates a lambda expression of the form:
;;
;;          ((lambda(p1 p2 ... pn) e1 e2 ... en) v1 v2 ...vn)
;; Note that (p1 v1) may be of the form p1 in which case the variable
;; is bound to nil. 

(defun let macro(l)
    `((lambda ,(mapcar '_lvar (cadr l))
	     ,@(cddr l)
      )
      ,@(mapcar '_lval (cadr l] 

(defun _lvar (l)(cond ((atom l) l) (t (car l]    

(defun _lval (l)(cond ((atom l) nil) (t (cadr l]    

;; macro defmacro
;; ~~~~~~~~~~~~~~
;;    Like defun except that it declares a macro. This is more convenient
;; than using the defun name macro(l) because access to variables can be
;; named. 

(defun defmacro fexpr(l)
    (putd (car l)
	  (cons 'macro 
	     (list '(defmacroarg)
		   `((lambda ,(__dmlats (cadr l))  
			     ,@(cddr l))
		     ,@(__dmal (cadr l))]

(defun defcmacro fexpr(l)         ; no such thing as compiler yet but
    (putd (car l)                 ; keeps interpreter happy
	  (cons 'macro 
	     (list '(defmacroarg)
		   `((lambda ,(__dmlats (cadr l))  
			     ,@(cddr l))
		     ,@(__dmal (cadr l))]

(defun __dma(l a)
      (cond ((null l) nil)
	    ((atom l) (setq __dmalhold (cons a __dmalhold)))      
	    (t (__dma (car l) (cons 'car (list a)))
	       (__dma (cdr l) (cons 'cdr (list a)))]

(defun __dmal(l &aux __dmalhold)
	(__dma l '(cdr defmacroarg)) 
	(reverse __dmalhold ]

(defun __dmlats(l)
	(cond ((null l) nil)
	      ((atom l) (list l))
	      ( t (append (__dmlats (car l)) (__dmlats (cdr l)))]

;;  (do "symbol" "exp1" "exp2" "test" -"exps"-)        ; case 1
;;  (do -"(symbol [exp1 [exp2]])"- "test" -"exps"-)    ; case 2
;;   
(defun _do2a_(l) (cond ((cdr l)(cons (car l) (list(cadr l))))(t nil]  
(defun _do2b_(l) (cond ((cddr l)(cons (car l) (list(caddr l))))(t nil]  

(defun _do2_(l)                            ; complex do loop case, many locals
     `(prog ,(mapcar 'car (cadr l))
	    (PAR-setq ,@(apply 'append (mapcar '_do2a_ (cadr l))))
     _dlab_ 
	    (cond (,(caaddr l) (return ,@(cdaddr l)) )) 
	    ,@(cdddr l)
	    (PAR-setq ,@(apply 'append (mapcar '_do2b_ (cadr l))))
	    (go _dlab_)
      )
)

(defun _do1_(l)                            ; simple do loop case, one local
     `(prog (,(nth 1 l))
	    (setq ,(nth 1 l) ,(nth 2 l))
     _dlab_ (cond (,(nth 4 l) (return))) 
	    ,@(cdddddr l)
	    (setq ,(nth 1 l) ,(nth 3 l))
	    (go _dlab_)
      )
)

(defun do macro(l)                        ; select simple/complex case.
       (cond ((atom (cadr l)) (_do1_ l))
	     (t (_do2_ l))))

;; This macro allow the following forms:
;;      (if a then b)   ==>  (cond (a b))
;;      (if a thenret)  ==>  (cond (a))
;;      (if a then b else c) ==> (cond (a b) (t c))
;;      (if a then b b2              ==> (cond (a b b2) (c d d2) (t e))
;;       elseif c then d d2
;;       else e)
;;
;;  I stole this from the SLANG package and changed its name to 'if from
;; 'If.
;;
(defun if macro  (lis) 
       (prog (majlis minlis revl)
	     (do ((revl (reverse lis) (cdr revl)))
		 ((null revl))
		 (cond ((eq (car revl) 'else)
			(setq majlis `((t ,@minlis) ,@majlis)
			      minlis nil))
		       ((or (eq (car revl) 'then) (eq (car revl) 'thenret))
			(setq revl (cdr revl)
			      majlis `((,(car revl) ,@minlis) ,@majlis)
			      minlis nil))
		       ((eq (car revl) 'elseif))
		       ((eq (car revl) 'if)
			(setq majlis `(cond ,@majlis)))
		       (t (setq minlis `( ,(car revl) ,@minlis)))))
	     ; we displace the previous macro, that is we actually replace
	     ; the if list structure with the corresponding cond, meaning
	     ; that the expansion is done only once
	     (rplaca  lis (car majlis))
	     (rplacd lis (cdr majlis))
	     (return majlis)))

;; A couple of rareley used definitions but just to complete the chapter
;; on mapping functions, here they are:
;;
(defun mapcan macro(l) `(apply 'nconc (mapcar ,@(cdr l))))
(defun mapcon macro(l) `(apply 'nconc (maplist ,@(cdr l))))

;; The progS functions again to fill in some gaps
;;
(defun progn macro(l) `(prog nil ,@(cdr l)))
(defmacro prog1(a . b) `(prog (__p1ret) (setq __p1ret ,a) ,@b __p1ret))
(defmacro prog2(a b . c) `(prog (__p2ret) ,a (setq __p2ret ,b) ,@c __p2ret))

