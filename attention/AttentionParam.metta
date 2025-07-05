!(bind! &attentionParam (new-space))
!(add-atom &attentionParam  (AF_SIZE    0.2))
!(add-atom &attentionParam  (MIN_AF_SIZE 500))
!(add-atom &attentionParam  (AFB_DECAY  0.05))
!(add-atom &attentionParam  (AFB_BOTTOM 50.0))
!(add-atom &attentionParam  (MAX_AF_SIZE 1000.0))
!(add-atom &attentionParam  (AFRentFrequency 5.0))
!(add-atom &attentionParam  (FORGET_THRESHOLD 0.05))
!(add-atom &attentionParam  (HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.05))
!(add-atom &attentionParam  (LOCAL_FAR_LINK_RATIO      10.0))
!(add-atom &attentionParam  (MAX_SPREAD_PERCENTAGE 0.4))
!(add-atom &attentionParam  (DIFFUSION_TOURNAMENT_SIZE 5.0))
!(add-atom &attentionParam  (SPREAD_HEBBIAN_ONLY 0.0))
!(add-atom &attentionParam  (StartingAtomStiRent 1.0))
!(add-atom &attentionParam  (StartingAtomLtiRent 1.0))
!(add-atom &attentionParam  (TARGET_LTI_FUNDS_BUFFER  10000.0))
!(add-atom &attentionParam  (RENT_TOURNAMENT_SIZE  5.0))
!(add-atom &attentionParam  (SPREADING_FILTER  (MemberLink (Type "MemberLink"))))
(: getAttentionParam (-> Symbol Number))
(= (getAttentionParam $param)
   (match &attentionParam ($param $x) $x)
)


(: updateAttentionParam (-> Symbol Number empty))
(= (updateAttentionParam $param $newValue)
   (match &attentionParam ($param $x)
      (let ()
           (remove-atom &attentionParam ($param $x))
           (add-atom &attentionParam ($param $newValue))
      )
   )
)

(: getAllAttentionParams (-> Expression))
(= (getAllAttentionParams)
   (get-atoms &attentionParam)
)

(= (attentionParam) 
    &attentionParam
)





