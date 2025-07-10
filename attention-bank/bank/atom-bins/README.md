## DATA STRUCTURE version 2.0

### About Atom Bins

- vector data structure which contain multiple another vector that contain atoms
- since it is a vector we can acesses, insert and remove specifc atom using index
- contain the following methods
    -> insert
    -> remove
    -> size
    -> getRandomatom  ... etc

### metta representation

- according to my suggetion atombins can be represnted the following way.

- tuple of tuple or expression of expression
  - like `((1 (A)) (2 ()) (C, D, R))`

the above structure can be loaded into atomspace into two ways

### 1 using specifc space to control importance of atoms

- have collection of atombins
- add them into specif space
- add specific atom into specifc bin value
- remove specifc atom from space
- update a place of an atom by using its importance

    Example code

   ```
    !(bind! &atombin (new-space))

    !(add-atom &atombin (1 (a)))
    !(add-atom &atombin (2 (d)))
    !(add-atom &atombin (3 (c)))
    !(add-atom &atombin (17 (s c)))
    !(add-atom &atombin (18 (g j)))
    !(add-atom &atombin (37 (f h j k)))
    ```

### 2 using varibale to represent all collection then manupulate that varibable according to our interest

- have specifc variable that have nested tuple structure and assign or load a few atoms
- add atom with specific bin value
- it that bin exist just add to the atom collection else add as a new bin and atom
- the order doesnt matter
- remove atom from atom bin by pattern matching
- chnage the palce of an atom

    Example code

```
    !(bind! &atombin (new-space))
    !(add-atom &atombin (AtomBins ((1 (a)) (2 (d)) (3 (c)) (17 (s c)) (18 (g j)) (37 (f h j k)))))
```

### conclusion

- so even if both methods seems applicabel we choose to represent atom bins using the first approach

### Functions that shoud be implemented using decided approach

- insert atom - it recives bin numebr and the atom
- remove atom - it recive bin number and the atom
- size - it recive bin number return the number of atom found inside that bin
- getRandomAtom - it returns random atom from that space
- getcontent - it recives bin number and returns atom found in that bin index
- getcontentif - it recives bin number, predicate and returns the atoms based on that predicat

- importanceBin - it recives importance value(sti value) and return bin value
- updateImportance - it recives atom, old and new sti value and updates its bin location or update its position
- update - update the global variables max sti and min sti value
- getmaxsti - return the max sti value
- getminsti - return the min sti value
- getHandleSet - recive lower and uper bound of sti and return atoms in that bound
- getMaxBinContents - return atoms found in max bin index
- getMinBinContents - return atoms found in min bin index
- bin_size - return the total bin size
- size - it recives atom bin index and return the size or total number of atoms found inside that bin index

