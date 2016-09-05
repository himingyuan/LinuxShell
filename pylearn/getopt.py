#!/usr/bin/env python
import getopt
try:
	options,args = getopt.getopt(sys.argv[1:],"hp:i:",["help","ip=","port="])
except getopt.GetoptError:
	sys.exit()

for name,value in options:
	if name in ("-h","--help"):
		usage()
	if name in ("-i","--ip"):
		print 'ip is----',value
	if name in ("-p","--port"):
		print 'port is----',value

options,args = getopt.getopt(sys.argv[1:],"hp:i:",["help","ip=","port="])

