;;;; package.lisp

(defpackage #:gtk-tagged-streams
;;  (:nicknames #:gtk-tagged-streams)
  (:use :gtk :gdk :gdk-pixbuf :gobject :glib :gio :pango :cairo :cffi
	#:cl
))

