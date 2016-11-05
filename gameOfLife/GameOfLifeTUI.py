import time
from Grid import Grid

class GameOfLifeTUI() :

    def __init__(self,xDim,yDim) :
        self.myGrid = Grid(xDim,yDim)
        self.xDim = xDim
        self.yDim = yDim
        self.myGrid.gliderSetup()

    def run(self) :
       # on purpose an endless loop
       self.clearScreen()
       while True :
          self.displayGrid()
          self.myGrid.update()
          time.sleep(1)
          self.clearScreen()

    def displayGrid(self) :
       print(self.myGrid)

    def clearScreen(self) :
       print("\033[H\033[2J")