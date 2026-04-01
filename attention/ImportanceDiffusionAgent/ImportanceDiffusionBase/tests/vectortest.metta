!(import! &self (library lib_vector))
!(import! &self (library lib_spaces))
!(import! &self (library lib_import))
!(import! &self (library lib_he))
!(import! &self ../../../baching)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(import! &self ../vectorIndicent)
!(import! &self ../ImportanceDiffusionBase)
!(static-import! &vecEmbd ../../../../experiments/data/larger_vec)

(= (VecSpace) &vecEmbd)

!(getVectorIncident tropical 100)
