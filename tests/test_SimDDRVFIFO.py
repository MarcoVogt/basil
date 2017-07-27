#
# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

import unittest
import os
import logging
from time import sleep

from basil.dut import Dut
from basil.utils.sim.utils import cocotb_compile_and_run, cocotb_compile_clean, get_basil_dir


cnfg_yaml = """
transfer_layer:
  - name  : intf
    type  : SiSim
    init:
        host : localhost
        port  : 12345

hw_drivers:
  - name      : ddrvfifo
    type      : ddrvfifo
    interface : intf
    base_addr : 0x0020
    size      : 32

  - name      : gpio
    type      : gpio
    interface : intf
    base_addr : 0x0000
    size      : 24

registers:
  - name        : GPIO
    type        : StdRegister
    hw_driver   : gpio
    size        : 24
    fields:
      - name    : OUT
        size    : 8
        offset  : 7
      - name    : IN
        size    : 8
        offset  : 15
      - name    : READ
        size    : 1
        offset  : 16
      - name    : WRITE
        size    : 1
        offset  : 17
      - name    : TLAST
        size    : 1
        offset  : 18
      - name    : FULL
        size    : 1
        offset  : 20
      - name    : EMPTY
        size    : 1
        offset  : 21
"""


class TestSimDDRVFIFO(unittest.TestCase):
    def setUp(self):
        logging.info("setup")

        proj_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        xilinx_dir = os.environ.get('XILINX')
        fw_path = os.path.join(get_basil_dir(), 'firmware/modules')

        cocotb_compile_and_run(

            sim_files=[
            os.path.join(proj_dir,'tests/test_SimDDRVFIFO.v'),
            os.path.join(fw_path, 'gpio/gpio.v'),
            os.path.join(fw_path, 'utils/bus_to_ip.v'),
            os.path.join(fw_path, 'ddrvfifo/ddrvfifo.v'),
            os.path.join(fw_path, 'ddrvfifo/ddrvfifo_core.v'),
            os.path.join(fw_path, 'ddrvfifo/axi_ddrvfifo.v'),
	        os.path.join(fw_path, 'ddrvfifo/ddr/axi_vfifo_ctrl_0/axi_vfifo_ctrl_0_sim_netlist.v'),
#	        os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0/mig_7series_0_sim_netlist.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/mig_7series_0_mig_sim.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/mig_7series_0.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/axi/*.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/clocking/*.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/controller/*.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/ip_top/*.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/phy/*.v'),
            os.path.join(fw_path, 'ddrvfifo/ddr/mig_7series_0_sources/ui/*.v'),
	        os.path.join(fw_path, 'ddrvfifo/ddr/ddr3_model/ddr3_model.sv'),
            os.path.join(fw_path, 'ddrvfifo/ddr/ddr3_model/ddr3_model_parameters.vh')
	        ],

            top_level='tb',
            extra='VSIM_ARGS = -t 1ps -L ../unisims -L ../secureip -wlf /tmp/tb.wlf work.glbl'
            #VHDL_SOURCES+=''
            #sim_bus='basil.utils.sim.SiLibUsbBusDriver'
        )

        self.chip = Dut(cnfg_yaml)
        self.chip.init()


    def test_io(self):
        logging.info('Setup GPIO pins')
        self.chip['gpio'].set_output_en([0x0f, 0x00, 0xff])
        ret_io = self.chip['gpio'].get_output_en()
        self.assertEqual([0x0f, 0x00, 0xff], ret_io)
        print("GPIO:get_output_en = ", ret_io)

        self.chip['gpio'].set_data([0x00, 0x00, 0xa5])
        #ret_data = self.chip['gpio'].get_data()
        #print("ret_data=", ret_data)
        #self.assertEqual([0x15, 0xff, 0xff], ret_data) #test feedback

        #wait
        logging.info('Waiting for ddr3_init_done')
        while(not self.chip['ddrvfifo'].get_init_done() ):
            pass
        logging.info('Init done')

        #write a few bytes
        self.chip['GPIO']['OUT'] = 0xa5
        self.chip['GPIO']['WRITE'] = 1
        self.chip['GPIO'].write()
        self.chip['GPIO']['OUT'] = 0x5a
        self.chip['GPIO'].write()
        self.chip['GPIO']['OUT'] = 0x00
        self.chip['GPIO']['TLAST'] = 1
        self.chip['GPIO']['WRITE'] = 0
        self.chip['GPIO']['TLAST'] = 0
        self.chip['GPIO'].write()
        self.chip['GPIO']['TLAST'] = 0
        self.chip['GPIO'].write()

        #ret_status = self.chip['gpio'].get_data()
        while(not self.chip['ddrvfifo'].get_data_available()):
            sleep(1)
            pass

        while(self.chip['ddrvfifo'].get_data_available()):
            sleep(1)
            pass

        while(not self.chip['ddrvfifo'].get_data_available()):
            sleep(1)
            pass

        self.chip['GPIO']['READ'] = 1
        self.chip['GPIO'].write()
#        while(self.chip['ddrvfifo'].get_data_available()):
#            sleep(1)
#            pass
        self.chip['GPIO']['READ'] = 0
        self.chip['GPIO'].write()


    def tearDown(self):
        self.chip.close()  # let it close connection and stop simulator
        #cocotb_compile_clean()

if __name__ == '__main__':
    unittest.main()
