(in-package :gtk-tagged-streams)

;;==============================================================================
;; cursor-output-stream
;;
;; Not a mixin, a standalone class.
;;
;; Using the cursor as output position, print user-originated text (such as
;; keystrokes) into the buffer,
;;
;; Watch out for cursor race conditions...
;;
(defclass cursor-out-stream (trivial-gray-streams:fundamental-character-output-stream)
  ((buffer  :accessor buffer :initarg :buffer :initform nil)
   (mark     :accessor mark   :initform nil)
   (iter0    :accessor iter0   :initform nil)
   (charbuf :accessor charbuf :initform "a"); internally, output needs strings
   ))
;;=============================================================================
;;
(defmethod initialize-instance :after ((stream cursor-out-stream) &key)
  (with-slots (buffer tag iter0 iter1 mark) stream
    (unless (and buffer tag)
      (error "cursor-out-stream requires :buffer initializer"))
    (setf iter0 (gtb-get-start-iter buffer)
	  mark  (gtb-get-insert buffer))))
;;=============================================================================
;;
(defmethod close ((stream context-input-stream) &key abort)
  (declare (ignore abort))
  (with-slots (buffer iter mark mstart mend tag) stream
    (gtb-delete-mark buffer mark)
    t))
;;==============================================================================
;;
(defmethod trivial-gray-streams:stream-write-char
    ((stream cursor-out-stream) char)
  (with-slots (buffer charbuf) stream
    (setf (char charbuf 0) char)
    (gtb-insert-at-cursor stream charbuf -1)))

;;==============================================================================
;; write-string is more efficient than character-by-character, but
;; could be done better if needed.
(defmethod trivial-gray-streams:stream-write-string
    ((stream cursor-out-stream)
     string
     &optional start end)
  (let ((s (if (or start end)
	       (subseq string start end )
	       string)))
    (gtb-insert-at-cursor (buffer stream) s -1)))
;;==============================================================================
(defmethod trivial-gray-streams:stream-start-line-p
    ((stream cursor-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-starts-line iter0)) )
;;==============================================================================
(defmethod trivial-gray-streams:stream-line-column
    ((stream cursor-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-get-line-offset iter0)))
;;==============================================================================
(defmethod trivial-gray-streams:stream-file-position
    ((stream cursor-out-stream))
  (with-slots (buffer iter0 mark) stream
    (%gtb-get-iter-at-mark buffer iter0 mark)
    (gti-get-offset iter0)))
;;==============================================================================
(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (stream cursor-out-stream))
  (with-slots (buffer iter0 mark ) stream
    (%gtb-get-iter-at-offset buffer iter0 (case newval
					    (:start 0)
					    (:end -1)
					    (t newval)))
    (gtb-place-cursor buffer iter0))
  t)
