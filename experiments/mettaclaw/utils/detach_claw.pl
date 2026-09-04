% Detach MettaClaw onto a SWI thread so ECAN owns the main thread
% (avoids nesting concurrent_and / hyperpose, which hung ECAN).
% Restart after transient failures so one bad LLM call does not
% permanently kill goal-setting.
:- use_module(library(thread)).
:- use_module(library(time)).

detach_mettaclaw(true) :-
    thread_create(
        detach_mettaclaw_loop,
        _,
        [detached(true)]).

detach_mettaclaw_loop :-
    catch(eval([mettaclaw], _),
          Error,
          (write('MettaClaw detached thread error: '), writeln(Error),
           write('MettaClaw restarting in 15s...'), nl,
           sleep(15),
           detach_mettaclaw_loop)).
