from nltk.corpus import wordnet as wn

# Make sure WordNet is downloaded
import nltk
nltk.download('wordnet')

out = open("../data/wordnet.metta", "w")

def clean(x):
    return x.replace(" ", "_")

# Track relationship counts for reporting
counts = {
    'synsets': 0,
    'in_synset': 0,
    'is_a': 0,
    'similarity': 0,
    'causes': 0,
    'entails': 0,
    'part_of': 0,
    'has_part': 0,
    'member_of': 0,
    'has_member': 0,
    'substance_of': 0,
    'has_substance': 0,
    'antonym': 0
}

for syn in wn.all_synsets():
    syn_name = clean(syn.name())
    counts['synsets'] += 1

    # Words in synset
    for lemma in syn.lemmas():
        word = clean(lemma.name())
        out.write(f"(InSynset {word} {syn_name})\n")
        counts['in_synset'] += 1
        
        # Antonyms (at lemma level)
        for antonym in lemma.antonyms():
            antonym_word = clean(antonym.name())
            out.write(f"(AntonymLink {word} {antonym_word})\n")
            counts['antonym'] += 1

    # Hierarchical relationships (IsA)
    for hyper in syn.hypernyms():
        hyper_name = clean(hyper.name())
        out.write(f"(IsA {syn_name} {hyper_name})\n")
        counts['is_a'] += 1
    
    # Similarity relationships
    for similar in syn.similar_tos():
        similar_name = clean(similar.name())
        out.write(f"(SimilarityLink {syn_name} {similar_name})\n")
        counts['similarity'] += 1
    
    # Also see (related concepts)
    for also in syn.also_sees():
        also_name = clean(also.name())
        out.write(f"(SimilarityLink {syn_name} {also_name})\n")
        counts['similarity'] += 1
    
    # Causal relationships
    for caused in syn.causes():
        caused_name = clean(caused.name())
        out.write(f"(CausesLink {syn_name} {caused_name})\n")
        counts['causes'] += 1
    
    # Entailment relationships
    for entailed in syn.entailments():
        entailed_name = clean(entailed.name())
        out.write(f"(EntailsLink {syn_name} {entailed_name})\n")
        counts['entails'] += 1
    
    # Part-whole relationships (Meronyms - has parts)
    for part in syn.part_meronyms():
        part_name = clean(part.name())
        out.write(f"(HasPartLink {syn_name} {part_name})\n")
        counts['has_part'] += 1
    
    # Part-whole relationships (Holonyms - is part of)
    for whole in syn.part_holonyms():
        whole_name = clean(whole.name())
        out.write(f"(PartOfLink {syn_name} {whole_name})\n")
        counts['part_of'] += 1
    
    # Member relationships (has members)
    for member in syn.member_meronyms():
        member_name = clean(member.name())
        out.write(f"(HasMemberLink {syn_name} {member_name})\n")
        counts['has_member'] += 1
    
    # Member relationships (is member of)
    for group in syn.member_holonyms():
        group_name = clean(group.name())
        out.write(f"(MemberLink {syn_name} {group_name})\n")
        counts['member_of'] += 1
    
    # Substance relationships (has substance)
    for substance in syn.substance_meronyms():
        substance_name = clean(substance.name())
        out.write(f"(HasSubstanceLink {syn_name} {substance_name})\n")
        counts['has_substance'] += 1
    
    # Substance relationships (is substance of)
    for whole in syn.substance_holonyms():
        whole_name = clean(whole.name())
        out.write(f"(SubstanceOfLink {syn_name} {whole_name})\n")
        counts['substance_of'] += 1

out.close()

# Print statistics
print("../data/wordnet.metta generated successfully!")
print("\nRelationship Statistics:")
print(f"  Synsets: {counts['synsets']:,}")
print(f"  InSynset (word → synset): {counts['in_synset']:,}")
print(f"  IsA (hypernym): {counts['is_a']:,}")
print(f"  SimilarityLink: {counts['similarity']:,}")
print(f"  CausesLink: {counts['causes']:,}")
print(f"  EntailsLink: {counts['entails']:,}")
print(f"  PartOfLink: {counts['part_of']:,}")
print(f"  HasPartLink: {counts['has_part']:,}")
print(f"  MemberLink: {counts['member_of']:,}")
print(f"  HasMemberLink: {counts['has_member']:,}")
print(f"  SubstanceOfLink: {counts['substance_of']:,}")
print(f"  HasSubstanceLink: {counts['has_substance']:,}")
print(f"  AntonymLink: {counts['antonym']:,}")
total_relations = sum(counts.values()) - counts['synsets']
print(f"\nTotal relationships: {total_relations:,}")
