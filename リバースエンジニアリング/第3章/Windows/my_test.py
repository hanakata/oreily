import my_debugger
from my_debugger_defines import *
debugger = my_debugger.debugger()

pid = input("Enter the PID of the Process to attach to:")

debugger.attach(int(pid))
printf = debugger.func_resolve("msvcrt.dll", "printf")
print("[*] Address of printf: 0x%08x" % printf)
# debugger.bp_set_sw(printf_address)
debugger.bp_set_hw(printf, 1, HW_EXECUTE)


# list = debugger.enumerate_threads()

# for thread in list:
#     thread_context = debugger.get_thread_context(thread)

#     print("[*] Dumping registers for thread ID: 0x%08x" % thread)
#     print("[*] RIP: 0x{0:016x}".format(thread_context.Rip))
#     print("[*] RSP: 0x{0:016x}".format(thread_context.Rsp))
#     print("[*] RBP: 0x{0:016x}".format(thread_context.Rbp))
#     print("[*] RAX: 0x{0:016x}".format(thread_context.Rax))
#     print("[*] RBX: 0x{0:016x}".format(thread_context.Rbx))
#     print("[*] RCX: 0x{0:016x}".format(thread_context.Rcx))
#     print("[*] RDX: 0x{0:016x}".format(thread_context.Rdx))
#     print("[*] END DUMP")


debugger.run()

# debugger.detach()
