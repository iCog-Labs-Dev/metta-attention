:- module(pln_state_snapshot, ['Baseline.Canonical'/2]).

'Baseline.Canonical'(Value, Canonical) :-
    copy_term(Value, Copy),
    numbervars(Copy, 0, _),
    canonical_variables(Copy, Canonical).

canonical_variables('$VAR'(Number), Atom) :-
    !,
    atom_number(Label, Number),
    atom_concat('$v', Label, Atom).
canonical_variables(Value, Canonical) :-
    is_list(Value),
    !,
    maplist(canonical_variables, Value, Canonical).
canonical_variables(Value, Value).
