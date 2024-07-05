;;  MATCH.L for PC-LISP.EXE (V2.13)
;;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;  A DEDUCTIVE DATA BASE RETRIEVER AS PER LISPcraft CHAPTERS 21&22
;;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
;;        This file called match.l implements all of the functions in  
;;  chapters 21 and 22 of LISPcraft by R.Wilensky. Together they form     
;;  a deductive data base retriever with two access functions. One is   
;;  called (insert) and the other (retrieve). Insert takes implications
;;  and base cases and inserts them into the given data base. (retrieve)
;;  returns a list of matches made with the data base and any bindings
;;  neccssary to make the match true. Hence an output like (nil) means
;;  one match requiring no bindings. The functions have been slightly
;;  modified to run with PC-LISP.  Note that they require the PC-LISP.L
;;  file to be loaded specificially for the let macro and a few other
;;  goodies. If you put PC-LISP.L in the current directory it will be
;;  automatically loaded. Or you can put it in a library directory, see
;;  the (load) function.
;;
;;             August 22nd 1986  
;;                Peter Ashwood-Smith
;;
;;  Example queries:
;;            (mammal Fido)     gives (nil) meaning Yes he is a mammal
;;            (dog ?x)          gives (?x Fido) meaning Yes if (?x is Fido)
;;            (mammal ?x)       etc.. you get the idea.
;;            (? Fido)
;;
;;      You really cannot get much out of this example unless you get
;; the LISPcraft book. Have Fun!
  
;;
;; Main processing Loop - input a data base query, expand the variables
;; ?x to (*var* x) as the read macro in LISPcraft page 295 would do then 
;; pass the request to the (retrieve) function.
;;

(setsyntax '|?| 'vmacro '(lambda()(list '*var* (read))))

(setq displace-macros t)   ;runs much faster if let is displaced at eval time

(defun ProcessQueries (data-base)
       (prog (InputQuery)
	loop (princ "query?")
	     (setq InputQuery (read))   
	     (cond ((null InputQuery) (return)))
	     (princ "ans=")
	     (patom (CompressVariables (retrieve InputQuery data-base)))
	     (princ (ascii 10))   
	     (go loop)
       )
)

;;
;; Opposite of Read Macro for ? - turn list  elements like (*var* x) into
;; ?x
;;

(defun CompressVariables (List)
       (cond ((null List) ())
	     ((atom List) List)
	     ((eq (car List) '*var*)
		(implode (list '|?| (cadr List)))
	     )
	     (t (cons(CompressVariables(car List))(CompressVariables (cdr List))))
       )
)

;;
;; top level matcher function, just drives the recursive next level
;; by setting bindings to nil.
;;

(defun match (pattern1 pattern2) 
      (match-with-bindings pattern1 pattern2 nil)
)

(defun match-with-bindings (pattern1 pattern2 bindings)
      (cond ((pattern-var-p pattern1)
	       (variable-match pattern1 pattern2 bindings)
	    )
	    ((pattern-var-p pattern2)
	       (variable-match pattern2 pattern1 bindings)
	    )
	    ((atom pattern1)
	       (cond ((eq pattern1 pattern2) 
			 (list bindings)
		     )
	       )
	    )
	    ((atom pattern2) nil)
	    (t (let ((car-result    
		       (match-with-bindings
			 (car pattern1)(car pattern2) bindings)))     
		    (and car-result
		       (match-with-bindings
			 (cdr pattern1)
			 (cdr pattern2)
			 (car car-result)
		       )
		    )
	       )  
	    )
      )   
)

(defun variable-match (pattern-var item bindings)
       (cond ((equal pattern-var item) (list bindings))
	     (t (let ((var-binding (get-binding pattern-var bindings)))
		  (cond (var-binding
			  (match-with-bindings var-binding item bindings))
			((not (contained-in pattern-var item bindings))
			  (list (add-binding pattern-var item bindings)))
		  )
		)
	     )
       )
)

(defun contained-in (pattern-var item bindings)
      (cond ((atom item) nil)
	    ((pattern-var-p item)
	      (or (equal pattern-var item)
		  (contained-in pattern-var 
			       (get-binding item bindings)
				bindings)
	      )        
	    )
	    (t (or (contained-in pattern-var (car item) bindings)
		   (contained-in pattern-var (cdr item) bindings)
	       )
	    )         
      )
)

(defun add-binding (pattern-var item bindings)
       (cons (list pattern-var item) bindings)
)

(defun get-binding (pattern-var bindings)
       (cadr (assoc pattern-var bindings))
) 

(defun pattern-var-p (item)
       (and (listp item) (eq '*var* (car item)))
)

;; 
;; Fast Data Base Manager Operations. Using matcher function above to perform
;; deductive retreival. Indexing as per LISPcraft chapter 22.
;;

(defun replace-variables(item)
      (let ((!bindings ()))
	   (replace-variables-with-bindings item)))

(defun replace-variables-with-bindings(item)
      (cond ((atom item) item)
	    ((pattern-var-p item)
	     (let ((var-binding (get-binding item !bindings)))
		  (cond (var-binding)
			(t (let ((newvar (makevar (gensym 'var))))
				(setq !bindings
				   (add-binding item newvar !bindings))
			    newvar))
		  )
	     )
	    )
	    (t (cons (replace-variables-with-bindings (car item))
		     (replace-variables-with-bindings (cdr item))
	       )
	    )
      )
)

(defun makevar (atom)
       (list '*var* atom)
)

(defun query (request data-base)
       (apply 'append (mapcar '(lambda(item)(match item request))  
			      data-base
		      )
       )
)
   
(defun index (item data-base)
      (let ((place (cond ((atom (car item)) (car item))
			 ((pattern-var-p (car item)) '*var*)
			 (t '*list*)
		   )   
	    )
	   )
	   (putprop place (cons (replace-variables item)(get place data-base))
				data-base)
	   (putprop data-base
		   (enter place (get data-base '*keys*)) 
		  '*keys*) 
      )
)
  
(defun enter (e l)
      (cond ((not (memq e l)) (cons e l))
	    (t l)
      )
)

(defun fast-query (request data-base)
      (cond ((pattern-var-p (car request))
	     (apply 'append  
		(mapcar '(lambda(key)(query request (get key data-base)))
			 (get data-base '*keys*)
		)
	     )
	    )
	    (t (append
		 (query request (get (cond ((atom (car request))
					      (car request)
					   )
					   (t '*list*)
				      )
				      data-base
				)
		 )
		 (query request (get '*var* data-base))
	       )
	    )
      )
)   

;;
;; deductive retreiver (LISPcraft page 314) use backward chaining to establish
;; bindings.
;;

(defun retrieve (request data-base)
      (append
	  (fast-query request data-base)
	  (apply 'append  
	       (mapcar '(lambda(bindings)
			    (retrieve
				(substitute-vars
				   (get-binding '(*var* antecedent) bindings)
				   bindings)
				data-base))
			(fast-query (list '<- request '(*var* antecedent))
				    data-base)
		)
	  )
      )
)

;;
;; substitute variables for bindings recursively. LISPcraft page 315.
;;

(defun substitute-vars (item bindings)
      (cond ((atom item) item)
	    ((pattern-var-p item)
	       (let ((binding (get-binding item bindings)))
		    (cond (binding (substitute-vars binding bindings))
			  (t item)
		    )
	       )
	    )
	    (t (cons (substitute-vars (car item) bindings)
		     (substitute-vars (cdr item) bindings)
	       )
	    )
      )
)

;;
;; page 315 of LISPcraft add too !d-b1!
;; by calling index to insert the implications and base cases.
;;

(index  '(<- (scales ?x) (fish ?x)) '!d-b1!)       ; fishes have scales
(index  '(<- (fins ?x) (fish ?x)) '!d-b1!)         ; fishes have fins
(index  '(<- (legs ?x) (mammal ?x)) '!d-b1!)       ; some mammals have legs
(index  '(<- (mammal ?x) (dog ?x)) '!d-b1!)        ; a dog is a mammal
(index  '(<- (dog ?x) (poodle ?x)) '!d-b1!)        ; a poodle is a dog
(index  '(poodle Fido) '!d-b1!)                    ; fido is a poodle
(index  '(horse Terry) '!d-b1!)                    ; terry is a horse
(index  '(fish Eric) '!d-b1!)                      ; Eric is a fish

;;
;; start processing queries from data base #1 which was entered above
;; some good things to try are (mammal Fido) which will return (nil)
;; meaning that one match was found needing no bindings to make it true.
;; this was established via the chain (poodle Fido)-->(dog Fido)-->
;; (mammal Fido).
;;

(defun run() (ProcessQueries '!d-b1!))

(princ "Data Base Retreiver Loaded and Ready To Go")
(princ (ascii 10))
(princ "Just type (run) to start it, have fun.")
(princ (ascii 10))
