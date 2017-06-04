(in-package :gtk-tagged-streams)
;;=============================================================================
;; buffer-stream  ABSTRACT - DO NOT INSTANTIATE!
;;
;; Common to all input and output streams here...
;

(defclass buffer-stream ()
  ((buffer   :accessor buffer :initarg :buffer)
   (iter     :accessor iter   :initform nil)
   (mark     :accessor mark   :initform nil)))

;;=============================================================================
;; All of these must get rid of mark.
(defmethod close ((stream buffer-stream) &key abort)
  (declare (ignore abort))
  (with-slots (buffer mark) stream
    (gtb-delete-mark buffer mark)
    t))
;;=============================================================================
;;
(defmethod initialize-instance :after ((stream buffer-stream)
				       &key position)
  (with-slots (buffer iter mark tag) stream
    (unless buffer
      (error "~A requires a :buffer and a :tag" (type-of stream)))
    ;; Create iter; set mark at current cursor position
    (setf iter (new-iter-at-position buffer position)
	  mark (gtb-create-mark buffer (cffi:null-pointer) iter))))

;;==============================================================================
(defmethod trivial-gray-streams:stream-file-position ((stream buffer-stream))
  (with-slots (buffer iter mark) stream
    (%gtb-get-iter-at-mark buffer iter mark)
    (gti-offset iter)))

;;==============================================================================
(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (stream buffer-stream))
  (with-slots (buffer iter mark ) stream
    (%gtb-get-iter-at-offset buffer iter (case newval
					   (:start 0)
					   (:end -1)
					   (t newval)))
    (%gtb-move-mark buffer mark iter))
  t)



;;==============================================================================
(defclass buffer-tag-stream (buffer-stream)
  ((tag      :accessor tag    :initarg :tag)))

;;==============================================================================
(defmethod initialize-instance :after ((stream buffer-tag-stream)
				       &key )
  (unless (tag stream)
    (error "~A requires a :tag parameter" (type-of stream))))

