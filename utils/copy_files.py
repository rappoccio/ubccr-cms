#/usr/bin/env python
from optparse import OptionParser
import sys
import subprocess
import os
from util_functions import *

        

def main():

    parser = OptionParser()

    parser.add_option('--input', '-i', type='string', action='store',
                          dest='input',
                          default = '',
                          help='Input file string')

    (options, args) = parser.parse_args(sys.argv)
    argv = []

    lines = [w.rstrip() for w in open(options.input).readlines()]

    xrdcp_files(lines)




if __name__ == "__main__":
    main()
