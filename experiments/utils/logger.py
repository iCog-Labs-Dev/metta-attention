from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, S
from hyperon.ext import register_atoms
from datetime import datetime
import csv



def get_csv_file_name() -> str:
    """ creats a name and file for the current instance of the controller """

    time = datetime.now().strftime("%H:%M:%S-%d-%m-%Y")
    file_name = f"csv/results_{time}.csv"
    return [S(file_name)]

def write_to_csv(afatoms, name):
    """ writes to a file passed as argument """
    data = []

    for atom in afatoms.get_children():
        (pattern, sti) = atom.get_children()
        data.append({"timestamp": datetime.now(), "pattern":pattern, "sti":sti}) 

    with open(name.get_name(), 'a') as f:
        writer = csv.DictWriter(f, fieldnames=["timestamp", "pattern", "sti"])

        if f.tell() == 0:
            writer.writeheader()
        
        for d in data:
            writer.writerow(d)

    return [S("wrote")]


@register_atoms(pass_metta=True)
def utils(metta):

    getCsvFileName = OperationAtom(
        "get_csv_file_name",
        lambda: get_csv_file_name(),
        ["Atom"],
        unwrap=False
        )

    writeToCsv = OperationAtom(
        "write_to_csv",
        lambda afatoms, name: write_to_csv(afatoms, name),
        ["Expression", "Expression", "Atom"],
        unwrap=False
        )
    return {r"get_csv_file_name": getCsvFileName, r"write_to_csv": writeToCsv}
