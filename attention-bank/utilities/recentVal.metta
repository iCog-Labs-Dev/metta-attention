!(bind! &recentVal (new-space))
;This space holds changing values: value, recent and decay.
;These first two values are used to represent STI values. Whereas, decay, is the 
;rate at which these values decay at. 
;
;When the respective update functions are called, the recent value will be Updated
;according to this mathematical relationship between the three:
    ;recent = ((decay * newValue) + ((decay - 1.0) * recent))
    ;where: newValue is the value passed as the argument to the update functions.

!(add-atom &recentVal (value_min 0))
!(add-atom &recentVal (recent_min 0.0))
!(add-atom &recentVal (decay_min 1))

!(add-atom &recentVal (value_max 0))
!(add-atom &recentVal (recent_max 0.0))
!(add-atom &recentVal (decay_max 1))

(: RecentVal (-> Grounded))
(= (RecentVal) &recentVal)

(: updateMin (-> Number empty))
(= (updateMin $newValue)
   (let*
     (
        ($recent (match &recentVal (recent_min $_) $_))
        ($decay (match &recentVal (decay_min $_) $_))
        ($value (match &recentVal (value_min $_) $_))
        ($newRecent (+ (* $decay $newValue) (* $recent (- 1.0 $decay)))) 
        ($_ (let () (remove-atom &recentVal (recent_min $recent)) (add-atom &recentVal (recent_min $newRecent))))
        ($_ (let () (remove-atom &recentVal (value_min $value)) (add-atom &recentVal (value_min $newValue))))
      )
      ()
    )
)

(: updateMax (-> Number empty))
(= (updateMax $newValue)
   (let*
     (
        ($recent (match &recentVal (recent_max $_) $_))
        ($decay (match &recentVal (decay_max $_) $_))
        ($value (match &recentVal (value_max $_) $_))
        ($newRecent (+ (* $decay $newValue) (* $recent (- 1.0 $decay)))) 
        ($_ (let () (remove-atom &recentVal (recent_max $recent)) (add-atom &recentVal (recent_max $newRecent))))
        ($_ (let () (remove-atom &recentVal (value_max $value)) (add-atom &recentVal (value_max $newValue))))
      )
      ()
    )
)