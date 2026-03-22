(exec 0
    (, ($link $source $target) )
    (O (+ ($source ($link $source $target)))
       (+ ($target ($link $source $target)))
       (+ (theoutput $source))
       (+ (theoutput $target))
       (- ($link $source $target))
    )
)
