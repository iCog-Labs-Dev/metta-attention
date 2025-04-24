from hyperon import *
from hyperon.ext import register_atoms
from hyperon.exts.agents import AgentObject
# import random
# import string
# import time
from hyperon.atoms import OperationAtom, V, S
from hyperon.ext import register_atoms
# import itertools
# from itertools import combinations
from datetime import datetime
import csv



def get_csv_file_name() -> str:
    """ creats a name and file for the current instance of the controller """

    time = datetime.now().strftime("%H:%M:%S-%d-%m-%Y")
    file_name = f"csv/results_{time}.csv"
    return [S(file_name)]

def write_to_csv(name):
    """ writes to a file passed as argument """
    data = [{"timestamp": datetime.now(),  "pattern": "ants", "sti": 10}]
    
    # print(type(name.get_children()[0]))
    # nname = str(name.get_children()[0])
    print(type(name.get_name()))
    with open(name.get_name(), 'a') as f:
        writer = csv.DictWriter(f, fieldnames=["timestamp", "pattern", "sti"])

        if f.tell() == 0:
            writer.writeheader()
        
        if len(data) > 1:
            for d in data:
                writer.writerow(d)

    return [S("wrote")]


@register_atoms(pass_metta=True)
def utils(metta):

    helloWorld = OperationAtom(
        "hello_world",
        lambda: hello_world(),
        ["Atom"],
        unwrap=False
        )

    getCsvFileName = OperationAtom(
        "get_csv_file_name",
        lambda: get_csv_file_name(),
        ["Atom"],
        unwrap=False
        )

    writeToCsv = OperationAtom(
        "write_to_csv",
        lambda name: write_to_csv(name),
        ["Expression", "Atom"],
        unwrap=False
        )
    return {r"hello_world": helloWorld, r"get_csv_file_name": getCsvFileName, r"write_to_csv": writeToCsv}
