!(import! &self (library lib_vector))
!(import! &self (library lib_spaces))
!(import! &self (library lib_import))
!(import! &self (library lib_he))
!(import! &self ../../../baching)
!(import! &self ../../../../attention-bank/utilities/helper-functions)
!(import! &self ../../../../attention-bank/attention-value/getter-and-setter)
!(static-import! &vecEmbd ../../../../word_embeddings)

(= (VecSpace) &vecEmbd)

!(import! &self ../vectorIndicent)

!(topk happy (sad angrt excited tired) 23)

(getEmbd angrt)
!(topNeighbours happy 10)
