!(bind! &recentVal (new-space))
!(add-atom &recentVal (value_min 0))
!(add-atom &recentVal (recent_min 0.0))
!(add-atom &recentVal (decay_min 0.5))

!(add-atom &recentVal (value_max 0))
!(add-atom &recentVal (recent_max 0.0))
!(add-atom &recentVal (decay_max 0.5))

(: RecentVal (-> Grounded))
(= (RecentVal) &recentVal)

(: updateRecentMinValue (-> Number empty))
(= (updateRecentMinValue $newValue)
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

(: updateRecentMaxValue (-> Number empty))
(= (updateRecentMaxValue $newValue)
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
