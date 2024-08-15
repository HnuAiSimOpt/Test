import os
import ast

class SimuResult:
    '''
    A container of simulation information and result
    '''
    def __init__(self, paradict : dict[str, float], fwrpm : list[float], bwrpm : list[float], wkname : str = "work"):
        self.paradict = paradict
        self.fwrpm = fwrpm
        self.bwrpm = bwrpm
        self.workname = wkname
    def __str__(self) -> str:
        return f"{self.workname}\n{self.paradict}\n{self.fwrpm}\n{self.bwrpm}\n"


def parse_result_text(filename : str) -> list[SimuResult]:
    '''
    Parse simulation result text file
    '''
    rstls : list[SimuResult] = []
    with open(filename, "r") as file1:
        file1.seek(0, os.SEEK_END)
        n = file1.tell()
        file1.seek(0)
        while(file1.tell() != n):
            s0 = file1.readline() # work name
            s0 = s0.removesuffix('\n')
            s1 = file1.readline() # parameter dictionary
            s1 = s1.removesuffix('\n')
            s2 = file1.readline() #FW rotating velocity (rpm)
            s2 = s2.removesuffix('\n')
            s3 = file1.readline() #BW rotating velocity (rpm)
            s3 = s3.removesuffix('\n')
            s1dict = ast.literal_eval(s1)
            s2l = ast.literal_eval(s2)
            s3l = ast.literal_eval(s3)
            simr = SimuResult(s1dict, s2l, s3l, s0)
            rstls.append(simr)
    return rstls