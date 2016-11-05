class Cell():
	def __init__(self):
		self.alive = False
	

	def isAlive(self):
		return self.alive
	
	def setAlive (self, booleanVal):
		self.alive = booleanVal
	
	def __str__(self):
		returnVal = "-"
		if self.alive :
			return "0"
		return returnVal
