interface ImportanceRatable a where
  getSTI : a -> Float
  getLTI : a -> Float

interface TruthValueRatable a where
  getTV : a -> Float
  getConf : a -> Float

record Event where 
  constructor MkEvent
  eventTitle : String
  importance : (Float, Float)
  stv : (Float, Float)

instance ImportanceRatable Event where
  getSTI (MkEvent _ (sti, _) _) = sti
  getLTI (MkEvent _ (_, lti) _) = lti

instance TruthValueRatable Event where
  getTV (MkEvent _ _ (tv, _)) = tv
  getConf (MkEvent _ _ (_, conf)) = conf
