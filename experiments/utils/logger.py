from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, S, ExpressionAtom 
from datetime import datetime
from pathlib import Path
import csv
import json
import os

class Logger:

    start_logger = False
    logging_directory = ""
    setting_path = ""
    csv_path = ""

    @classmethod
    def start_logger(cls, directory):
        """ 
            writes the params into a json file 
            and changes value of global param to start logger 
        """
        cls.start_logger = True
        cls.parse_path(str(directory.get_name()))
        cls.create_file_paths()
        cls.clear_csv()
        cls.clear_settings()
        
        return [S('()')]

    @classmethod
    def save_params(cls, metta, params):

        if not cls.start_logger:
            return [S('()')]

        data = {}
        for param in params.get_children():
            key, value = param.get_children()
            key = str(key)
            value = str(value)
            data[key] = value

        if cls.setting_path.exists():
            with cls.setting_path.open("r") as f:
                try:
                    existing_data = json.load(f)
                except json.JSONDecodeError:
                    existing_data = {}

            existing_data.update(data)
        else:
            existing_data = data
        
        with cls.setting_path.open("w") as f:
            json.dump(existing_data, f, indent=4)


        return[S('()')]

    @classmethod
    def parse_path(cls, path):

        if not isinstance(path, str):
            raise TypeError("parse_path accepts only str instace")

        base_path = Path(__file__).parent.parent.parent

        path_str = base_path / path
        if path_str.exists() and path_str.is_dir() and os.access(path_str, os.R_OK):
            cls.logging_directory = path_str
        else:
            raise ValueError(f"{path_str} can not be resolved")

    @classmethod
    def create_file_paths(cls):

        if not isinstance(cls.logging_directory, Path):
            raise TypeError("Invalid type for logging directory")

        log_dir = cls.logging_directory / "output"

        if not log_dir.exists():
            log_dir.mkdir()

        cls.setting_path = log_dir / "settings.json"
        cls.csv_path = log_dir / "output.csv"
        print(f"writing outputs to {log_dir.resolve()} Directory")

    @classmethod
    def clear_csv(cls):

        csv_path = cls.csv_path
        if not isinstance(csv_path, Path):
            raise TypeError("Invalid type for cls.csv_path")


        if csv_path.exists():
            csv_path.write_text("")

    @classmethod
    def clear_settings(cls):

        setting_path = cls.setting_path
        if not isinstance(setting_path, Path):
            raise TypeError("Invalid type for cls.csv_path")


        if setting_path.exists():
            setting_path.write_text("")

    @classmethod
    def write_to_csv(cls, afatoms):
        """ writes to a file passed as argument """

        if not isinstance(afatoms, ExpressionAtom):
            raise TypeError("write_to_csv expects an ExpressionAtom argument")

        # check is a global param before writing
        if not cls.start_logger:
            return [S('()')]

        data = []

        for atom in afatoms.get_children():
            (pattern, av) = atom.get_children()
            (_, sti, lti, _) = av.get_children()
            data.append({"timestamp": datetime.now(), "pattern":pattern, "sti":sti, "lti":lti}) 

        with open(cls.csv_path, 'a') as f:
            writer = csv.DictWriter(f, fieldnames=["timestamp", "pattern", "sti", "lti"])

            if f.tell() == 0:
                writer.writeheader()
            
            for d in data:
                writer.writerow(d)

        return [S("wrote")]



@register_atoms(pass_metta=True)
def utils(metta):

    startLogger = OperationAtom(
        "start_logger",
        lambda directory: Logger.start_logger(directory),
        ["Atom", "Atom"],
        unwrap=False
        )
    writeToCsv = OperationAtom(
        "write_to_csv",
        lambda afatoms: Logger.write_to_csv(afatoms),
        ["Expression", "Atom"],
        unwrap=False
        )

    saveParams = OperationAtom(
        "save_params",
        lambda params: Logger.save_params(metta, params),
        ["Expression", "Atom"],
        unwrap=False
        )

    return {
                r"start_logger": startLogger,
                r"write_to_csv": writeToCsv,
                r"save_params": saveParams,
            }

print("utils imported")