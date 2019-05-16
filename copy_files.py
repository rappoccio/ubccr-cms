#/usr/bin/env python
from optparse import OptionParser
import sys
import subprocess

def main():

    parser = OptionParser()

    parser.add_option('--input', '-i', type='string', action='store',
                          dest='input',
                          default = '',
                          help='Input file string')

    (options, args) = parser.parse_args(sys.argv)
    argv = []

    lines = [w.rstrip() for w in open(options.input).readlines()]

    for iline,line in enumerate(lines):
        s =  'xrdcp root://cmsxrootd.fnal.gov/%s /mnt/cms-data%s' % (line,line)
        print (s)
        subprocess.call( s, shell=True )


if __name__ == "__main__":
    main()
