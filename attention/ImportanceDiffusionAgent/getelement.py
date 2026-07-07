def getTopK(l, k):
     if k <= 0:
        return []
     return sorted(l, reverse=True)[:k]

def getK(l, k):
     if k <= 0:
        return []
     return l[:k]

def get_fair_goals(pairs, source_atom, k=5):
    sorted_pairs = sorted(pairs, key=lambda x: x[1], reverse=True)
    goals = tuple(p[0] for p in sorted_pairs if p[0] != source_atom)[:k]
    if not goals:
      return ("NONE",)
    return goals