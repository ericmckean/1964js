###1964js - JavaScript/HTML5 port of 1964 - N64 emulator
Copyright (C) 2012 Joel Middendorf

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.###

  #segments must be at least 64KB in size for lookup table.
`/** @const */ var MEMORY_START_RDRAM = 0x00000000`
`/** @const */ var MEMORY_SIZE_RDRAM = 0x800000` #4MB RDRAM + 4MB Expansion = 8MB
`/** @const */ var MEMORY_START_RAMREGS4 = 0x03F04000`
`/** @const */ var MEMORY_SIZE_RAMREGS4 = 0x10000`
`/** @const */ var MEMORY_START_RAMREGS0 = 0x03F00000`
`/** @const */ var MEMORY_START_RAMREGS8 = 0x03F80000`
`/** @const */ var MEMORY_SIZE_RAMREGS0 = 0x10000`
`/** @const */ var MEMORY_SIZE_RAMREGS8 = 0x10000`
`/** @const */ var MEMORY_START_SPMEM = 0x04000000`
`/** @const */ var MEMORY_START_SPREG_1 = 0x04040000`
`/** @const */ var MEMORY_START_SPREG_2 = 0x04080000`
`/** @const */ var MEMORY_START_DPC = 0x04100000`
`/** @const */ var MEMORY_START_DPS = 0x04200000`
`/** @const */ var MEMORY_START_MI = 0x04300000`
`/** @const */ var MEMORY_START_VI = 0x04400000`
`/** @const */ var MEMORY_START_AI = 0x04500000`
`/** @const */ var MEMORY_START_PI = 0x04600000`
`/** @const */ var MEMORY_START_RI = 0x04700000`
`/** @const */ var MEMORY_START_SI = 0x04800000`
`/** @const */ var MEMORY_START_C2A1 = 0x05000000`
`/** @const */ var MEMORY_START_C1A1 = 0x06000000`
`/** @const */ var MEMORY_START_C2A2 = 0x08000000`
`/** @const */ var MEMORY_START_ROM_IMAGE = 0x10000000`
`/** @const */ var MEMORY_START_GIO = 0x18000000`
`/** @const */ var MEMORY_START_C1A3 = 0x1FD00000`
`/** @const */ var MEMORY_START_DUMMY = 0x1FFF0000`
`/** @const */ var MEMORY_SIZE_SPMEM = 0x10000`
`/** @const */ var MEMORY_SIZE_SPREG_1 = 0x10000`
`/** @const */ var MEMORY_SIZE_SPREG_2 = 0x10000`
`/** @const */ var MEMORY_SIZE_DPC = 0x10000`
`/** @const */ var MEMORY_SIZE_DPS = 0x10000`
`/** @const */ var MEMORY_SIZE_MI = 0x10000`
`/** @const */ var MEMORY_SIZE_VI = 0x10000`
`/** @const */ var MEMORY_SIZE_AI = 0x10000`
`/** @const */ var MEMORY_SIZE_PI = 0x10000`
`/** @const */ var MEMORY_SIZE_RI = 0x10000`
`/** @const */ var MEMORY_SIZE_SI = 0x10000`
`/** @const */ var MEMORY_SIZE_C2A1 = 0x10000`
`/** @const */ var MEMORY_SIZE_C1A1 = 0x10000`
`/** @const */ var MEMORY_SIZE_C2A2 = 0x20000`
`/** @const */ var MEMORY_SIZE_GIO = 0x10000`
`/** @const */ var MEMORY_SIZE_C1A3 = 0x10000`
`/** @const */ var MEMORY_SIZE_DUMMY = 0x10000`
`/** @const */ var MEMORY_START_PIF = 0x1FC00000`
`/** @const */ var MEMORY_START_PIF_RAM = 0x1FC007C0`
`/** @const */ var MEMORY_SIZE_PIF = 0x10000`
`/** @const */ var MEMORY_SIZE_ROM = 0x4000000`

class C1964jsMemory
  constructor: (@core) ->
    @romUint8Array = `undefined` # set after rom is loaded.
    @rom = `undefined` # set after rom is loaded.
    @rdramArrayBuffer = new ArrayBuffer(0x800000);
    @rdramUint8Array = new Uint8Array(@rdramArrayBuffer);
    @rdramUint16Array = new Uint16Array(@rdramArrayBuffer);
    @rdramUint32Array = new Uint32Array(@rdramArrayBuffer);
    @rdramDataView = new DataView(@rdramArrayBuffer);

    @spMemUint8Array = new Uint8Array(0x10000)
    @spReg1Uint8Array = new Uint8Array(0x10000)
    @spReg2Uint8Array = new Uint8Array(0x10000)
    @dpcUint8Array = new Uint8Array(0x10000)
    @dpsUint8Array = new Uint8Array(0x10000)
    @miUint8Array = new Uint8Array(0x10000)
    @viUint8Array = new Uint8Array(0x10000)
    @aiUint8Array = new Uint8Array(0x10000)
    @piUint8Array = new Uint8Array(0x10000)
    @siUint8Array = new Uint8Array(0x10000)
    @c2a1Uint8Array = new Uint8Array(0x10000)
    @c1a1Uint8Array = new Uint8Array(0x10000)
    @c2a2Uint8Array = new Uint8Array(0x10000)
    @c1a3Uint8Array = new Uint8Array(0x10000)
    @riUint8Array = new Uint8Array(0x10000)
    @pifUint8Array = new Uint8Array(0x10000)
    @gioUint8Array = new Uint8Array(0x10000)
    @ramRegs0Uint8Array = new Uint8Array(0x10000)
    @ramRegs4Uint8Array = new Uint8Array(0x10000)
    @ramRegs8Uint8Array = new Uint8Array(0x10000)
    @dummyReadWriteUint8Array = new Uint8Array(0x10000)
    @region = []
    @region16 = []
    @region32 = []
    @writeRegion8 = []
    @writeRegion16 = []
    @writeRegion32 = []

    @initRegion 0, 0x80000000, @readTLB8, @writeTLB8, @readTLB16, @writeTLB16, @readTLB32, @writeTLB32
    @initRegion 0x80000000, 0x40000000, @readDummy8, @writeDummy8, @readDummy16, @writeDummy16, @readDummy32, @writeDummy32
    @initRegion 0xC0000000, 0x40000000, @readTLB8, @writeTLB8, @readTLB16, @writeTLB16, @readTLB32, @writeTLB32
    @initRegion MEMORY_START_RDRAM, MEMORY_SIZE_RDRAM, @readRdram8, @writeRdram8, @readRdram16, @writeRdram16, @readRdram32, @writeRdram32
    @initRegion MEMORY_START_RAMREGS4, MEMORY_START_RAMREGS4, @readRamRegs4, @writeRamRegs4, @readRamRegs4, @writeRamRegs4, @readRamRegs4, @writeRamRegs4
    @initRegion MEMORY_START_SPMEM, MEMORY_SIZE_SPMEM, @readSpMem8, @writeSpMem8, @readSpMem16, @writeSpMem16, @readSpMem32, @writeSpMem32
    @initRegion MEMORY_START_SPREG_1, MEMORY_SIZE_SPREG_1, @readSpReg1_8, @writeSpReg1_8, @readSpReg1_16, @writeSpReg1_16, @readSpReg1_32, @writeSpReg1_32
    @initRegion MEMORY_START_SPREG_2, MEMORY_SIZE_SPREG_2, @readSpReg2_8, @writeSpReg2_8, @readSpReg2_16, @writeSpReg2_16, @readSpReg2_32, @writeSpReg2_32
    @initRegion MEMORY_START_DPC, MEMORY_SIZE_DPC, @readDpc8, @writeDpc8, @readDpc16, @writeDpc16, @readDpc32, @writeDpc32
    @initRegion MEMORY_START_DPS, MEMORY_SIZE_DPS, @readDps8, @writeDps8, @readDps16, @writeDps16, @readDps32, @writeDps32
    @initRegion MEMORY_START_MI, MEMORY_SIZE_MI, @readMi8, @writeMi8, @readMi16, @writeMi16, @readMi32, @writeMi32
    @initRegion MEMORY_START_VI, MEMORY_SIZE_VI, @readVi8, @writeVi8, @readVi16, @writeVi16, @readVi32, @writeVi32
    @initRegion MEMORY_START_AI, MEMORY_SIZE_AI, @readAi8, @writeAi8, @readAi16, @writeAi16, @readAi32, @writeAi32
    @initRegion MEMORY_START_PI, MEMORY_SIZE_PI, @readPi8, @writePi8, @readPi16, @writePi16, @readPi32, @writePi32
    @initRegion MEMORY_START_SI, MEMORY_SIZE_SI, @readSi8, @writeSi8, @readSi16, @writeSi16, @readSi32, @writeSi32
    @initRegion MEMORY_START_C2A1, MEMORY_SIZE_C2A1, @readC2A1_8, @writeC2A1_8, @readC2A1_16, @writeC2A1_16, @readC2A1_32, @writeC2A1_32
    @initRegion MEMORY_START_C1A1, MEMORY_SIZE_C1A1, @readC1A1_8, @writeC1A1_8, @readC1A1_16, @writeC1A1_16, @readC1A1_32, @writeC1A1_32
    @initRegion MEMORY_START_C2A2, MEMORY_SIZE_C2A2, @readC2A2_8, @writeC2A2_8, @readC2A2_16, @writeC2A2_16, @readC2A2_32, @writeC2A2_32
    @initRegion MEMORY_START_ROM_IMAGE, MEMORY_SIZE_ROM, @readRom8, @writeRom8, @readRom16, @writeRom16, @readRom32, @writeRom #todo: could be a problem to use romLength
    @initRegion MEMORY_START_C1A3, MEMORY_SIZE_C1A3, @readC1A3_8, @writeC1A3_8, @readC1A3_16, @writeC1A3_16, @readC1A3_32, @writeC1A3_32
    @initRegion MEMORY_START_RI, MEMORY_SIZE_RI, @readRi8, @writeRi8, @readRi16, @writeRi16, @readRi32, @writeRi32
    @initRegion MEMORY_START_PIF, MEMORY_SIZE_PIF, @readPif8, @writePif8, @readPif16, @writePif16, @readPif32, @writePif32
    @initRegion MEMORY_START_GIO, MEMORY_SIZE_GIO, @readGio8, @writeGio8, @readGio16, @writeGio16, @readGio32, @writeGio32
    @initRegion MEMORY_START_RAMREGS0, MEMORY_SIZE_RAMREGS0, @readRamRegs0_8, @writeRamRegs0_8, @readRamRegs0_16, @writeRamRegs0_16, @readRamRegs0_32, @writeRamRegs0_32
    @initRegion MEMORY_START_RAMREGS8, MEMORY_SIZE_RAMREGS8, @readRamRegs8_8, @writeRamRegs8_8, @readRamRegs8_16, @writeRamRegs8_16, @readRamRegs8_32, @writeRamRegs8_32
    @physRegion = undefined

  initRegion: (start, size, readRegion8, writeRegion8, readRegion16, writeRegion16, readRegion32, writeRegion32) ->
    end = (start + size) >>> 14
    start >>>= 14

    while start < end
      @region[start] = readRegion8
      @region16[start] = readRegion16
      @region32[start] = readRegion32     
      @writeRegion8[start] = writeRegion8
      @writeRegion16[start] = writeRegion16
      @writeRegion32[start] = writeRegion32
      start++

    return

  readDummy8: (that, a) ->
    off_ = a & 0x0000FFFC
    that.dummyReadWriteUint8Array[off_]

  readDummy16: (that, a) ->
    off_ = a & 0x0000FFFC
    that.dummyReadWriteUint8Array[off_] << 8 | that.dummyReadWriteUint8Array[off_ + 1]

  readDummy32: (that, a) ->
    off_ = a & 0x0000FFFC
    that.dummyReadWriteUint8Array[off_] << 24 | that.dummyReadWriteUint8Array[off_ + 1] << 16 | that.dummyReadWriteUint8Array[off_ + 2] << 8 | that.dummyReadWriteUint8Array[off_ + 3]

  #little-endian only
  readRdram8: (that, a) ->
    that.rdramUint8Array[a]

  readRdram16: (that, a) ->
    that.rdramUint8Array[a] << 8 | that.rdramUint8Array[a + 1]

  readRdram32: (that, a) ->
    that.rdramUint8Array[a] << 24 | that.rdramUint8Array[a + 1] << 16 | that.rdramUint8Array[a + 2] << 8 | that.rdramUint8Array[a + 3]

  readRamRegs0_8: (that, a) ->
    off_ = a - MEMORY_START_RAMREGS0
    that.ramRegs0Uint8Array[off_]

  readRamRegs0_16: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS0)
    that.ramRegs0Uint8Array[off_] << 8 | that.ramRegs0Uint8Array[off_ + 1]

  readRamRegs0_32: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS0)
    that.ramRegs0Uint8Array[off_] << 24 | that.ramRegs0Uint8Array[off_ + 1] << 16 | that.ramRegs0Uint8Array[off_ + 2] << 8 | that.ramRegs0Uint8Array[off_ + 3]

  readRamRegs4_8: (that, a) ->
    off_ = a - MEMORY_START_RAMREGS4
    that.ramRegs4Uint8Array[off_]

  readRamRegs4_16: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS4)
    that.ramRegs4Uint8Array[off_] << 8 | that.ramRegs4Uint8Array[off_ + 1]

  readRamRegs4_32: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS4)
    that.ramRegs4Uint8Array[off_] << 24 | that.ramRegs4Uint8Array[off_ + 1] << 16 | that.ramRegs4Uint8Array[off_ + 2] << 8 | that.ramRegs4Uint8Array[off_ + 3]

  readRamRegs8_8: (that, a) ->
    off_ = a - MEMORY_START_RAMREGS8
    that.ramRegs8Uint8Array[off_]

  readRamRegs8_16: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS8)
    that.ramRegs8Uint8Array[off_] << 8 | that.ramRegs8Uint8Array[off_ + 1]

  readRamRegs8_32: (that, a) ->
    off_ = (a-MEMORY_START_RAMREGS8)
    that.ramRegs8Uint8Array[off_] << 24 | that.ramRegs8Uint8Array[off_ + 1] << 16 | that.ramRegs8Uint8Array[off_ + 2] << 8 | that.ramRegs8Uint8Array[off_ + 3]

  readSpMem8: (that, a) ->
    off_ = a - MEMORY_START_SPMEM
    that.spMemUint8Array[off_]

  readSpMem16: (that, a) ->
    off_ = (a-MEMORY_START_SPMEM)
    that.spMemUint8Array[off_] << 8 | that.spMemUint8Array[off_ + 1]

  readSpMem32: (that, a) ->
    off_ = (a-MEMORY_START_SPMEM)
    that.spMemUint8Array[off_] << 24 | that.spMemUint8Array[off_ + 1] << 16 | that.spMemUint8Array[off_ + 2] << 8 | that.spMemUint8Array[off_ + 3]

  readSpReg1_8: (that, a) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.readSPReg1 off_

  readSpReg1_16: (that, a) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.readSPReg1 off_

  readSpReg1_32: (that, a) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.readSPReg1 off_

  readSpReg2_8: (that, a) ->
    off_ = a - MEMORY_START_SPREG_2
    that.spReg2Uint8Array[off_]

  readSpReg2_16: (that, a) ->
    off_ = (a-MEMORY_START_SPREG_2)
    that.spReg2Uint8Array[off_] << 8 | that.spReg2Uint8Array[off_ + 1]

  readSpReg2_32: (that, a) ->
    off_ = (a-MEMORY_START_SPREG_2)
    that.spReg2Uint8Array[off_] << 24 | that.spReg2Uint8Array[off_ + 1] << 16 | that.spReg2Uint8Array[off_ + 2] << 8 | that.spReg2Uint8Array[off_ + 3]

  readDpc8: (that, a) ->
    off_ = a - MEMORY_START_DPC
    that.dpcUint8Array[off_]

  readDpc16: (that, a) ->
    off_ = (a-MEMORY_START_DPC)
    that.dpcUint8Array[off_] << 8 | that.dpcUint8Array[off_ + 1]

  readDpc32: (that, a) ->
    off_ = (a-MEMORY_START_DPC)
    that.dpcUint8Array[off_] << 24 | that.dpcUint8Array[off_ + 1] << 16 | that.dpcUint8Array[off_ + 2] << 8 | that.dpcUint8Array[off_ + 3]

  readDps8: (that, a) ->
    off_ = a - MEMORY_START_DPS
    that.dpsUint8Array[off_]

  readDps16: (that, a) ->
    off_ = (a-MEMORY_START_DPS)
    that.dpsUint8Array[off_] << 8 | that.dpsUint8Array[off_ + 1]

  readDps32: (that, a) ->
    off_ = (a-MEMORY_START_DPS)
    that.dpsUint8Array[off_] << 24 | that.dpsUint8Array[off_ + 1] << 16 | that.dpsUint8Array[off_ + 2] << 8 | that.dpsUint8Array[off_ + 3]

  readMi8: (that, a) ->
    off_ = a - MEMORY_START_MI
    that.miUint8Array[off_]

  readMi16: (that, a) ->
    off_ = (a-MEMORY_START_MI)
    that.miUint8Array[off_] << 8 | that.miUint8Array[off_ + 1]

  readMi32: (that, a) ->
    off_ = (a-MEMORY_START_MI)
    that.miUint8Array[off_] << 24 | that.miUint8Array[off_ + 1] << 16 | that.miUint8Array[off_ + 2] << 8 | that.miUint8Array[off_ + 3]

  readVi8: (that, a) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.readVI off_

  readVi16: (that, a) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.readVI off_

  readVi32: (that, a) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.readVI off_

  readAi8: (that, a) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.readAI off_
  
  readAi16: (that, a) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.readAI off_

  readAi32: (that, a) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.readAI off_

  readPi8: (that, a) ->
    off_ = a - MEMORY_START_PI
    that.piUint8Array[off_]
  
  readPi16: (that, a) ->
    off_ = (a-MEMORY_START_PI)
    that.piUint8Array[off_] << 8 | that.piUint8Array[off_ + 1]

  readPi32: (that, a) ->
    off_ = (a-MEMORY_START_PI)
    that.piUint8Array[off_] << 24 | that.piUint8Array[off_ + 1] << 16 | that.piUint8Array[off_ + 2] << 8 | that.piUint8Array[off_ + 3]

  readSi8: (that, a) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.readSI off_

  readSi16: (that, a) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.readSI off_

  readSi32: (that, a) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.readSI off_

  readC2A1_8: (that, a) ->
    off_ = a - MEMORY_START_C2A1
    that.c2a1Uint8Array[off_]

  readC2A1_16: (that, a) ->
    off_ = (a-MEMORY_START_C2A1)
    that.c2a1Uint8Array[off_] << 8 | that.c2a1Uint8Array[off_ + 1]

  readC2A1_32: (that, a) ->
    off_ = (a-MEMORY_START_C2A1)
    that.c2a1Uint8Array[off_] << 24 | that.c2a1Uint8Array[off_ + 1] << 16 | that.c2a1Uint8Array[off_ + 2] << 8 | that.c2a1Uint8Array[off_ + 3]

  readC1A1_8: (that, a) ->
    off_ = a - MEMORY_START_C1A1
    that.c1a1Uint8Array[off_]

  readC1A1_16: (that, a) ->
    off_ = (a-MEMORY_START_C1A1)
    that.c1a1Uint8Array[off_] << 8 | that.c1a1Uint8Array[off_ + 1]

  readC1A1_32: (that, a) ->
    off_ = (a-MEMORY_START_C1A1)
    that.c1a1Uint8Array[off_] << 24 | that.c1a1Uint8Array[off_ + 1] << 16 | that.c1a1Uint8Array[off_ + 2] << 8 | that.c1a1Uint8Array[off_ + 3]

  readC2A2_8: (that, a) ->
    off_ = a - MEMORY_START_C2A2
    that.c2a2Uint8Array[off_]

  readC2A2_16: (that, a) ->
    off_ = (a-MEMORY_START_C2A2)
    that.c2a2Uint8Array[off_] << 8 | that.c2a2Uint8Array[off_ + 1]

  readC2A2_32: (that, a) ->
    off_ = (a-MEMORY_START_C2A2)
    that.c2a2Uint8Array[off_] << 24 | that.c2a2Uint8Array[off_ + 1] << 16 | that.c2a2Uint8Array[off_ + 2] << 8 | that.c2a2Uint8Array[off_ + 3]

  readRom8: (that, a) ->
    off_ = a - MEMORY_START_ROM_IMAGE
    that.romUint8Array[off_]

  readRom16: (that, a) ->
    off_ = (a-MEMORY_START_ROM_IMAGE)
    that.romUint8Array[off_] << 8 | that.romUint8Array[off_ + 1]

  readRom32: (that, a) ->
    off_ = (a-MEMORY_START_ROM_IMAGE)
    that.romUint8Array[off_] << 24 | that.romUint8Array[off_ + 1] << 16 | that.romUint8Array[off_ + 2] << 8 | that.romUint8Array[off_ + 3]

  readC1A3_8: (that, a) ->
    off_ = a - MEMORY_START_C1A3
    that.c1a3Uint8Array[off_]

  readC1A3_16: (that, a) ->
    off_ = (a-MEMORY_START_C1A3)
    that.c1a3Uint8Array[off_] << 8 | that.c1a3Uint8Array[off_ + 1]

  readC1A3_32: (that, a) ->
    off_ = (a-MEMORY_START_C1A3)
    that.c1a3Uint8Array[off_] << 24 | that.c1a3Uint8Array[off_ + 1] << 16 | that.c1a3Uint8Array[off_ + 2] << 8 | that.c1a3Uint8Array[off_ + 3]

  readRi8: (that, a) ->
    off_ = a - MEMORY_START_RI
    that.riUint8Array[off_]

  readRi16: (that, a) ->
    off_ = (a-MEMORY_START_RI)
    that.riUint8Array[off_] << 8 | that.riUint8Array[off_ + 1]

  readRi32: (that, a) ->
    off_ = (a-MEMORY_START_RI)
    that.riUint8Array[off_] << 24 | that.riUint8Array[off_ + 1] << 16 | that.riUint8Array[off_ + 2] << 8 | that.riUint8Array[off_ + 3]

  readPif8: (that, a) ->
    off_ = a - MEMORY_START_PIF
    that.pifUint8Array[off_]

  readPif16: (that, a) ->
    off_ = (a-MEMORY_START_PIF)
    that.pifUint8Array[off_] << 8 | that.pifUint8Array[off_ + 1]

  readPif32: (that, a) ->
    off_ = (a-MEMORY_START_PIF)
    that.pifUint8Array[off_] << 24 | that.pifUint8Array[off_ + 1] << 16 | that.pifUint8Array[off_ + 2] << 8 | that.pifUint8Array[off_ + 3]

  readGio8: (that, a) ->
    off_ = a - MEMORY_START_GIO
    that.gioUint8Array[off_]

  readGio16: (that, a) ->
    off_ = (a-MEMORY_START_GIO)
    that.gioUint8Array[off_] << 8 | that.gioUint8Array[off_ + 1]

  readGio32: (that, a) ->
    off_ = (a-MEMORY_START_GIO)
    that.gioUint8Array[off_] << 24 | that.gioUint8Array[off_ + 1] << 16 | that.gioUint8Array[off_ + 2] << 8 | that.gioUint8Array[off_ + 3]

  writeRdram8: (that, val, a) ->
    that.rdramUint8Array[a] = val
    return

  writeRdram16: (that, val, a) ->
    that.rdramUint8Array[a] = val >> 8
    that.rdramUint8Array[a + 1] = val
    return

  writeRdram32: (that, val, a) ->
    that.rdramUint8Array[a] = val >> 24
    that.rdramUint8Array[a + 1] = val >> 16
    that.rdramUint8Array[a + 2] = val >> 8
    that.rdramUint8Array[a + 3] = val
    return

  writeSpMem8: (that, val, a) ->
    off_ = a - MEMORY_START_SPMEM
    that.spMemUint8Array[off_] = val
    return

  writeSpMem16: (that, val, a) ->
    off_ = a - MEMORY_START_SPMEM
    that.spMemUint8Array[off_] = val >> 8
    that.spMemUint8Array[off_ + 1] = val
    return

  writeSpMem32: (that, val, a) ->
    off_ = a - MEMORY_START_SPMEM
    that.spMemUint8Array[off_] = val >> 24
    that.spMemUint8Array[off_ + 1] = val >> 16
    that.spMemUint8Array[off_ + 2] = val >> 8
    that.spMemUint8Array[off_ + 3] = val
    return

  writeRi8: (that, val, a) ->
    off_ = a - MEMORY_START_RI
    that.riUint8Array[off_] = val
    return

  writeRi16: (that, val, a) ->
    off_ = a - MEMORY_START_RI
    that.riUint8Array[off_] = val >> 8
    that.riUint8Array[off_ + 1] = val
    return

  writeRi32: (that, val, a) ->
    off_ = a - MEMORY_START_RI
    that.riUint8Array[off_] = val >> 24
    that.riUint8Array[off_ + 1] = val >> 16
    that.riUint8Array[off_ + 2] = val >> 8
    that.riUint8Array[off_ + 3] = val
    return

  writeMi8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_MI
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeMi16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_MI
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeMi32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_MI
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeRamRegs8_8: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS8
    that.ramRegs8Uint8Array[off_] = val
    return

  writeRamRegs8_16: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS8
    that.ramRegs8Uint8Array[off_] = val >> 8
    that.ramRegs8Uint8Array[off_ + 1] = val
    return

  writeRamRegs8_32: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS8
    that.ramRegs8Uint8Array[off_] = val >> 24
    that.ramRegs8Uint8Array[off_ + 1] = val >> 16
    that.ramRegs8Uint8Array[off_ + 2] = val >> 8
    that.ramRegs8Uint8Array[off_ + 3] = val
    return

  writeRamRegs4_8: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS4
    that.ramRegs4Uint8Array[off_] = val
    return

  writeRamRegs4_16: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS4
    that.ramRegs4Uint8Array[off_] = val >> 8
    that.ramRegs4Uint8Array[off_ + 1] = val
    return

  writeRamRegs4_32: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS4
    that.ramRegs4Uint8Array[off_] = val >> 24
    that.ramRegs4Uint8Array[off_ + 1] = val >> 16
    that.ramRegs4Uint8Array[off_ + 2] = val >> 8
    that.ramRegs4Uint8Array[off_ + 3] = val
    return

  writeRamRegs0_8: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS0
    that.ramRegs0Uint8Array[off_] = val
    return

  writeRamRegs0_16: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS0
    that.ramRegs0Uint8Array[off_] = val >> 8
    that.ramRegs0Uint8Array[off_ + 1] = val
    return

  writeRamRegs0_32: (that, val, a) ->
    off_ = a - MEMORY_START_RAMREGS0
    that.ramRegs0Uint8Array[off_] = val >> 24
    that.ramRegs0Uint8Array[off_ + 1] = val >> 16
    that.ramRegs0Uint8Array[off_ + 2] = val >> 8
    that.ramRegs0Uint8Array[off_ + 3] = val
    return

  writeSpReg1_8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writeSpReg1_16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writeSpReg1_32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writePi8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_PI
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writePi16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_PI
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writePi32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_PI
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writeSi8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeSi16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeSi32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeAi8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeAi16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeAi32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeVi8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeVi16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeVi32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeSpReg2_8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_2
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeSpReg2_16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_2
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeSpReg2_32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_2
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeDpc8: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_DPC
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDpc16: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_DPC
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDpc32: (that, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_DPC
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDps8: (that, val, a) ->
    off_ = a - MEMORY_START_DPS
    that.dpsUint8Array[off_] = val
    return

  writeDps16: (that, val, a) ->
    off_ = a - MEMORY_START_DPS
    that.dpsUint8Array[off_] = val >> 8
    that.dpsUint8Array[off_ + 1] = val
    return

  writeDps32: (that, val, a) ->
    off_ = a - MEMORY_START_DPS
    that.dpsUint8Array[off_] = val >> 24
    that.dpsUint8Array[off_ + 1] = val >> 16
    that.dpsUint8Array[off_ + 2] = val >> 8
    that.dpsUint8Array[off_ + 3] = val
    return

  writeC2A1_8: (that, val, a) ->
    off_ = a - MEMORY_START_C2A1
    that.c2a1Uint8Array[off_] = val
    return

  writeC2A1_16: (that, val, a) ->
    off_ = a - MEMORY_START_C2A1
    that.c2a1Uint8Array[off_] = val >> 8
    that.c2a1Uint8Array[off_ + 1] = val
    return

  writeC2A1_32: (that, val, a) ->
    off_ = a - MEMORY_START_C2A1
    that.c2a1Uint8Array[off_] = val >> 24
    that.c2a1Uint8Array[off_ + 1] = val >> 16
    that.c2a1Uint8Array[off_ + 2] = val >> 8
    that.c2a1Uint8Array[off_ + 3] = val
    return

  writeC1A1_8: (that, val, a) ->
    off_ = a - MEMORY_START_C1A1
    that.c1a1Uint8Array[off_] = val
    return

  writeC1A1_16: (that, val, a) ->
    off_ = a - MEMORY_START_C1A1
    that.c1a1Uint8Array[off_] = val >> 8
    that.c1a1Uint8Array[off_ + 1] = val
    return

  writeC1A1_32: (that, val, a) ->
    off_ = a - MEMORY_START_C1A1
    that.c1a1Uint8Array[off_] = val >> 24
    that.c1a1Uint8Array[off_ + 1] = val >> 16
    that.c1a1Uint8Array[off_ + 2] = val >> 8
    that.c1a1Uint8Array[off_ + 3] = val
    return

  writeC2A2_8: (that, val, a) ->
    off_ = a - MEMORY_START_C2A2
    that.c2a2Uint8Array[off_] = val
    return

  writeC2A2_16: (that, val, a) ->
    off_ = a - MEMORY_START_C2A2
    that.c2a2Uint8Array[off_] = val >> 8
    that.c2a2Uint8Array[off_ + 1] = val
    return

  writeC2A2_32: (that, val, a) ->
    off_ = a - MEMORY_START_C2A2
    that.c2a2Uint8Array[off_] = val >> 24
    that.c2a2Uint8Array[off_ + 1] = val >> 16
    that.c2a2Uint8Array[off_ + 2] = val >> 8
    that.c2a2Uint8Array[off_ + 3] = val
    return

  writeRom8: (that, val, a) ->
    alert "attempt to overwrite rom!"
    off_ = a - MEMORY_START_ROM_IMAGE
    that.romUint8Array[off_] = val
    return

  writeRom16: (that, val, a) ->
    off_ = a - MEMORY_START_ROM_IMAGE
    that.romUint8Array[off_] = val >> 8
    that.romUint8Array[off_ + 1] = val
    return

  writeRom32: (that, val, a) ->
    off_ = a - MEMORY_START_ROM_IMAGE
    that.romUint8Array[off_] = val >> 24
    that.romUint8Array[off_ + 1] = val >> 16
    that.romUint8Array[off_ + 2] = val >> 8
    that.romUint8Array[off_ + 3] = val
    return

  writeC1A3_8: (that, val, a) ->
    off_ = a - MEMORY_START_C1A3
    that.c1a3Uint8Array[off_] = val
    return

  writeC1A3_16: (that, val, a) ->
    off_ = a - MEMORY_START_C1A3
    that.c1a3Uint8Array[off_] = val >> 8
    that.c1a3Uint8Array[off_ + 1] = val
    return

  writeC1A3_32: (that, val, a) ->
    off_ = a - MEMORY_START_C1A3
    that.c1a3Uint8Array[off_] = val >> 24
    that.c1a3Uint8Array[off_ + 1] = val >> 16
    that.c1a3Uint8Array[off_ + 2] = val >> 8
    that.c1a3Uint8Array[off_ + 3] = val
    return

  writePif8: (that, val, a) ->
    off_ = a - MEMORY_START_PIF
    that.pifUint8Array[off_] = val
    return

  writePif16: (that, val, a) ->
    off_ = a - MEMORY_START_PIF
    that.pifUint8Array[off_] = val >> 8
    that.pifUint8Array[off_ + 1] = val
    return

  writePif32: (that, val, a) ->
    off_ = a - MEMORY_START_PIF
    that.pifUint8Array[off_] = val >> 24
    that.pifUint8Array[off_ + 1] = val >> 16
    that.pifUint8Array[off_ + 2] = val >> 8
    that.pifUint8Array[off_ + 3] = val
    return

  writeGio8: (that, val, a) ->
    off_ = a - MEMORY_START_GIO
    that.gioUint8Array[off_] = val
    return

  writeGio16: (that, val, a) ->
    off_ = a - MEMORY_START_GIO
    that.gioUint8Array[off_] = val >> 8
    that.gioUint8Array[off_ + 1] = val
    return

  writeGio32: (that, val, a) ->
    off_ = a - MEMORY_START_GIO
    that.gioUint8Array[off_] = val >> 24
    that.gioUint8Array[off_ + 1] = val >> 16
    that.gioUint8Array[off_ + 2] = val >> 8
    that.gioUint8Array[off_ + 3] = val
    return

  writeDummy8: (that, val, a) ->
    #log "writing to invalid memory at " + dec2hex(a)
    off_ = a & 0x0000fffc
    that.dummyReadWriteUint8Array[off_] = val
    return

  writeDummy16: (that, val, a) ->
    off_ = a & 0x0000fffc
    that.dummyReadWriteUint8Array[off_] = val >> 8
    that.dummyReadWriteUint8Array[off_ + 1] = val
    return

  writeDummy32: (that, val, a) ->
    off_ = a & 0x0000fffc
    that.dummyReadWriteUint8Array[off_] = val >> 24
    that.dummyReadWriteUint8Array[off_ + 1] = val >> 16
    that.dummyReadWriteUint8Array[off_ + 2] = val >> 8
    that.dummyReadWriteUint8Array[off_ + 3] = val
    return

  virtualToPhysical: (a) ->
    #uncomment to see where we're loading/storing
    #if ((((a & 0xF0000000)>>>0) isnt 0x80000000) and (((a & 0xF0000000)>>>0) isnt 0xA0000000))
    #  alert(dec2hex(a))
    
    #uncomment to verify non-tlb lookup.
    #if dec2hex(a) != dec2hex(((physRegion[a>>>12]<<16) | a&0x0000ffff))
    #  alert dec2hex(a) + ' ' + dec2hex(((physRegion[a>>>12]<<16) | a&0x0000ffff))
    return ((@physRegion[a>>>12]<<16) | (a&0x0000ffff))

  readTLB8: (that, a) ->
    a = that.virtualToPhysical(a)

    region = that.region[a>>>14]

    if region is that.readTLB8
      region = that.readDummy8

    region(that, a)

  writeTLB8: (that, val, a, pc, isDelaySlot) ->
    a = that.virtualToPhysical(a)

    region = that.writeRegion8[a>>>14]

    if region is that.writeTLB8
      region = that.writeDummy8

    region(that, val, a, pc, isDelaySlot)
    return

  readTLB16: (that, a) ->
    a = that.virtualToPhysical(a)

    region16 = that.region16[a>>>14]

    if region16 is that.readTLB16
      region16 = that.readDummy16

    region16(that, a)

  writeTLB16: (that, val, a, pc, isDelaySlot) ->
    a = that.virtualToPhysical(a)

    region16 = that.writeRegion16[a>>>14]

    if region16 is that.writeTLB16
      region16 = that.writeDummy16

    region16(that, val, a, pc, isDelaySlot)
    return

  readTLB32: (that, a) ->
    a = that.virtualToPhysical(a)

    region32 = that.region32[a>>>14]

    if region32 is that.readTLB32
      region32 = that.readDummy32

    region32(that, a)

  writeTLB32: (that, val, a, pc, isDelaySlot) ->
    a = that.virtualToPhysical(a)

    region32 = that.writeRegion32[a>>>14]

    if region32 is that.writeTLB32
      region32 = that.writeDummy

    region32(that, val, a, pc, isDelaySlot)
    return

  initPhysRegions: ->
    #Initialize the TLB Lookup Table
    @physRegion = new Int16Array(0x100000)
    i = 0
    #todo: replace with call to buildTLBHelper clear
    while i < 0x100000
      @physRegion[i] = (i & 0x1ffff) >>> 4
      i++
    return

  #getInt32 and getUint32 are identical. they both return signed.
  getInt8: (region, off_) ->
    region[off_]

  getInt16: (region, off_) ->
    region[off_] << 8 | region[off_ + 1]

  getInt32: (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  getUint32: (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  setInt8: (uregion, off_, val) ->
    uregion[off_] = val
    return

  setInt32: (uregion, off_, val) ->
    uregion[off_] = val >> 24
    uregion[off_ + 1] = val >> 16
    uregion[off_ + 2] = val >> 8
    uregion[off_ + 3] = val
    return

  setInt16: (uregion, off_, val) ->
    uregion[off_] = val >> 8
    uregion[off_ + 1] = val
    return

  lb: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region[a>>>14](this, a)

  lh: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region16[a>>>14](this, a)

  lw: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region32[a>>>14](this, a)

  sw: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion32[a>>>14](this, val, a, pc, isDelaySlot)
    return

  #Same routine as storeWord, but store a byte
  sb: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion8[a>>>14](this, val, a, pc, isDelaySlot)
    return

  sh: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion16[a>>>14](this, val, a, pc, isDelaySlot)
    return

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsMemory = C1964jsMemory
