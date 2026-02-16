import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("output.csv")

insect_words = {
    "ant","aphid","beetle","caterpillar","larva","pupa",
    "colony","nest","soil","leaf"
}

poison_words = {
    "poison","toxin","venom","substance","chemical",
    "lethal","harmful"
}

relations = {"isa", "insynset"}

def categorize(pattern):
    p = pattern.lower()

    if p == ".":
        return "PUNCTUATION"

    if p in insect_words or any(p.startswith(w+"_") for w in insect_words):
        return "INSECT"

    if p in poison_words or any(p.startswith(w+"_") for w in poison_words):
        return "POISON"

    if p in relations:
        return "RELATION"

    if "_n_" in p or "_v_" in p or "_a_" in p or "_s_" in p:
        return "WORDNET_SYNSET"

    return "OTHER"

df["category"] = df["pattern"].apply(categorize)

cat_sum = df.groupby("category")["sti"].sum()

cat_sum.plot(kind="bar", figsize=(8,4))
plt.title("Total Attention by Category")
plt.ylabel("Total STI")
plt.show()


df["timestamp"] = pd.to_datetime(df["timestamp"])

time_cat = (
    df.groupby([pd.Grouper(key="timestamp", freq="1S"), "category"])["sti"]
    .sum()
    .unstack(fill_value=0)
)

time_cat[["INSECT","POISON"]].plot(figsize=(10,4))
plt.title("Attention Over Time: Insect vs Poison")
plt.ylabel("STI")
plt.show()
