import immlib


def main(args):
    imm = immlib.Debugger()
    bad_char_found = False

    address = int(args[0], 16)
    shellcode = "<<作成したシェルコードをここに貼り付ける>>"
    shellcode_length = len(shellcode)

    debug_shellcode = imm.readMemory(address, shellcode_length)
    imm.log("Address:0x%08x" % address)
    imm.log("shellcode Length: %d" % shellcode_length)

    imm.log("Attack Shellcode: %s" % shellcode.encode("HEX"))
    imm.log("In Memory Shellcode: %s" % debug_shellcode.encode("HEX"))

    count = 0
    while count < shellcode_length:
        if debug_shellcode[count] != shellcode[count]:
            imm.log("Bad Char Detected at offset %d" % count)
            bad_char_found = True
            break
        count += 1

    if bad_char_found:
        imm.log("[*****]")
        imm.log("Bad character found: %s" %
                debug_shellcode[count].encode("HEX"))
        imm.log("Bad character original: %s" %
                shellcode[count].encode("HEX"))
        imm.log("[*****]")
    return "[*] !badchar finished, check log window"
