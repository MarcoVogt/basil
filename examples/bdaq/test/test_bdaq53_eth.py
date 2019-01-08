# ------------------------------------------------------------
# SiTCP throughput test
# Reads data for a couple of seconds and displays the data rate
#
# Copyright (c) All rights reserved
# SiLab, Physics Institute, University of Bonn
# ------------------------------------------------------------
#
import unittest
import os, sys
import time
from basil.dut import Dut
from basil.utils.sim.utils import cocotb_compile_and_run, cocotb_compile_clean

doprint=True
IntsToReceive=1000

class TestSimBDAQ53Eth(unittest.TestCase):
    def setUp(self):
        sys.path = [os.path.dirname(os.getcwd())] + sys.path
        proj_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        cocotb_compile_and_run(
           sim_files = [proj_dir + '/test/bdaq53_eth_tb.v'],
           top_level = 'tb',
           include_dirs = (proj_dir, proj_dir + '/firmware/src')
        )

        with open("bdaq53_eth.yaml") as conf_file:
            try:
                conf = yaml.load(conf_file)
            except yaml.YAMLError as exception:
                print(exception)

        cnfg['transfer_layer'][0]['type'] = 'SiSim'

        cnfg['hw_drivers'].append({'name': 'fifo', 'type': 'sram_fifo',
                                   'interface': 'intf', 'base_addr': 0x8000, 'base_data_addr': 0x80000000})

        self.chip = Dut(cnfg_yaml)
        self.chip.init()


    def test(self):
        testduration = 10
        total_len = 0
        tick = 0
        tick_old = 0
        start_time = time.time()

        self.chip['GPIO_LED']['LED'] = 0x01  #start data source
        self.chip['GPIO_LED'].write()

        while time.time() - start_time < testduration:
            data = self.chip['FIFO'].get_data()
            total_len += len(data)
            time.sleep(0.01)
            tick = int(time.time() - start_time)
            if tick != tick_old:
                print(tick)
                tick_old = tick

            if doprint==True:
                print(data)

            for i in data:
                if i<(len(data)-1): assert data[i] == data[i+1]-1   #Check, if received integers are increasing numbers


            if total_len >= IntsToReceive:
                break

        total_len_bits = total_len*32   #32-bit ints to bits
        print('Bits received:', total_len_bits, '  data rate:', round((total_len_bits/1e6/testduration),2), ' Mbit/s')

        self.chip['GPIO_LED']['LED'] = 0x00  #stop data source
        self.chip['GPIO_LED'].write()


    def tearDown(self):
        self.chip.close()  # let it close connection and stop simulator
        cocotb_compile_clean()


if __name__ == '__main__':
    unittest.main()
