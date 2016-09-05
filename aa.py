#!/usr/bin/env python
tuple=('a','b','c')
def print_params(*params):
	print params
print_params('test','test0','test1')
print_params(tuple)
