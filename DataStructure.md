## Proposed Data Structure for Atom Representation in Attention Allocation System

Current Scheme Representation

Here’s how the pattern is currently represented in a Scheme file:
```
(InheritanceLink (stv 1.0 1.0)
    Socrates
    man
)
```

Based on this representation, the data structure could be designed as follows:

### Example 1: Basic Structure

```meTTa
(InheritanceLink (stv 0.1 0.9)
    socrates ((stv 0.1 0.9) (av 0 0 0))
    man ((stv 0.1 0.9) (av 0 0 0) ) 
)
```


### Example 2: Simplified Node

```(socrates (stv 0.1 0.9) (av 0 0 0))```


### Example 3: Extended Representation

```(human socrates ((stv 0.1 0.9) (av 0 0 0)))```

### Question: Should `human` have `stv`, `av`, both, or none?

Assumption: Each expression will always have 2, 3, or 4 symbols:

A link or no link
1 or 2 outgoing sets

A numerical value expression (e.g., stv or av) attached to the link
For nested patterns or trees, the complexity increases. For example:

```
(InheritanceLink (stv 0.1 0.9)
    (human socrates ((stv 0.1 0.9) (av 0 0 0)))
    man ((stv 0.1 0.9) (av 0 0 0))   
)
```

This approach can make it difficult to retrieve and update the av or stv values due to data immutability in meTTa.

### Cleaner Alternative Proposal

### <i>Idea: Use Random Identifiers (rand)</i>

Assign a unique random identifier to each node or link. For example:

```(InheritanceLink socrates human (rand1 rand2 rand3))```

Store the corresponding values (stv and av) in a separate &AV and TV space:

```
(rand1 ((stv 0.1 0.9) (av 0 0 0)))
(rand2 ((stv 0.1 0.9) (av 0 0 0)))
(rand3 ((stv 0.1 0.9) (av 0 0 0)))
```

Example with Nested Patterns

``` 
(InheritanceLink 
    (human socrates)
    man
    (rand1 (rand2) rand3)
)
```

In &AV and TV space:

```
(rand1 ((stv 0.1 0.9) (av 0 0 0)))
(rand2 ((stv 0.1 0.9) (av 0 0 0)))
(rand3 ((stv 0.1 0.9) (av 0 0 0)))
```
For the first one -------------------- For the second one

Ugly pattern------------------- Clean pattern

No additional computetion to retrieve values------------needs to retrieve the random numbers from the pattern and then match to the AV and TV space

Need to reconstruct the etire pattern after updating the values tv or av --------------------- no need for that


### Lets now see how Nil used the STV in the PLN

```
(: TruthValue Type)

(: STV (-> Number Number TruthValue))

(: ≞ (-> $event $tv Type))

```


;; Knowledge base
```
(: kb (-> Atom))


(= (kb) (superpose ((: Pm (≞ P (STV 0.2 0.3)))
                    (: Qm (≞ Q (STV 0.3 0.2)))
                    (: Rm (≞ R (STV 0.4 0.1)))
                    (: P2 (⊷ P (fromNumber 2) True))
                    (: Q2 (⊷ Q (fromNumber 2) False))
                    (: P7 (⊷ P (fromNumber 7) True))
                    (: Q7 (⊷ Q (fromNumber 7) True))
                    (: QRm (≞ (→ Q R) (STV 0.9 0.7))))))

!(get-type Pm)  ;gives (≞ P (STV 0.2 0.3))
```

The Truthvalue is being attached as a type to the Pm

So the same can be done for the AV


```metta
(:AttentionValue Type)

(: AV (-> Number Number Number AttentionValue))

(= (Test $pattern $sti $lti $vlti)
    (: $pattern ( (STV 0.2 0.3) (AV $sti $lti $vlti)) )
)
```
```
! (add-reduct &self (Test (Inheritance A B) 100 200 0))
! (add-reduct &self (Test (Inheritance A C) 200 400 0))
! (add-reduct &self (Test (Inheritance A D) 200 400 1)) 
! (add-reduct &self (Test (A) 250 400 1))
```
```
! (get-type (Inheritance A B))
! (get-type (Inheritance A C))
! (get-type (Inheritance A D))
! (get-type (A))
```

### Final decision

The data structure to represent atoms in attention allocation system will be like the following

```
(:AttentionValue Type)

(: AV (-> Number Number Number AttentionValue))

(: TruthValue Type)

(: STV (-> Number Number TruthValue))

```