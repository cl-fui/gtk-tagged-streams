(in-package :gtk-tagged-streams)

;;==============================================================================
;;
(defclass tb (gtk-text-buffer tb-output-mixin)
  ((usertag  :accessor usertag :initform nil); user input tagged with this
   (iter0    :accessor iter0 )	;a very temporary iterator...
   (iter1    :accessor iter1 )	;a very temporary iterator...
   (mcursor   :accessor mcursor)) ;a minor optimization
  (:metaclass gobject-class))

;;==============================================================================
(defmethod initialize-instance :after ((tb tb) &key)
  (with-slots (iter0 iter1 mcursor) tb
    (setf mcursor (gtb-get-insert tb)
	  iter0   (gtb-get-start-iter tb)
	  iter1   (gtb-get-start-iter tb))))

;;------------------------------------------------------------------------------
;;
;; TB-CURSOR-ITER   set iter0 at cursor
;;
(declaim (inline tb-cursor-iter))

(defun tb-cursor-iter (tb)
  "set iter0 to cursor"
  (with-slots (iter0) tb
    (%gtb-get-iter-at-mark tb iter0 (gtb-get-insert tb))
    iter0))


(defun tb-iters-to-offsets (tb start end)
  (with-slots (iter0 iter1) tb
    (%gtb-get-iter-at-offset tb iter0 start)
    (%gtb-get-iter-at-offset tb iter1 end)))

;;------------------------------------------------------------------------------
;;
;; Tag application
;;
;; This may be a stupid way to do it... TODO: is there a better way?
;;
(defun tb-apply-tag (tb tag start end)
  "place a tag at characters (start,end]"
;;  (format t "START END ~A ~A~&" start end)
  (tb-iters-to-offsets tb start end)
  (with-slots (iter0 iter1) tb
  ;;  (format t "APPLYING ~A ~A~&" (gti-offset iter0) (gti-offset iter1))
    (gtb-apply-tag tb tag iter0 iter1)))

(defun tb-remove-tag (tb tag start end)
  (tb-iters-to-offsets tb start end)
  (with-slots (iter0 iter1) tb
    (gtb-remove-tag tb tag iter0 iter1)))


(defmacro with-tag (tb tag &rest body)
  `(let ((start (gtb-cursor-position ,tb)))
     (progn ,@body)
     (tb-apply-tag ,tb ,tag start (gtb-cursor-position ,tb))))

(defmacro without-tag (tb tag &rest body)
  `(let ((start (gtb-cursor-position ,tb)))
     (progn ,@body)
     (tb-remove-tag ,tb ,tag start (gtb-cursor-position ,tb))))


(defun tb-cursor-backwards(tb &key count )
  (with-slots (iter0) tb
    (tb-cursor-iter tb)
    (when (if count
	      (gti-backward-cursor-positions iter0 count)
	      (gti-backward-cursor-position iter0))
      (gtb-place-cursor tb iter0))))
