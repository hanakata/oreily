import my_debugger

debugger = my_debugger.debugger()

pid = input("Enter the PID of the Process to attach to:")

debugger.attach(int(pid))
debugger.run()
debugger.detach()
