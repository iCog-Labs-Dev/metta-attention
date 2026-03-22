from functools import partial
import json
from multiprocessing import Pool, cpu_count
from client import MORK, ManagedMORK


def input():
    with ManagedMORK.connect(binary_path="../target/release/mork-server").and_terminate() as server:
        server.clear().block()

        server.sexpr_import_("file:///home/blightg/Documents/Icog/ecan/output/safebiginput.metta").block()
        # out = "tropical today caffeine central nervous system stimulant methylxanthine class nicotine is cancerogenic addictive substance salts sodim cynaide pottassium cynaide compounds highly toxic aflatoxins poisonous carcinogens that are produced certain molds which grow in soil decaying vegetation hay grains"
        out = server.download("(theoutput $x)", "$x")
        heads = set(out.data.split())
        # heads = set(out.split())
        

        with open("/home/blightg/Documents/Icog/ecan/incident/final.metta", "w") as f:
            for head in heads:
                print(head)
                out = server.download(f"({head} $link)", f"$link").data
                out = out.replace('\n', ' ').removesuffix(' ')
                out = f"({head} ({out}))\n"
                f.write(out)

if __name__ == '__main__':
    input()
    
