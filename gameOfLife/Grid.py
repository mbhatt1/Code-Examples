from Cell import Cell

class Grid(object) :

    #construct a grid of cells
    def __init__(self, numRows, numColumns) :
        self.numRows = numRows
        self.numColumns = numColumns
        self.itsCurrentState = [ [ Cell() for x in range(numRows)] for y in range(numColumns)]
        self.itsNextState =    [ [ Cell() for x in range(numRows)] for y in range(numColumns)]

    def cellIsAlive(self, x, y) :
        return (self.itsCurrentState[x][y]).isAlive()

    def update(self) :
        # loop over rows
        for row in range(self.numRows) :
            for column in range(self.numColumns) :
                isAliveNextRound = self.aliveNextRound(row,column)
                self.itsNextState[row][column].setAlive(isAliveNextRound)
        self.swapStates();


    def aliveNextRound(self, row, column) :
        aliveNextRound = False
        currentAliveState = (self.itsCurrentState[row][column]).isAlive()
        liveNeighbors = self.getCountOfLiveNeighbors(row,column)
        if currentAliveState == True and liveNeighbors <2 :
            aliveNextRound = False
        elif currentAliveState == True and (liveNeighbors == 2 or liveNeighbors == 3) :
            aliveNextRound = True
        elif  currentAliveState == True and liveNeighbors > 3 :
            aliveNextRound = False
        elif currentAliveState == False and liveNeighbors == 3 :
            aliveNextRound = True
        return aliveNextRound

    def getCountOfLiveNeighbors(self, row, column) :
        numLiveNeighbors = 0
        up = row-1
        down = row+1
        right = column+1
        left = column-1
        if row == 0 :  # top edge case
            up = self.numRows-1
        elif row == self.numRows-1 : # bottom edge case
            down = 0

        if column == 0 :  # left edge case
            left = self.numColumns-1
        elif column == self.numColumns-1 : # right edge case
            right = 0

        neighborsToConsider = [ [up,left],   [up,column], [up,right],
                                [row,left],               [row,right],
                                [down,left],[down,column],[down,right] ]

        for neighbor in neighborsToConsider :
            if self.itsCurrentState[neighbor[0]][neighbor[1]].isAlive() :
                numLiveNeighbors = numLiveNeighbors + 1

        return numLiveNeighbors;

    # this swaps current and next references
    def swapStates(self) :
        temp = self.itsCurrentState
        self.itsCurrentState = self.itsNextState
        self.itsNextState = temp
    
    def __str__(self) :
        returnVal = "";
        for row in range(self.numRows) :
            for column in range(self.numColumns) :
                returnVal += str(self.itsCurrentState[row][column])
                returnVal += " "
            returnVal += "\n"
        return returnVal

    def gliderSetup(self) :
			self.itsCurrentState[5][5].setAlive(True)
			self.itsCurrentState[6][5].setAlive(True)
			self.itsCurrentState[7][5].setAlive(True)
			self.itsCurrentState[7][4].setAlive(True)
			self.itsCurrentState[6][3].setAlive(True)
