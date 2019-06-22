import sys
import subprocess
import os

def dasgoclient_files( datasets, instance='prod/phys03'):
    filemaps = {}
    for iline,line in enumerate(datasets):
        if instance :
            strinstance = 'instance=%s' % instance
        else: 
            strinstance = ''
        s = 'dasgoclient -query="file dataset=%s %s"' % (line.rstrip(), strinstance)
        print(s)
        retvals = subprocess.check_output( s, shell=True )
        filemaps[line] = [ x.decode('utf-8') for x in retvals.split(b'\n')]
    return filemaps
        


def xrdcp_files( infiles, xrdinput='root://cmsxrootd.fnal.gov', localinput='/mnt/cms-data', test=False ):    
    for ifile,ffile in enumerate(infiles):
        if ffile is '' or ffile is None:
            continue
        directory = localinput + '/'.join( ffile.split('/')[:-1] )
        os.makedirs( directory, exist_ok = True)
        s =  'xrdcp %s/%s %s/%s' % (xrdinput, ffile, localinput, ffile)
        if not test:
            subprocess.call( s, shell=True )
        else:
            print("Execution command: " , s)
