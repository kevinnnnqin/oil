#!/usr/bin/python -S
from __future__ import print_function
"""
callgraph_test.py: Tests for callgraph.py
"""

import unittest
import sys

from opy import callgraph  # module under test
from core.meta import types_asdl

lex_mode_e = types_asdl.lex_mode_e

class CallgraphTest(unittest.TestCase):

  def testFoo(self):
    # Figuring out how to inspect ASDL types

    print(lex_mode_e)
    print(dir(lex_mode_e))
    print(lex_mode_e.__module__)
    print(sys.modules[lex_mode_e.__module__])
    print(sys.modules[lex_mode_e.__module__].__file__)

    print(callgraph)


if __name__ == '__main__':
  unittest.main()
