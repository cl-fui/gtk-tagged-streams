(in-package :gtk-tagged-streams)

;;==============================================================================
;; mark-out-stream
;;
;; A general-purpose output stream, using a mark to keep position.
;;
(defclass mark-out-stream (trivial-gray-streams:fundamental-character-output-stream)
  ((buffer  :accessor buffer :initarg :buffer :initform nil)
   (mark     :accessor mark   :initform nil)
   (iter0    :accessor iter0   :initform nil)
   (charbuf :accessor charbuf :initform "a"); internally, output needs strings
   ))
;;=============================================================================
;;
(defmethod initialize-instance :after ((stream mark-out-stream) &key position)
  (with-slots (buffer tag iter0 iter1 mark) stream
    (unless buffer
      (error "mark-out-stream requires :buffer initializer"))
    (setf iter0 (new-iter-at-position buffer position)
	  mark  (gtb-create-mark buffer (cffi:null-pointer) iter0))))
;;=============================================================================
;;
(defmethod close ((stream mark-out-stream) &key abort)
  (declare (ignore abort))
  (with-slots (buffer iter mark mstart mend tag) stream
    (gtb-delete-mark buffer mark)
    t))
;;==============================================================================
;;
(defmethod trivial-gray-streams:stream-write-char
    ((stream mark-out-stream) char)
  (with-slots (buffer charbuf iter0 mark) stream
    (setf (char charbuf 0) char)
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (%gtb-insert buffer iter0 charbuf -1)))

;;==============================================================================
;; write-string is more efficient than character-by-character, but
;; could be done better if needed.
(defmethod trivial-gray-streams:stream-write-string
    ((stream mark-out-stream)
     string
     &optional start end)
  (let ((s (if (or start end)
	       (subseq string start end )
	       string)))
    (with-slots (buffer iter0 mark) stream
      (%gtb-get-iter-at-mark buffer iter0 mark)
      (%gtb-insert buffer iter0 s -1))))
;;==============================================================================
(defmethod trivial-gray-streams:stream-start-line-p
    ((stream mark-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-starts-line iter0)) )
;;==============================================================================
(defmethod trivial-gray-streams:stream-line-column
    ((stream mark-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-get-line-offset iter0)))
;;==============================================================================
(defmethod trivial-gray-streams:stream-file-position
    ((stream mark-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-get-offset iter0)))
;;==============================================================================
(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (stream mark-out-stream))
  (with-slots (buffer iter0 mark ) stream
    (%gtb-get-iter-at-offset buffer iter0 (case newval
					    (:start 0)
					    (:end -1)
					    (t newval)))
    (gtb-place-cursor buffer iter0))
  t)
