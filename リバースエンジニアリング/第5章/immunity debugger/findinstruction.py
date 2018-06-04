import immlib


def main(args):
    imm = immlib.Debugger()
    search_code = " ".join(args)
    search_bytes = imm.assemble(search_code)
    search_results = imm.search(search_bytes)

    for hit in search_results:
        code_page = imm.getMemoryPageByAddress(hit)
        access = code_page.getAccess(human=True)

        if "execute" in access.lower():
            imm.log("[*] Found: %s (0x%08x)" % (search_code, hit))
    return "[*] Finished searching for instructions, check the Log Window"
