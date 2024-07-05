;; TURTLE.L for PC-LISP.EXE V2.13
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;    A set of rough turtle graphics primitives to demonstrate PC-LISP's BIOS 
;; graphics routines. These routines are pretty self explanitory. The first
;; 5 defun's define the primitives, next are a set of routines to draw things
;; like squares, triangles etc. Try the function (GraphicsDemo). It will
;; draw Squirals, Trianglerals, etc. Note that the BIOS line drawing is really
;; slow. This is because the BIOS 'set dot/pixel' routine is used for every
;; point in a line. Using the BIOS has the advantage however of portability,
;; these routines work on virtually every MS-DOS machine. The global variable
;; !Mode controls the graphics resolution that will be used. It is set by 
;; default to 6, I set it to 8 or 9 for my Tandy 2000. You can adjust the code
;; to support your machines higher resolution modes. More 640x400 modes can be
;; supported by (= !Mode NN) at ### PATCH POINT 1 ### where NN is the value
;; to pass to (#srcmde#) Ie the value to pass in AH when INT 10H is generated
;; with AL=0 (the BIOS Set CRT Mode call). If your machines has high resolution 
;; modes besides the 640x400 say X * Y resolution associated with mode NN then
;; add the following code at ### PATCH POINT 2 ### (where AA is X/2, BB is Y/2
;; CC is the ratio X/Y and DD is the number of pixels that should correspond
;; to one Turtle movement Unit):
;;
;;           ((= !Mode NN)                         
;;            (setq CenterX AA CenterY BB Scale CC Lfactor DD) 
;;            (TurtleCenter))  
;;
;;                      Peter Ashwood-Smith
;;                      August 22nd, 1986 
;;

(setq !Mode 6)                                         ; default setting

(defun TurtleGraphicsUp()           
       (#scrmde# !Mode)(#scrsap# 0)      
       (cond ((= !Mode 6)                              ; 640x200 B&W mode
	      (setq CenterX 100 CenterY 100 Scale 3.2 Lfactor 1) 
	      (TurtleCenter))  
;
	     ((= !Mode 7)
	      (patom '|mode 7 not allowed|))
;
	     ((or (= !Mode 8) (= !Mode 9)              ; Tandy 2000 640x400
		  (= !Mode 64)                         ; AT&T  6300 640x400?
		  ; ### PATCH POINT 1 ###
	      )  
	      (setq CenterX 266 CenterY 200 Scale 1.2 Lfactor 2) 
	      (TurtleCenter))  
;
;            ### PATCH POINT 2
;
	     (t (patom '|unsupported mode|))
       )
)   

(defun TurtleGraphicsDown()
       (#scrmde# 2))

(defun TurtleCenter()    
      (setq Lastx CenterX Lasty CenterY Heading 1.570796372))

(defun TurtleRight(n)   
      (setq Heading (plus Heading (times n 0.01745329))))

(defun TurtleLeft(n)    
      (setq Heading (diff Heading (times n 0.01745329))))

(defun TurtleGoTo(x y)  
      (setq Lastx (quotient x Scale) Lasty (times y Lfactor) )) 

(defun TurtleForward(n) 
      (setq n (times n Lfactor)
	    Newx (plus Lastx(times(cos Heading)n))
	    Newy (plus Lasty(times(sin Heading)n)))
      (#scrline# (times Lastx Scale) Lasty (times Newx Scale) Newy 1)
      (setq Lastx Newx Lasty Newy)
)

;
; end of Turtle Graphics primitives, start of Graphics demonstration code
; you can cut this out if you like and leave the Turtle primitives intact.
;

(defun Line_T(n)        
	(TurtleForward n) (TurtleRight 180)
	(TurtleForward (quotient n 4)) 
)
	
(defun Square(n)
	(TurtleForward n)  (TurtleRight 90)     
	(TurtleForward n)  (TurtleRight 90)     
	(TurtleForward n)  (TurtleRight 90)     
	(TurtleForward n)                       
)

(defun Triangle(n)
	(TurtleForward n)  (TurtleRight 120)
	(TurtleForward n)  (TurtleRight 120)
	(TurtleForward n)
)

(defun Make(ObjectFunc Size times skew) 
      (prog()       
       TOP:(cond ((zerop times) (return)))
	   (ObjectFunc Size) 
	   (TurtleRight skew)
	   (setq times (1- times))
	   (go TOP:)    
       )
)

(defun GraphicsDemo()
	   (TurtleGraphicsUp) 
	   (Make Square 40 18 5) (Make Square 60 18 5)
	   (gc)                                              ; idle work
	   (TurtleGraphicsUp) 
	   (Make Triangle 40 18 5) (Make Triangle 60 18 5)
	   (gc)                                              ; idle work
	   (TurtleGraphicsUp) 
	   (Make Line_T 80 50 10)
	   (gc)                                              ; idle work
	   (TurtleGraphicsDown)
)

