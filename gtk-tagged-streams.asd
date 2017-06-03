(asdf:defsystem #:gtk-tagged-streams
  :description "Text I/O using streams for GTK text buffers, including tags for styling."
  :author "StackSmith <fpgasm@apple2.x10.mx>"
  :license "BSD Simplified (2-clause)"
  :depends-on (#:cl-cffi-gtk      
	       #:bordeaux-threads
	       #:trivial-gray-streams
;;               #:trivial-utf-8
;;	       #:alexandria
	       )
  :serial t
  :components (
               (:file "package")
	       (:file "gtk-fixes/gtk.text-iter")

	       (:file "utils")

	       (:file "gtk-assets/generalized-position")
	       (:file "gtk-assets/tb-output-mixin")
	       (:file "gtk-assets/tb")
	       (:file "gtk-assets/tag")
	       (:file "gtk-assets/tag-in-stream")
	       (:file "gtk-assets/mark-out-stream")

	       (:file "demo")))
