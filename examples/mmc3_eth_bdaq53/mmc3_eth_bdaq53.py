# ------------------------------------------------------------
# BDAQ53 tests
# Evaluation of RD53A-specific modules
#
# Command encoder  DONE    24.05.2017
# Debug signals    WIP
# Aurora 1-lane    WIP
# DDR3 FIFO        WIP
#
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

import time
import yaml
import numpy as np
import logging

from basil.dut import Dut
import rd53a


activelanes_tx = 1
activelanes_rx = 1


chip = rd53a.rd53a()
#chip = Dut("mmc3_eth_bdaq53.yaml")
chip.init()


#Configure CMD encoder
chip['cmd'].reset()
chip['cmd'].start()
chip['cmd'].set_ext_trigger(True)

print 'Mem size:', chip['cmd'].get_mem_size()


#Send a few test commands
for i in range(10):
    print(i)
    chip.write_ecr(write = True)


# set lanes and CB parameters
chip.set_aurora(tx_lanes = activelanes_tx, rx_lanes = activelanes_rx, CB_Wait = 255, CB_Send = 1, chip_id = 8, write = True)
chip.write_ecr(write = True)

#wait for data
rawdata = chip['fifo'].get_data()
prev_size=0
cnt=0
for i in range(400):
    rawdata = np.hstack((rawdata, chip['fifo'].get_data()))
    size = len(rawdata)
    if cnt >= 3:
        break
    else:
        if size > prev_size:
            cnt = 0
        else:
            if size > 0:
                cnt += 1
    prev_size = size
    logging.info("#%d,%d Fifo size: %d", i, cnt, size)

