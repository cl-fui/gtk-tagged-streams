# GTK-TAGGED-STREAMS

GTK-TAGGED-STREAMS is a minimalistic library that beefs up gtk-text-buffer with an output stream.  Tagged runs of text can now be printed using a simple (with-tag ..) macro and your favorite Lisp printing function.

It further lets you open tagged texts as streams, for reasonably easy input.

You may be interested in this library if 
* you need something better looking than a terminal;
* you need control of type and color in your output;

This library uses (and is an extension of) the [ubiquitous cl-cffi-gtk](https://github.com/crategus/cl-cffi-gtk).

## Demo and Screenshot

...

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

## Generalized Positions

When opening streams, the initial position can be expressed in a variety of ways.  For convenience, all streams on text-buffer are opened with a `:position` argument that may be one of:

- an integer offset (0 is start, -1 is end);
- an iterator;
- a mark;
- a string naming a mark;
- nil for the caret position. 

## MARK-OUT-STREAM

The built-in caret stream of a text-buffer always outputs at the current caret position, adjusting it after output.  For truly random-position output, use MARK-OUT-STREAM.  It maintains its own mark for tracking output position.  Any number of these may be opened of a text-buffer; don't forget to close!

`(make-instance 'mark-out-stream :buffer buffer :position genpos)`

## TAG-IN-STREAM

This stream allows you to treat a tagged run of text as an input stream. 

`(make-instance 'tag-in-stream :buffer buffer :tag tag :position genpos)`

If the tag is not active at the position indicated by the :position parameter, an :eof condition will exist at the next read. 

Once open, you may use :start or :end file-position to wind to the beginning or end of the run.

## STATUS

Early working code.

Other stream classes will probably be added as needed.  Please open an issue if you have a good idea for one.


 
