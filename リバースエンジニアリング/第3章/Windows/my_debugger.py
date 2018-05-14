from ctypes import *
from my_debugger_defines import *

kernel32 = windll.kernel32


class debugger():
    def __init__(self):
        self.h_process = None
        self.pid = None
        self.debugger_active = False

    def load(self, path_to_exe):
        creation_flags = DEBUG_PROCESS

        startupinfo = STARTUPINFO()
        process_information = PROCESS_INFORMATION()

        startupinfo.dwFlags = 0x1
        startupinfo.wShowWindow = 0x0

        startupinfo.cb = sizeof(startupinfo)

        if kernel32.CreateProcessW(
                path_to_exe,
                None,
                None,
                None,
                None,
                creation_flags,
                None,
                None,
                byref(startupinfo),
                byref(process_information)):
            print("[*] We have successfully launched the process!")
            print("[*] PID: %d" % process_information.dwProcessId)

            self.h_process = self.open_process(process_information.dwProcessId)
        else:
            print(path_to_exe)
            print(creation_flags)
            print("[*] Error: 0x%08x." % kernel32.GetLastError())

    def open_process(self, pid):
        h_process = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid)
        return h_process

    def attach(self, pid):
        self.h_process = self.open_process(pid)
        if kernel32.DebugActiveProcess(pid):
            self.debugger_active = True
            self.pid = int(pid)
            print("[*] Able to attach to the process")
        else:
            print("[*] Unable to attach to the process")

    def run(self):
        while self.debugger_active == True:
            self.get_debug_event()

    def get_debug_event(self):
        debug_event = DEBUG_EVENT()
        continue_status = DBG_CONTINUE

        if kernel32.WaitForDebugEvent(byref(debug_event), INFINITE):
            input("Press a key to continue...")
            self.debugger_active = False
            kernel32.ContinueDebugEvent(
                debug_event.dwProcessId,
                debug_event.dwThreadId,
                continue_status
            )

    def detach(self):
        if kernel32.DebugActiveProcessStop(self.pid):
            print("[*] Finished debugging. Exiting...")
            return True
        else:
            print("There was an error")
            return False
