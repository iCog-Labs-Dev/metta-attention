from nltk.corpus import wordnet as wn

# Make sure WordNet is downloaded
import nltk
nltk.download('wordnet')

out = open("../data/wordnet.metta", "w")

def clean(x):
    return x.replace(" ", "_")

for syn in wn.all_synsets():
    syn_name = clean(syn.name())

    # Synset node
    out.write(f"(Synset {syn_name})\n")

    # Words in synset
    for lemma in syn.lemmas():
        word = clean(lemma.name())
        out.write(f"(InSynset {word} {syn_name})\n")

    # Hypernyms (IsA)
    for hyper in syn.hypernyms():
        hyper_name = clean(hyper.name())
        out.write(f"(IsA {syn_name} {hyper_name})\n")

out.close()
print("wordnet.metta generated")