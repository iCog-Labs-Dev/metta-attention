import os
import sys
import shutil
from pathlib import Path
import pytest
from hyperon import MeTTa, E, ExpressionAtom

BASE_DIR = Path(__file__).resolve().parents[2]

sys.path.insert(0, str(BASE_DIR))
from pythonController import ParallelScheduler, Agentrun

# change dir so metta working directory remain constant regardless of where it is called
os.chdir(BASE_DIR)


def setup_test():

    # create Base dir to allow robust agent path defination
    base_path = os.path.join(BASE_DIR, "attention/")

    metta = MeTTa()

    scheduler = ParallelScheduler(metta, "attention/paths.metta")
    
    scheduler.update_attention_param("MAX_AF_SIZE", 5)
    scheduler.update_attention_param("AFRentFrequency", 2.0)
    scheduler.update_attention_param("STI_FUNDS_BUFFER", 1000)
    scheduler.update_attention_param("LTI_FUNDS_BUFFER", 1000)
    scheduler.update_attention_param("TARGET_STI", 1000)
    scheduler.update_attention_param("TARGET_LTI", 1000)
    scheduler.update_attention_param("FUNDS_STI", 2000)
    scheduler.update_attention_param("FUNDS_LTI", 2000)
    
    scheduler.start_logger("pythonController/tests")

    print("base", BASE_DIR, "b2", base_path)
    scheduler.register_agent("test-superpose",
        lambda: Agentrun(metta=metta, path=os.path.join(base_path, "../experiments/Agents-runner.metta")))


    scheduler.load_imports("pythonController/tests/links.metta")

    return scheduler

def test_schduler():

    scheduler = setup_test()

    # assertions on atomspace starting condition
    assert scheduler.metta.run("!(assertEqual (getAtomList) ())") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (collapse (get-atoms &newAtomInAV)) ())") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (collapseAtomBin (atomBin)) ())") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (match &timer (firstTime $x) $x) True)") == [[E()]]

    # stimualte an atom Ants with 30 
    scheduler.stimulate_data("Ants", 30)

    assert scheduler.metta.run("!(assertEqual (collapse (get-atoms &newAtomInAV)) (Ants))") == [[E()]]

    # run all registered agents
    for agent_id in scheduler.agent_instances:
        agent = scheduler.get_or_create_agent(agent_id)
        agent.run()


    # assertion on state of spaces after one loop of running agents
    assert scheduler.metta.run("!(assertEqual (getAtomList) (Ants (SimilarityLink abamectin Ants)))") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (collapseAtomBin (atomBin)) ((52.0 (Ants)) (47.0 ((SimilarityLink abamectin Ants)))))") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (collapse (get-atoms &newAtomInAV)) ())") == [[E()]]

    # asserion on atoms lti and sti after one loop or running agents
    assert scheduler.metta.run("!(assertEqual (getSti Ants) 360)") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (getLti Ants) 600)") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (getSti (SimilarityLink abamectin Ants)) 240)") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (getLti (SimilarityLink abamectin Ants)) 0)") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (match &timer (firstTime $x) $x) False)") == [[E()]]

    # assertion on number of hebbian links created
    assert scheduler.metta.run("""!(assertEqual 
        (let $asym 
            (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
            (size-atom $asym)
        )
        5
    )""") == [[E()]]

    
    # second loop of calling agents
    scheduler.stimulate_data("aflatoxin", 30)
    assert scheduler.metta.run("!(assertEqual (collapse (get-atoms &newAtomInAV)) (aflatoxin))") == [[E()]]

    for agent_id in scheduler.agent_instances:
        agent = scheduler.get_or_create_agent(agent_id)
        agent.run()


    # assertions on new state of atoms and spaces
    assert scheduler.metta.run("""!(assertEqual (getAtomList) 
	    (Ants (SimilarityLink abamectin Ants) aflatoxin abamectin (SimilarityLink aldicarb aflatoxin)))""") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (< (getLti Ants) 600) True) ") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (getLti (SimilarityLink abamectin Ants)) 0)") == [[E()]]
    assert scheduler.metta.run("!(assertEqual (collapse (get-atoms &newAtomInAV)) ())") == [[E()]]
    assert scheduler.metta.run("""!(assertEqual
    (let $asym 
            (collapse (match (TypeSpace) ((ASYMMETRIC_HEBBIAN_LINK $x $y) $z) (ASYMMETRIC_HEBBIAN_LINK $x $y))) 
            (size-atom $asym)
        )
        23
    )""") == [[E()]]

    shutil.rmtree(BASE_DIR / "pythonController/tests/output")
