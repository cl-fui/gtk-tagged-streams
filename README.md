# GTK-TAGGED-STREAMS

GTK-TAGGED-STREAMS is a minimalistic library that beefs up gtk-text-buffer with an output stream.  Tagged runs of text can now be printed using a simple (with-tag ..) macro and your favorite Lisp printing function.

It further lets you open tagged texts as streams, for reasonably easy input.

You may be interested in this library if 
* you need something better looking than a terminal;
* you need control of type and color in your output;

This library uses (and is an extension of) the [ubiquitous cl-cffi-gtk](https://github.com/crategus/cl-cffi-gtk).

## Demo and Screenshot

```
(ql:quickload :gtk-tagged-streams)(in-package :gts)
(demo)
```

![screenshot](./Screenshot.png?raw=true) 


Mouse-clicks will create an input stream on the run of text underneath the click, and output it to your *standard-output*.

While the demo is open, you can output to the screen using something like `(format *buffer* "hello")` from the REPL.  Or if you want to be fancy, try `(with-tag *buffer* *tHead* (format *buffer* "~&Elephant~&"))`


## Quickstart

To use GTK-TAGGED-STREAMS, clone it into your Lisp directory, or use Quicklisp (soon).

Use gts:text-buffer instead of gtk-text-buffer.  The buffer is also a caret output stream; any output will be inserted at the caret.

For tagged output, wrap your outputting code like this:
```
(with-tag *buffer* tag (format *buffer* "hello"))

(without-tag *buffer* tag ...)
```

The latter removes the specified tag from output (a very useful feature!)

The tag can be any tag valid for this buffer.  You may nest these as needed.

Other streams may be opened on the buffer.  They are described below.



## TAG-INPUT-STREAM

This stream allows you to treat a tagged run of text as an input stream. 

`(make-instance 'tag-input-stream :buffer buffer :tag tag :position pos)`

Parameter | Notes 
--- | --- 
`:tag` | a gtk-text-tag valid for this buffer.  If the tag is not active at the position indicated by the :position parameter, an :eof condition will exist at the next read. 
`:buffer` | a gts:text-buffer; 
`:position` | one of:
| | - an integer offset (0 is start, -1 is end);
| | - an iterator;
| | - a mark;
| | - a string naming a mark;
| | - nil for the caret position. 

Once open, you may use :start or :end file-position to wind to the beginning or end of the run.

Other stream classes will probably be added as needed.  Please open an issue if you have a good idea for one.


 
