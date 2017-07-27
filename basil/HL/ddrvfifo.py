#
# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

from basil.HL.RegisterHardwareLayer import RegisterHardwareLayer


class ddrvfifo(RegisterHardwareLayer):
    '''DDRVFIFO interface
    '''
    _registers = {  'RESET':    {'descr': {'addr': 0, 'size': 8, 'properties': ['writeonly']}},
                    'VERSION':  {'descr': {'addr': 0, 'size': 8, 'properties': ['ro']}},
                    'VALID':    {'descr': {'addr': 3, 'size': 1, 'offset': 0, 'properties': ['ro']}},
                    'INIT_DONE':{'descr': {'addr': 3, 'size': 1, 'offset': 1, 'properties': ['ro']}},
                    'DOUT':     {'descr': {'addr': 4, 'size': 1,'properties': ['ro', 'byte_array']}},
                    'DIN':      {'descr': {'addr': 5, 'size': 1,'properties': ['ro', 'byte_array']}},
    }
    _require_version = "==1"

    def __init__(self, intf, conf):
        super(ddrvfifo, self).__init__(intf, conf)

    def reset(self):
        '''Soft reset the module.'''
        self.RESET = 0

    def get_init_done(self):
        return self.INIT_DONE

    def get_data_available(self):
        return self.VALID

#    def set_data(self, value):
#        self.DIN = value

#    def get_data(self):
#        return self.DOUT

