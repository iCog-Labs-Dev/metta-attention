# Getter and Setter Implementation based on dependent types
**Brief explanation of the approach**
- **Types**
Two type definitions have been used here:
```scheme
(: createAV (-> $event ($sti $lti $vlti) ($sti $lti $vlti)))
(: createSTV (-> $event ($mean $conf) ($mean $conf)))
```
where:  the **type** of these two are the tuple expressions holding attention value parameters and truth value parameters, respectively. 
This gives us the ability to treat attention and truth value as assignable properties so we can assign them onto desired structures(eg. links, nodes, tuples, subspaces ...). This is done via type assignment here. 
- **Usage**
Let us walk through a simple example of assigning attention value to an atom `a`. Then we see how we can use pattern matching to get the `sti` and `lti` of the atom.
```scheme
(: A (createAV a (1.0 2.0 1.0))

(: getSTI (-> $instance Number))
(= (getSTI (createAV $x ($sti $lti $vlti))) $sti)

(: getLTI (-> $instance Number))
(= (getLTI (createAV $x ($sti $lti $vlti))) $lti)

!(getSTI (get-type A)) ;1.0
!(getLTI (get-type A)) ;2.0
```
Truth value can be assigned to `a` in the same way. However, the definitions of `getSTI` and `getLTI` need to be refactored to accommodate the additional **type** being assigned to the atom. The getters for stv can be implemented using the same principle using `collapse`.
```scheme
(: A (createAV a (1.0 2.0 1.0))
(: A (createSTV a (0.5 0.5))

(: getSTI (-> $instance Number))
(= (getSTI ((createAV $x ($sti $lti $vlti) $_) $sti)
(= (getSTI ($_ (createAV $x ($sti $lti $vlti)) $sti)

(: getLTI (-> $instance Number))
(= (getLTI ((createAV $x ($sti $lti $vlti) $_) $lti)
(= (getLTI ($_ (createAV $x ($sti $lti $vlti)) $lti)

!(getSTI (collapse (get-type A))) ;1.0
!(getLTI (collapse (get-type A))) ;2.0
```
since both createAV and createSTV are implemented in generic way, we can take this to our advantage to extend the representation to any type of data structure and it would work fine. 
- All the setters and getters for both attention values and truth values can be found in `attention-bank/attention-value/getter-and-setter.metta`. 
**NOTE** Review the code there before moving forward to the next part.

----
**Directory structure**
- **separation of space**
A quick look inside `attention-bank/attention-value/tests/` shows a file by the name `test-kb.metta`. This, as the name implies, is a file that can be used to store instances of data that can be imported and used by test cases. 
**NOTE**: Doing so ensures separation of data related to ECAN. Using `&self` might cause confusion between some patterns while pattern matching. Here we will be definitely confident about the patterns we match by because they will be set according to patterns suitable to ECAN.
```scheme
;inside test-kb.metta
(: A (createSTV a (0.1 0.2)))
(: A (createAV a (10.0 10.0 0.1)))

(: B (createAV b (100.0 1.0 0.2)))
(: B (createSTV b (0.5 0.5)))
```

```scheme
;inside getter-and-setter-test.metta
!(register-module! ../../../../metta-attention)
!(import! &test-kb metta-attention:attention-bank:attention-value:tests:test-kb)
!(import! &self metta-attention:attention-bank:utilities:helper-functions) ;used to import getType.

!(assertEqual (getSTI (getType &test-kb A)) 10.0)
!(assertEqual (getLTI (getType &test-kb A)) 10.0)
!(assertEqual (getMean (getType &test-kb B)) 0.5)
!(assertEqual (getConf (getType &test-kb B)) 0.5)
```
----
**Demonstration**
- **Bringing Everything Together**
To bring the concepts together, an example of links and nodes has been used.
```scheme
;test-kb.metta
;For the sake of simplicity, A and B represent Nodes A and B.
;A link(link_ab) is used to represent an evaluation link between the two.

(: A (createSTV a (0.1 0.2)))
(: A (createAV a (10.0 10.0 0.1)))

(: B (createAV b (100.0 1.0 0.2)))
(: B (createSTV b (0.5 0.5)))

(: createLink (-> $source $target $type ($source $target)))
(: link_ab (createAV (createLink A B EvaluationLink) (10.0 10.0 1.0)))
```
```scheme
;getter-and-setter-test.metta
!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &test-kb metta-attention:attention-bank:attention-value:tests:test-kb)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)

!(assertEqual (getAV (getType &test-kb link_ab)) (10.0 10.0 1.0))
!(setAV &test-kb link_ab (10.0 0.0 0.0))
!(assertEqual (getAV (getType &test-kb link_ab)) (10.0 0.0 0.0))
```
----
