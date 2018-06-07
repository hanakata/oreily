import struct
import random
from immlib import *


class ioctl_hook(LogBpHook):
    def __init__(self):
        self.imm = Debugger()
        self.logfile = "C:\ioctl_log.txt"
        LogBpHook.__init__(self)

    def run(self, regs):
        ioctl_code = self.imm.readLong(regs['ESP'] + 8)
        inbuffer_size = self.imm.readLong(regs['ESP'] + 0x10)
        inbuffer_ptr = self.imm.readLong(regs['ESP'] + 0xC)
        in_buffer = self.imm.readMemory(inbuffer_ptr, inbuffer_size)
        mutated_buffer = self.mutate(inbuffer_size)

        self.imm.writeMemory(inbuffer_ptr, mutated_buffer)
        self.save_test_case(ioctl_code, inbuffer_size,
                            in_buffer, mutated_buffer)

    def mutate(self, inbuffer_size):
        counter = 0
        mutated_buffer = ""

        while counter < inbuffer_size:
            mutated_buffer += struct.pack("H", random.randint(0, 255))[0]
            counter += 1
            return mutated_buffer

    def save_test_case(self, ioctl_code, inbuffer_size, in_buffer, mutated_buffer):
        message = "*****\n"
        message += "IOCTL Code:              0x%08x\n" % ioctl_code
        message += "Buffer Size:             %d\n" % inbuffer_size
        message += "Original Buffer:         %s\n" % in_buffer
        message += "Mutated Buffer:          %s\n" % mutated_buffer.encode(
            "HEX")
        message += "*****\n\n"

        fd = open(self.logfile, "a")
        fd.write(message)
        fd.close

    def main(args):
        imm = Debugger()
        deviceiocontrol = imm.getAddress("kernel32.DeviceIoControl")
        ioctl_hooker = ioctl_hook()
        ioctl_hooker.add("%08x" % deviceiocontrol, deviceiocontrol)

        return "[*] IOCTL Fuzzer Ready for Action"
