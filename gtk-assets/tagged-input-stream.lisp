(in-package :gtk-tagged-streams)
;;=============================================================================
;; tagged-input-stream
;;
;; 
;; Treat the context (i.e. tag) used to open this stream as the stream limit

(defclass tag-input-stream
    (trivial-gray-streams:fundamental-character-input-stream)
  ((buffer   :accessor buffer :initarg :buffer)
   (iter     :accessor iter   :initform nil)
   (mark     :accessor mark   :initform nil);; preserving position
   (tag      :accessor tag    :initarg :tag)  ;; ref tag we are filtering on

   ))

;;=============================================================================
(defmethod close ((stream tag-input-stream) &key abort)
  (declare (ignore abort))
  (with-slots (buffer iter mark tag) stream
    (gtb-delete-mark buffer mark)
    t))



;;=============================================================================
;;
;;
(defmethod initialize-instance :after ((stream tag-input-stream) &key)
  (with-slots (buffer iter mark tag) stream
    (unless (and buffer tag)
      (error "TAGGED-INPUT-STREAM requires a :buffer and a :tag"))
    ;; Create iter; set mark at current cursor position
    (setf iter (gtb-get-iter-at-offset buffer (gtb-cursor-position buffer))
	  mark   (gtb-create-mark buffer (cffi:null-pointer) iter))
    ;; get start position for our stream
))

;;===========================================================================
(defmethod trivial-gray-streams:stream-read-char
    ((stream tag-input-stream))
  (with-slots (buffer iter tag mark) stream
    (%gtb-get-iter-at-mark buffer iter mark); current position
    (if (gti-has-tag iter tag)
	(prog1
	    (gti-get-char iter)
	  (gti-forward-char iter)
	  (gtb-move-mark buffer mark iter))
	:eof)))

;;===========================================================================
;; position can only be set to :start
(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (us tag-input-stream))
  (with-slots (buffer iter  mark tag) us
    (%gtb-get-iter-at-mark buffer iter mark) ;mark -> iter
    (case newval
      (:start
       (or (gti-starts-tag iter tag)
	   (gti-backward-to-tag-toggle iter tag)))
      (:end
       (or (gti-ends-tag iter tag)
	   (gti-forward-to-tag-toggle iter tag)))
      (t nil))))
