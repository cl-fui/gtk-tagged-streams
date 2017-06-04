(in-package :gtk-tagged-streams)

;;==============================================================================
;;
;; Note: if usertagging is not desired, set usertag to null, or to temporarily
;; disable for key, set utagstart to null.
(defclass tv (gtk-text-view)
  ((usertag  :accessor usertag :initarg :usertag :initform nil); user input tagged with this
   (utagstart :accessor utagstart :initform nil))

  (:metaclass gobject-class))

;;==============================================================================
(defmethod initialize-instance :after ((tv tv) &key)
  ;;----------------------------------------------------------------------
  ;; Marking keyboard input with a tag
  ;;
  ;; In order to tag keyboarded input, we must isolate before and after
  ;; positions.  Key-down and key-up work fine, with a minor glitch
  ;; (tag is not applied until key is lifted), but it is ok for now.
  ;; Edge conditions include: -system starts with the key down; non-print
  ;; motion keys must be filtered, etc.
  (with-slots (utagstart usertag) tv
    (when usertag;; lifelong commitment
      (let ((buffer (gtv-buffer tv)))

	(g-signal-connect
	 tv "key-press-event"
	 (lambda (tv event)
	   ;;(format t "KEY-DOWN ~A~&"(gdk-event-key-keyval event))
	   (unless utagstart
	     (when (< (gdk-event-key-keyval event) #xF000); filter prints
	       (setf utagstart (gtb-cursor-position buffer))))
	   nil))
	
	(g-signal-connect
	 tv "key-release-event"
	 (lambda (tv event)
	   ;;(format t "KEY-UP ~A~&"(gdk-event-key-keyval event))
	   (let ((utagend (gtb-cursor-position buffer)))
	     (and utagstart
		  (/= utagstart utagend)
		  (tb-apply-tag buffer usertag utagstart utagend ))
	     (setf utagstart nil))
	   nil))))))
