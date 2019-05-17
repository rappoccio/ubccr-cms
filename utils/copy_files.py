#/usr/bin/env python
from optparse import OptionParser
import sys
import subprocess


def xrdcp_files( infiles, xrdinput='root://cmsxrootd.fnal.gov', localinput='/mnt/cms-data' ):    
    for ifile,ffile in enumerate(infiles):
        directory = ''.join( ffile.split('/')[:-1] )
        print ('making directory', directory)
        s =  'xrdcp %s/%s %s/%s' % (xrdinput, ffile, localinput, ffile)
        print (s)
        #subprocess.call( s, shell=True )

        

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
