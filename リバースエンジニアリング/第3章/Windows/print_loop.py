from ctypes import *
import time

msvcrt = cdll.msvcrt
counter = 0

while 1:
    msvcrt.printf("Loop iteration %s!\n".encode('ascii'),
                  str(counter).encode('ascii'))
    time.sleep(2)
    counter += 1
