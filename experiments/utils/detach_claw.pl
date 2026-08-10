% Detach MettaClaw onto a SWI thread so ECAN owns the main thread
% (avoids nesting concurrent_and / hyperpose, which hung ECAN).
:- use_module(library(thread)).

detach_mettaclaw(true) :-
    thread_create(
        catch(eval([mettaclaw], _),
              Error,
              (write('MettaClaw detached thread error: '), writeln(Error))),
        _,
        [detached(true)]).
