import java.util.Arrays;


public class Grid {
	private int numOfRows = 0;
	private int numOfColumns = 0;
	public 	Cell[][] currentState ;
	private Cell[][] nextState ;
	
	
	public Grid(int numOfRows, int numOfColumns){
		this.numOfRows = numOfRows;
		this.numOfColumns = numOfColumns;
		this.currentState = new Cell[numOfRows][numOfColumns];
		this.nextState = new Cell[numOfRows][numOfColumns];
		for (int i = 0; i < numOfRows; i++){
			for (int j = 0; j < numOfColumns; j++){
				currentState[i][j] = new Cell();
				nextState[i][j] = new Cell();
			}
			
		}
	}
	
	public void GliderSetup(){
		this.currentState[5][5].setAlive(true);
		this.currentState[6][5].setAlive(true);
		this.currentState[7][5].setAlive(true);
		this.currentState[7][4].setAlive(true);
        this.currentState[6][3].setAlive(true);
		
	}
	
	public int getNeighbourCount(int row, int column){
		int numberOfNeighbours = 0;
			int up = row - 1 ;
			int down = row + 1;
			int left = column - 1;
			int right = column + 1;
			if (row == 0){
				up = this.numOfRows-1;
			}
			if (row == (this.numOfRows-1)){
				down = 0;
			}
			if (column == (this.numOfColumns-1)){
				right = 0;
			}
			if (column == 0){
				left = this.numOfColumns-1;
			}
			
			int[][] neighbours = {{up, left}, {up, column}, {up, right}, {row, left}, {row, right}, {down, left}, {down, column}, {down, right}};
			
			for (int[] j : neighbours){
				if (this.currentState[j[0]][j[1]].isAlive()){
					numberOfNeighbours++;
				}
			}
			
		return numberOfNeighbours;
		
	}

	public boolean isAliveNextRound(int row, int column){
		boolean aliveNextRound = false;
			boolean current = currentState[row][column].isAlive();
			int liveNeighbours = getNeighbourCount(row, column);
			if (current == true && liveNeighbours < 2){
				aliveNextRound = false;
			}else if (current == true && (liveNeighbours == 2 || liveNeighbours == 3)){
				aliveNextRound = true;
			}else if (current == false && liveNeighbours == 3){
				aliveNextRound = true;
			}else {
				aliveNextRound = false;
			}
			
			return aliveNextRound;
	}

	public void update(){
		for (int i = 0; i < this.numOfRows; i ++){
			for (int j = 0; j < numOfColumns; j++){
				boolean alivenext=  isAliveNextRound(i, j);
				this.nextState[i][j].setAlive(alivenext);
			}
		}
		
		swapStates();
	
	}

	private void swapStates(){
		Cell[][] temp = this.currentState;
		this.currentState = this.nextState;
		this.nextState = temp;
		
	}


	

}
