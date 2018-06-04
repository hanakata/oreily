from distutils.core import setup
import py2exe

setup(console=['print_loop.py'], options={
      'py2exe': {'bundle_files': 1}}, zipfile=None,)
