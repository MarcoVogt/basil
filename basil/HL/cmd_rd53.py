#
# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

from basil.HL.RegisterHardwareLayer import RegisterHardwareLayer


class cmd_rd53(RegisterHardwareLayer):
    '''Implement master RD53 configuration and timing interface driver.
    '''

    _registers = {'RESET':          {'descr': {'addr': 0, 'size': 8, 'properties': ['writeonly']}},
                  'VERSION':        {'descr': {'addr': 0, 'size': 8, 'properties': ['ro']}},
                  'START':          {'descr': {'addr': 1, 'size': 1, 'offset': 7, 'properties': ['writeonly']}},
                  'READY':          {'descr': {'addr': 2, 'size': 1, 'offset': 0, 'properties': ['ro']}},
                  'SYNCING':        {'descr': {'addr': 2, 'size': 1, 'offset': 1, 'properties': ['ro']}},
                  'EXT_START_EN':   {'descr': {'addr': 2, 'size': 1, 'offset': 2, 'properties': ['rw']}},
                  'EXT_TRIGGER_EN': {'descr': {'addr': 2, 'size': 1, 'offset': 3, 'properties': ['rw']}},
                  'SIZE':           {'descr': {'addr': 3, 'size': 16}},
                  'MEM_BYTES':      {'descr': {'addr': 6, 'size': 16}},
                  }

    _require_version = "==1"

    def __init__(self, intf, conf):
        super(cmd_rd53, self).__init__(intf, conf)
        self._mem_offset = 16 # in bytes

    def init(self):
        super(cmd_rd53, self).init()
        self._mem_size = self.get_mem_size()

    def get_mem_size(self):
        return self.MEM_BYTES

    def get_cmd_size(self):
        return self.SIZE

    def reset(self):
        self.RESET = 0

    def start(self):
        self.START = 0

    def set_size(self, value):
        self.SIZE = value

    def get_size(self):
        return self.SIZE

    def set_ext_start(self, ext_start_mode):
        self.EXT_START_EN = ext_start_mode

    def get_ext_start(self):
        return self.EXT_START_EN

    def set_ext_trigger(self, ext_trigger_mode):
        self.EXT_TRIGGER_EN = ext_trigger_mode

    def get_ext_trigger(self):
        return self.EXT_TRIGGER_EN

    def is_done(self):
        return self.READY

    def set_data(self, data, addr=0):
        if self._mem_size < len(data):
            raise ValueError('Size of data (%d bytes) is too big for memory (%d bytes)' % (len(data), self._mem_size))
        self._intf.write(self._conf['base_addr'] + self._mem_offset + addr, data)

    def get_data(self, size=None, addr=0):
        if size and self._mem_size < size:
            raise ValueError('Size is too big')
        if not size:
            return self._intf.read(self._conf['base_addr'] + self._mem_offset + addr, self._mem_size)
        else:
            return self._intf.read(self._conf['base_addr'] + self._mem_offset + addr, size)
