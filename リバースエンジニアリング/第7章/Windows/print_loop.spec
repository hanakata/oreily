# -*- mode: python -*-

block_cipher = None


a = Analysis(['print_loop.py'],
             pathex=['c:\\git\\oreily\\���o�[�X�G���W�j�A�����O\\��7��\\Windows'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='print_loop',
          debug=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=True )
