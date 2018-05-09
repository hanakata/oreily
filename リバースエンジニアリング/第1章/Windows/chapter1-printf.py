from ctypes import *

msvcrt = cdll.msvcrt
message_string = "Hello world!\n"
msvcrt.printf("Testing: %s".encode('ascii'), message_string.encode('ascii'))
