(in-package :gtk-tagged-streams)



(eval-when (:compile-toplevel :load-toplevel)

(defun make-synonym (old newname &key (package (symbol-package old)) (overwrite nil))
     "make a synonym for old symbol using newname, optionally in a different package.
 Functions only."
     (unless overwrite
       (when (find-symbol newname package)
	 (error "~%Symbol ~A already exists in package ~A." newname package)))
     (let ((new-sym (intern newname package)))
       (setf (symbol-function new-sym) (symbol-function old))
       (export new-sym package)
       new-sym))

(defun abbrev-symbols (package old-prefix new-prefix)
  "Create synonyms starting with 'new-prefix' for function symbols 
starting with 'old-prefix' in :package.  Remember to capitalize "
  (let ((old-prefix-length (length old-prefix)))
    (do-symbols (sym (find-package package))
      (when (fboundp sym) ;functions only
       	(let ((sym-name (symbol-name sym)))
	  (alexandria:when-let (match (search old-prefix sym-name))
	    (when (zerop match)
	      (let* ((abbrev-sym-name
		      (concatenate 'string new-prefix
				   (subseq sym-name old-prefix-length))))
		(make-synonym sym abbrev-sym-name :package package :overwrite t)))))))))

  (abbrev-symbols :gtk "GTK-TEXT-VIEW-"      "GTV-")
  (abbrev-symbols :gtk "GTK-TEXT-ITER-"      "GTI-")
  (abbrev-symbols :gtk "%GTK-TEXT-ITER-"     "%GTI-")
  (abbrev-symbols :gtk "GTK-TEXT-BUFFER-"    "GTB-")
  (abbrev-symbols :gtk "GTK-TEXT-MARK-"      "GTM-")
  (abbrev-symbols :gtk "GTK-TEXT-TAG-"       "GTT-")
  (abbrev-symbols :gtk "GTK-TEXT-TAG-TABLE-" "GTTT-")
  (abbrev-symbols :gtk "%GTK-TEXT-BUFFER-"   "%GTB-"))

(defmacro prognil (&body body)
  `(progn ,@body nil))

(defmacro progt (&body body)
  `(progn ,@body t))

(defmacro mvb (&body rest)
  "synonym for multiple-value-bind"
  `(multiple-value-bind ,@rest))

(defmacro mvs (&rest rest)
  "synonym for multiple-value-setq"
  `(multiple-value-setq ,@rest))

(defmacro fsv (&rest rest)
  `(foreign-slot-value ,@rest))

(defmacro increment-within-range (item &key by min max)
  "increment (or decrement if 'by' is negative) item if the result is within
 range (inclusive min).  Return result or nil if no increment took place."
  `(let ((val (+ ,item ,by)))
    (and (>= val ,min)
	 (<  val ,max)
	 (setf ,item val))))


(defun string-ell-out (string limit stream)
  "stream out a string; if it is longer than limit, ellipsize. "
  (let ((len (length string)))
    (if (<= len limit)
	(format stream "~A" string)
	(let ((chunk (- (round (/ limit 2)) 6)))
	  (format stream "~A...<~A>...~A"
		  (subseq string 0 chunk)
		  len
		  (subseq string (- len chunk) ))))))

;;==============================================================================
;; execute rest in idle thread, binding *package*
(defmacro idly (&rest rest)
  `(gdk-threads-add-idle (lambda () 
			   ,@rest)))

(defmacro gsafe (&rest body)
  "execute body safely inside gtk main thread"
  `(unwind-protect
	(progn
	  (gdk-threads-enter)
	  ,@body)
     (gdk-threads-leave)))

(defun hsv (h s v)
  "convert hsv color to a gdk-rgba"
  (let* ((hi (mod (floor h 60) 6))
	 (f (float (- (/ h 60) hi)))
	 (p  (* v (- 1 s)))
	 (q  (* v (- 1 (* f s))))
	 (tt (* v (- 1 (* (- 1 f) s)))))
    (labels ((helper (r g b)
	       (make-gdk-rgba :red   (coerce r 'double-float)
			      :green (coerce g 'double-float)
			      :blue  (coerce b 'double-float)
			      :alpha 1.0d0)))
      (ecase hi
	(0 (helper v tt p))
	(1 (helper q v p))
	(2 (helper p v tt))
	(3 (helper p q v))
	(4 (helper tt p v))
	(5 (helper v p q))))) )
