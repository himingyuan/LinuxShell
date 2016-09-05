#!/usr/bin/env python
while True:
  try:
	x = input('Enter x:')
	y = input('Enter y:')
	result = x/y
	print 'x/y is:',result
  except Exception,e:
	print 'error input:',e
	print 'Try again!!'
  else:
	break
