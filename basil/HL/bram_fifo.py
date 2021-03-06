#
# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

import logging
from time import sleep

import numpy as np

from basil.HL.RegisterHardwareLayer import RegisterHardwareLayer


class bram_fifo(RegisterHardwareLayer):
    '''BRAM FIFO controller interface for bram_fifo FPGA module.
    '''

    _registers = {'RESET': {'descr': {'addr': 0, 'size': 8, 'properties': ['writeonly']}},
                  'VERSION': {'descr': {'addr': 0, 'size': 8, 'properties': ['ro']}},
                  'ALMOST_FULL_THRESHOLD': {'descr': {'addr': 1, 'size': 8}},
                  'ALMOST_EMPTY_THRESHOLD': {'descr': {'addr': 2, 'size': 8}},
                  'READ_ERROR_COUNTER': {'descr': {'addr': 3, 'size': 8, 'properties': ['ro']}},
                  'FIFO_SIZE': {'descr': {'addr': 4, 'size': 32, 'properties': ['ro']}}}
    _require_version = "==2"

    def __init__(self, intf, conf):
        super(bram_fifo, self).__init__(intf, conf)

    def reset(self):
        self.RESET = 0
        sleep(0.01)  # wait some time for initialization

    @property
    def FIFO_INT_SIZE(self):
        ''' Get FIFO size in units of integers (32 bit).

        Returns
        -------
        fifo_size : int
            FIFO size in units of integers (32 bit).
        '''
        fifo_size = self.FIFO_SIZE
        # sometimes reading of FIFO size happens during writing to BRAM, but we want to have a multiplicity of 32 bits
        return (fifo_size - (fifo_size % 4)) / 4

    def get_FIFO_INT_SIZE(self):
        ''' Get FIFO size in units of integers (32 bit).

        Returns
        -------
        fifo_size : int
            FIFO size in units of integers (32 bit).
        '''
        return self.FIFO_INT_SIZE

    def get_data(self):
        ''' Reading data in BRAM.

        Returns
        -------
        array : numpy.ndarray
            Array of unsigned integers (32 bit).
        '''
        fifo_int_size_1 = self.FIFO_INT_SIZE
        fifo_int_size_2 = self.FIFO_INT_SIZE
        if fifo_int_size_1 > fifo_int_size_2:
            fifo_int_size = fifo_int_size_2  # use smaller chunk
            logging.warning("Reading wrong FIFO size. Expected: %d <= %d" % (fifo_int_size_1, fifo_int_size_2))
        else:
            fifo_int_size = fifo_int_size_1  # use smaller chunk
        return np.frombuffer(self._intf.read(self._conf['base_data_addr'], size=4 * fifo_int_size), dtype=np.dtype('<u4'))  # size in number of bytes
