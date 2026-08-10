# Profile Results

Only application-level functions are shown (Prolog built-ins and MeTTa runtime internals excluded).


## 1. Rent Collection 

| Function                  | Calls     | Self Time     | Children Time | Total Time    |
|---------------------------|-----------|---------------|---------------|---------------|
| `setAv`                   | 10,016    | 0.04s ( 0.5%) | 6.80s (76.2%) | 6.84s (76.7%) |
| `updateAf`                | 10,014    | 0.06s ( 0.7%) | 2.34s (26.2%) | 2.40s (26.9%) |
| `attentionValueChanged`   | 7,010     | 0.02s ( 0.2%) | 1.68s (18.8%) | 1.70s (19.0%) |
| `applyRent`               | 4,000     | 0.02s ( 0.2%) | 3.50s (39.2%) | 3.52s (39.4%) |
| `getValueType`            | 51,066    | 0.05s ( 0.5%) | 1.18s (13.2%) | 1.23s (13.7%) |
| `getAv`                   | 37,055    | 0.02s ( 0.2%) | 0.85s ( 9.5%) | 0.87s ( 9.7%) |
| `println!`                | 7,010     | 0.01s ( 0.1%) | 1.45s (16.3%) | 1.46s (16.4%) |
| `importanceBin`           | 9,010     | 0.02s ( 0.2%) | 0.14s ( 1.6%) | 0.16s ( 1.8%) |
| `collectRent`             | 1,502     | 0.01s ( 0.1%) | 1.37s (15.4%) | 1.38s (15.5%) |
| `getLti`                  | 14,022    | 0.02s ( 0.2%) | 0.30s ( 3.3%) | 0.32s ( 3.5%) |
| `updateMinAf`             | 7,010     | 0.04s ( 0.5%) | 0.20s ( 2.2%) | 0.24s ( 2.7%) |
| `calculateLtiRent`        | 14,000    | 0.05s ( 0.5%) | 0.25s ( 2.8%) | 0.30s ( 3.3%) |
| `calculateStiRent`        | 14,000    | 0.02s ( 0.2%) | 0.15s ( 1.7%) | 0.17s ( 1.9%) |
| `findGroup`               | 4,002     | 0.01s ( 0.1%) | 0.03s ( 0.4%) | 0.04s ( 0.4%) |
| `isAtomInAf`              | 10,013    | 0.01s ( 0.2%) | 0.02s ( 0.2%) | 0.03s ( 0.4%) |



## 2. Importance Diffusion 

| Function                          | Calls     | Self Time     | Children Time | Total Time    |
|-----------------------------------|-----------|---------------|---------------|---------------|
| `incidentAtoms`                   | 3,900     | 0.01s ( 0.2%) | 3.42s (69.0%) | 3.43s (69.2%) |
| `diffuseAtom`                     | 1,601     | 0.01s ( 0.3%) | 0.57s (11.4%) | 0.58s (11.7%) |
| `getValueType`                    | 38,545    | 0.01s ( 0.3%) | 0.53s (10.6%) | 0.54s (10.9%) |
| `getStv`                          | 29,602    | 0.02s ( 0.4%) | 0.46s ( 9.2%) | 0.48s ( 9.6%) |
| `probabilityVectorHebbianAjacent` | 4,800     | 0.01s ( 0.2%) | 0.14s ( 2.8%) | 0.15s ( 3.0%) |
| `concatTuple`                     | 1,300     | 0.01s ( 0.2%) | 0.00s ( 0.0%) | 0.01s ( 0.2%) |
| `hebbianDiffusionUsed`            | 1 (entry) | 0.02s ( 0.4%) | 0.05s ( 1.0%) | 0.07s ( 1.4%) |
| `calcElapsedTime`                 | 1,401     | 0.01s ( 0.2%) | 0.02s ( 0.4%) | 0.03s ( 0.6%) |
| `profileIncidentAtoms`            | 2,001     | 0.02s ( 0.3%) | 1.98s (39.8%) | 2.00s (40.1%) |
| `profileProbabilityVectorHebbian` | 1         | 0.01s ( 0.2%) | 0.05s ( 1.1%) | 0.06s ( 1.3%) |
| `profileProbabilityVectorIncident`| 1,001     | 0.01s ( 0.2%) | 0.71s (14.4%) | 0.72s (14.6%) |
| `profileHebbianDiffusionUsed`     | 1         | 0.02s ( 0.4%) | 0.05s ( 1.0%) | 0.07s ( 1.4%) |
| `profileFilteroset`               | 1         | 0.02s ( 0.3%) | 0.03s ( 0.6%) | 0.05s ( 0.9%) |



## 3. Hebbain Updating 

| Function                      | Calls     | Self Time     | Children Time | Total Time    |
|-------------------------------|-----------|---------------|---------------|---------------|
| `targetConjunction`           | 4,547     | 0.03s ( 1.1%) | 0.94s (31.6%) | 0.97s (32.7%) |
| `getSti`                      | 9,099     | 0.04s ( 1.2%) | 0.57s (19.4%) | 0.61s (20.6%) |
| `getValueType`                | 11,301    | 0.02s ( 0.7%) | 0.63s (21.3%) | 0.65s (22.0%) |
| `getAv`                       | 9,651     | 0.02s ( 0.8%) | 0.57s (19.2%) | 0.59s (20.0%) |
| `getNormalisedZeroToOneSTI`   | 9,094     | 0.05s ( 1.8%) | 0.23s ( 7.8%) | 0.28s ( 9.6%) |
| `getAttentionParam`           | 18,759    | 0.03s ( 1.1%) | 0.12s ( 4.1%) | 0.15s ( 5.2%) |
| `higherConfidenceMerge`       | 10,000    | 0.02s ( 0.6%) | 0.04s ( 1.4%) | 0.06s ( 2.0%) |
| `mergeCalculation`            | 4,547     | 0.01s ( 0.2%) | 0.19s ( 6.3%) | 0.20s ( 6.5%) |
| `updateHebbianLinks`          | 606       | 0.00s ( 0.1%) | 1.18s (39.8%) | 1.18s (39.9%) |
| `bachUpdateHeb`               | 547       | 0.00s ( 0.1%) | 0.24s ( 8.2%) | 0.24s ( 8.3%) |
| `profileMergeCalculation`     | 1         | 0.03s ( 1.1%) | 0.18s ( 6.0%) | 0.21s ( 7.1%) |
| `profileTargetConjunction`    | 1         | 0.01s ( 0.4%) | 0.86s (29.2%) | 0.87s (29.6%) |
| `getMinSTI`                   | 9,094     | 0.01s ( 0.5%) | 0.09s ( 3.1%) | 0.10s ( 3.6%) |



## 4. Hebbain Creation 

| Function                      | Calls     | Self Time     | Children Time | Total Time    |
|-------------------------------|-----------|---------------|---------------|---------------|
| `addHebbian` (hyp/batch spec) | 10,006    | 0.02s ( 0.6%) | 2.32s (82.8%) | 2.34s (83.4%) |
| `bach-p` (addHebbian spec)    | 1,997     | 0.01s ( 0.3%) | 2.45s (87.5%) | 2.46s (87.8%) |
| `batch` (addHebbian spec)     | 2,006     | 0.00s ( 0.2%) | 2.36s (84.4%) | 2.36s (84.6%) |
| `localToFarLinks`             | 1,000     | 0.00s ( 0.1%) | 0.00s ( 0.0%) | 0.00s ( 0.1%) |
| `first-k`                     | 2,000     | 0.01s ( 0.3%) | 0.01s ( 0.5%) | 0.02s ( 0.8%) |


## 5. Forget Agent 

| Function                    | Calls     | Self Time     | Children Time | Total Time    |
|-----------------------------|-----------|---------------|---------------|---------------|
| `getValueType`              | 99,545    | 0.03s ( 1.1%) | 1.39s (50.3%) | 1.42s (51.4%) |
| `getAv`                     | 97,528    | 0.02s ( 0.8%) | 1.39s (50.4%) | 1.41s (51.2%) |
| `getLti`                    | 91,014    | 0.04s ( 1.6%) | 1.25s (45.5%) | 1.29s (47.1%) |
| `greaterThanLtiThenTV`      | 10,000    | 0.02s ( 0.6%) | 0.62s (22.5%) | 0.64s (23.1%) |
| `updateAf`                  | 2,015     | 0.01s ( 0.4%) | 0.36s (13.2%) | 0.37s (13.6%) |
| `lessThanLtiThenTV`         | 10,000    | 0.00s ( 0.1%) | 0.48s (17.3%) | 0.48s (17.4%) |
| `profileLessThanLtiThenTV`  | 1         | 0.00s ( 0.1%) | 0.50s (18.0%) | 0.50s (18.1%) |
| `updateMinAf`               | 1,012     | 0.01s ( 0.3%) | 0.01s ( 0.3%) | 0.02s ( 0.6%) |
| `importanceBin`             | 1,012     | 0.01s ( 0.3%) | 0.03s ( 0.9%) | 0.04s ( 1.2%) |
| `atomBelowForgetThreshold`  | 10,000    | 0.00s ( 0.1%) | 0.36s (13.2%) | 0.36s (13.3%) |
