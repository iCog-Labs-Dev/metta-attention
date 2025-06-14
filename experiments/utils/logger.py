from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, S
from datetime import datetime
import csv
import json
import json



def get_csv_file_name() -> str:
    """ creats a name and file for the current instance of the controller """

    time = datetime.now().strftime("%H:%M:%S-%d-%m-%Y")
    file_name = f"csv/results_{time}.csv"
    return [S(file_name)]

def write_to_csv(afatoms, name):
    """ writes to a file passed as argument """
    data = []

    for atom in afatoms.get_children():
        (pattern, av) = atom.get_children()
        (_, sti, lti, _) = av.get_children()
        data.append({"timestamp": datetime.now(), "pattern":pattern, "sti":sti, "lti":lti}) 

    with open(name.get_name(), 'a') as f:
        writer = csv.DictWriter(f, fieldnames=["timestamp", "pattern", "sti", "lti"])

        if f.tell() == 0:
            writer.writeheader()
        
        for d in data:
            writer.writerow(d)

    return [S("wrote")]



def save_params(params):
    """ writes the params into a json file """

    data = {}
    for param in params.get_children():
        key, value = param.get_children()
        key = str(key)
        value = str(value)
        data[key] = value

    with open("/home/tarik/new-attention/metta-attention/output/settings.json", "w") as f:
        json.dump(data, f, indent=4)

    return [S('()')]


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

    saveParams = OperationAtom(
        "save_params",
        lambda param: save_params(param),
        ["Expression", "Atom"],
        unwrap=False
    )


    return {
                r"get_csv_file_name": getCsvFileName,
                r"write_to_csv": writeToCsv,
                r"save_params": saveParams
            }
