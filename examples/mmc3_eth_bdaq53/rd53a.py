#
# ------------------------------------------------------------
# Copyright (c) All rights reserved
# SiLab, Institute of Physics, University of Bonn
# ------------------------------------------------------------
#

import yaml
from basil.dut import Dut
import logging
logging.getLogger().setLevel(logging.DEBUG)
import os
import numpy as np
from basil.utils.BitLogic import BitLogic

class rd53a(Dut):

    cmd_data_map = {
        0: 0b01101010,
        1: 0b01101100,
        2: 0b01110001,
        3: 0b01110010,
        4: 0b01110100,
        5: 0b10001011,
        6: 0b10001101,
        7: 0b10001110,
        8: 0b10010011,
        9: 0b10010101,
        10: 0b10010110,
        11: 0b10011001,
        12: 0b10011010,
        13: 0b10011100,
        14: 0b10100011,
        15: 0b10100101,
        16: 0b10100110,
        17: 0b10101001,
        18: 0b10101010,
        19: 0b10101100,
        20: 0b10110001,
        21: 0b10110010,
        22: 0b10110100,
        23: 0b11000011,
        24: 0b11000101,
        25: 0b11000110,
        26: 0b11001001,
        27: 0b11001010,
        28: 0b11001100,
        29: 0b11010001,
        30: 0b11010010,
        31: 0b11010100
        }

    trigger_map = {
        0: 0b00101011,
        1: 0b00101011,
        2: 0b00101101,
        3: 0b00101110,
        4: 0b00110011,
        5: 0b00110101,
        6: 0b00110110,
        7: 0b00111001,
        8: 0b00111010,
        9: 0b00111100,
        10: 0b01001011,
        11: 0b01001101,
        12: 0b01001110,
        13: 0b01010011,
        14: 0b01010101,
        15: 0b01010110
        }

    CMD_GLOBAL_PULSE =  0b01011100
    CMD_CAL =           0b01100011
    CMD_REGISTER =      0b01100110
    CMD_RDREG =         0b01100101
    CMD_NULL =          0b01101001
    CMD_ECR =           0b01011010
    CMD_BCR =           0b01011001
    CMD_SYNCH =         0b10000001
    CMD_SYNCL =         0b01111110
    CMD_SYNC =         [0b10000001, 0b01111110] #0x(817E)


    def __init__(self,conf=""):

        if conf=="":
            conf = os.path.dirname(__file__) + os.sep + "rd53a.yaml"

        logging.debug("Loading configuration file from %s" % conf)
        super(rd53a, self).__init__(conf)

    def init(self):
        super(rd53a, self).init()


    def write_global_cmd(self, regs = 'all'):
        if regs == 'all':
            addr_size = len(self['global_conf'])/16
            regs = range(addr_size)

        for i in regs:
            self.write_register(i ,self['global_conf'][(i+1)*16-1:i*16].tovalue())



    def write_global_pulse(self, width, chip_id = 0, write = False):
        #0101_1100    ChipId<3:0>,0    Width<3:0>,0
        indata = [self.CMD_GLOBAL_PULSE]*2 #[0b01011100]
        chip_id_bits = chip_id << 1
        indata += [self.cmd_data_map[chip_id_bits]]
        width_bits = width << 1
        indata += [self.cmd_data_map[width_bits]]

        if write:
            self.write_command(indata)

        return indata

    def write_cal(self, cal_edge_dly = 2, cal_edge_width = 10, cal_aux_dly = 0, cal_aux_mode = 0, cal_edge_mode = 0, chip_id = 0, write = False):
        #0110_0011    ChipId<3:0>,CalEdgeMode - CalEdgeDly[2:0],CalEdgeWidth[5:4] - CalEdgeWidth[3:0],CalAuxMode - CalAuxDly[4:0]
        indata = [self.CMD_CAL]*2
        chip_id_bits = chip_id << 1
        indata += [self.cmd_data_map[(chip_id_bits+cal_edge_mode)]]
        cal_edge_dly_bits = BitLogic.from_value(0, size=3)
        cal_edge_dly_bits[:] = cal_edge_dly
        cal_edge_width_bits = BitLogic.from_value(0, size=6)
        cal_edge_width_bits[:] = cal_edge_width
        cal_aux_dly_bits = BitLogic.from_value(0, size=5)
        cal_aux_dly_bits[:] = cal_edge_dly

        indata += [self.cmd_data_map[cal_edge_dly_bits[2:0].tovalue()<<2 + cal_edge_width_bits[5:4].tovalue()]]
        indata += [self.cmd_data_map[(cal_edge_width_bits[3:0].tovalue()<<1 + cal_aux_mode)]]
        indata += [self.cmd_data_map[cal_aux_dly_bits[4:0].tovalue()]]

        if write:
            self.write_command(indata)

        return indata

    # Rrdeg: {RdReg,RdReg} {ChipId[3:0],0,Addr[8:4]} {Addr[3:0],0,0_0000} [RdReg +DD +DD]
    def read_register(self, address, chip_id = 8, write = False):
        indata = [self.CMD_RDREG]*2 #[0b01100101]
        chip_id_bits = chip_id << 1
        indata += [self.cmd_data_map[chip_id_bits]]
        addr_bits = BitLogic.from_value(0, size=9+6)
        addr_bits[14:6] = address # last 6 bits are 0
        indata += [self.cmd_data_map[addr_bits[14:10].tovalue()]]
        indata += [self.cmd_data_map[addr_bits[9:5].tovalue()]]
        indata += [self.cmd_data_map[addr_bits[4:0].tovalue()]]

        if write:
            self.write_command(indata)
        return indata

    def write_register(self, address, data, wr_reg_mode = 0, chip_id = 0, write = False):
        #0110_0110 ChipId[3:0],WrRegMode=0, Addr[8:0], Data[15:0];
        #0110_0110 ChipId[3:0],WrRegMode=1, Addr[8:0], Data[95:0];   <-- Not implemented in this TestBench
        indata = [self.CMD_REGISTER]*2 #[0b01100110]
        chip_id_bits = chip_id << 1
        indata += [self.cmd_data_map[(chip_id_bits+wr_reg_mode)]] #ChipId

        if wr_reg_mode == 0:
            addr_data_bits = BitLogic.from_value(0, size=9+16)
            addr_data_bits[24:16] = address
            addr_data_bits[15:0] = data

            indata += [self.cmd_data_map[addr_data_bits[24:20].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[19:15].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[14:10].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[9:5].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[4:0].tovalue()]]
        else:
            addr_data_bits = BitLogic.from_value(0, size=9+96)
            addr_data_bits[104:96] = address
            addr_data_bits[95:0] = data

            indata += [self.cmd_data_map[addr_data_bits[104:100].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[99:95].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[94:90].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[89:85].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[84:80].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[79:75].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[74:70].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[69:65].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[64:60].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[59:55].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[54:50].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[49:45].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[44:40].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[39:35].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[34:30].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[29:25].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[24:20].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[19:15].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[14:10].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[9:5].tovalue()]]
            indata += [self.cmd_data_map[addr_data_bits[4:0].tovalue()]]

        if write:
            self.write_command(indata)

        return indata


    def write_null(self, data, chip_id = 0, write = False):
        indata = [self.CMD_NULL]*2 #[0b01101001]
        if write:
            self.write_command(indata)
        return indata


    def write_ecr(self, write = False):
        indata = [self.CMD_ECR]*2 #[0b01011010]
        if write:
            self.write_command(indata)
        return indata


    def write_bcr(self, write = False):
        indata = [self.CMD_BCR]*2 #[0b01011001]
        if write:
            self.write_command(indata)
        return indata

    def write_sync(self, write = False):
        # indata = [self.CMD_SYNC] #[0b10000001, 0b01111110]
        indata  = [self.CMD_SYNCH]
        indata += [self.CMD_SYNCL]
        if write:
            self.write_command(indata)
        return indata


    def send_trigger(self, trigger, tag = 0, write = False):
        # Trigger is always followed by 5 Data bits
        indata = [self.trigger_map[trigger]]
        indata += [self.cmd_data_map[tag]]
        if write:
            self.write_command(indata)
        return indata

    def send_trigger_tag(self, trigger, trigger_tag, write = False):   #Send {TriggerID, TriggerTag}
        if trigger == 0:
            logging.error("Illegal trigger number")
            return
        else:
            indata = [self.trigger_map[trigger]]
            indata += [self.trigger_tag]
            if write:
                self.write_command(indata)
            return indata


    def write_command(self, data, wait_for_done = True):
        self['cmd'].set_data(data)
        self['cmd'].set_size(len(data))
        self['cmd'].start()

        if wait_for_done:
            while(not self['cmd'].is_done()):
                 pass


    def interpret_data(self, rawdata, do_print = False):
        data = np.array([], dtype={'names':['bcid','multicol','region','tot3','tot2','tot1','tot0'], 'formats':['uint32','uint16','uint16','uint8','uint8','uint8','uint8']})

        multicol=0
        region=0
        tot3=0
        tot2=0
        tot1=0
        tot0=0

        hi = False
        bcid = 0

        for inx, i in enumerate(rawdata):
            header = False
            if(i & 0x00010000):
                hi = True
                header = True
            else:
                hi = not hi

            if hi and inx + 1< len(rawdata):
                word = ((rawdata[inx] & 0xffff) << 16)+ (rawdata[inx+1] & 0xffff)

                if (header):# or rawdata[inx] == 0x00):
                    bcid = word & 0x7fff
                    trg_tag = (word >> 15) & 0x1f
                    trig_id = (word >> 20) & 0x1f
                    multicol = -1
                    if do_print: print(inx, hex(word), 'BcId=' + format(bcid), 'TrgTag=' + format(trg_tag) , 'TrgId=' + format(trig_id) )
                else:
                    multicol = (word & 0xfc000000) >> 26    #(word >>26) & 0xfc),
                    region =   (word & 0x03ff0000) >> 16    #(word >>16) & 0x3ff),
                    tot3 =     (word >>12) & 0xf
                    tot2 =     (word >> 8) & 0xf
                    tot1 =     (word >> 4) & 0xf
                    tot0 =      word       & 0xf
                    if do_print: print(inx, hex(word),
                         'multi-col='  + format(multicol),
                         'region='     + format(region),
                         'tot3='       + format(tot3),
                         'tot2='       + format(tot2),
                         'tot1='       + format(tot1),
                         'tot0='       + format(tot0))

                data_temp = np.array([(bcid, multicol, region, tot3, tot2, tot1, tot0)], dtype = data.dtype)
                data = np.append(data, data_temp)

        return data


    def write_register_name(self, register_name, data, chip_id = 0, write = False):
        #read register address from spreadsheet
        address=1
        #read register size from spreadsheet
        size=8
        #determine reg_mode
        wr_reg_mode = 0
        #mask data, check size???
        data = data & (2**size - 1)

        indata = self.write_register(self, address, data, wr_reg_mode = 0, chip_id = chip_id, write = write)

        return indata


    def set_aurora(self, tx_lanes = 1, rx_lanes = 1, CB_Wait = 255, CB_Send = 1, chip_id = 0, only_cb = False, write = False):
        indata = self.write_sync()
        indata += self.write_register(address = 74,data = CB_Wait & 0xf0 | CB_Send, chip_id = chip_id)     # Set CB frame distance and number
        indata += self.write_register(address = 75,data = (CB_Wait & 0xfffff)>>4,   chip_id = chip_id)     # Set CB frame distance and number

        if only_cb == False:
            logging.info("Aurora settings: Lanes: TX=%u RX=%u, CB_Wait=%u, CB_Send=%u", tx_lanes, rx_lanes, CB_Wait, CB_Send)
            if tx_lanes == 4:
                logging.info("4 Aurora lanes active")
                indata += self.write_register(address = 61,data = 0b00111100, chip_id = chip_id)         # Sets 4-lane-mode
                indata += self.write_register(address = 69,data = 0b00001111, chip_id = chip_id)         # Enable 4 CML outputs
            elif tx_lanes == 2:
                logging.info("2 Aurora lanes active")
                indata += self.write_register(address = 61,data = 0b00001100, chip_id = chip_id)         # Sets 2-lane-mode
                indata += self.write_register(address = 69,data = 0b00000011, chip_id = chip_id)         # Enable 2 CML outputs
            elif tx_lanes == 1:
                logging.info("1 Aurora lane active")
            else:
                logging.error("Aurora lane configuration (1,2,4) must be specified")
        else:
            logging.info("Aurora settings: CB_Wait=%u, CB_Send=%u", CB_Wait, CB_Send)

        if write:
            self.write_command(indata)
        return indata


if __name__=="__main__":
    chip = rd53a.rd53a()
    chip.init()
