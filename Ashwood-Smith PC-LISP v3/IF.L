;--- super if macro
; This macro allow the following forms:
;       (If a then b)   ==>  (cond (a b))
;       (If a thenret)  ==>  (cond (a))
;       (If a then b else c) ==> (cond (a b) (t c))
;       (If a then b b2              ==> (cond (a b b2) (c d d2) (t e))
;        elseif c then d d2
;        else e)
;
;
(defun If macro  (lis) 
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
		       ((eq (car revl) 'If)
			(setq majlis `(cond ,@majlis)))
		       (t (setq minlis `( ,(car revl) ,@minlis)))))
	     ; we displace the previous macro, that is we actually replace
	     ; the if list structure with the corresponding cond, meaning
	     ; that the expansion is done only once
	     (rplaca  lis (car majlis))
	     (rplacd lis (cdr majlis))
	     (return majlis)))

;--- msg : print a message consisting of strings and values
