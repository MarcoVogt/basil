# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

import os
import yaml
from time import sleep
from basil.dut import Dut

chip = Dut("example.yaml")
chip.init()

print("Init done")

val=0

chip['GPIO_LED']['LED'] = 0x00
chip['GPIO_LED'].write()

for i in range(16):
    chip['GPIO_LED']['LED'] = val
    chip['GPIO_LED'].write()
    print(val)
    dip = chip['GPIO_LED']['DIP']
    print(dip)
    val += 1
#    sleep(0.1)


chip['GPIO_LED']['LED'] = 0x00
chip['GPIO_LED'].write()
