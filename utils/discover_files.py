#/usr/bin/env python
from optparse import OptionParser
import sys
import subprocess
import os
import json
from util_functions import *


def main():

    parser = OptionParser()

    parser.add_option('--input', '-i', type='string', action='store',
                          dest='input',
                          default = '',
                          help='Input file string')

    parser.add_option('--instance', type='string', action='store',
                          dest='instance',
                          default = 'prod/phys03',
                          help='instance')
    
    (options, args) = parser.parse_args(sys.argv)
    argv = []

    lines = [w.rstrip() for w in open(options.input).readlines()]
    filemap = dasgoclient_files( lines )

    print (filemap)

    
        




if __name__ == "__main__":
    main()
