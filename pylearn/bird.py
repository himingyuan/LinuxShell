#!/usr/bin/env python
class Bird:
  def __init__(self):
	self.hungry = True
  def eat(self):
	if self.hungry:
	  print "Aaaaah...."
	  self.hungry = False
	else:
  	  print "not hungry..."
b = Bird()
b.eat()
b.eat()
