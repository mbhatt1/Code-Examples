import java.util.Arrays;
import java.util.Date;




public class GameOfLifeTUI {
	private Grid myGrid;
	
	
	public GameOfLifeTUI(int x, int y){
		this.myGrid=new Grid(x, y);
		myGrid.GliderSetup();
	}
	
	
	public void run(){
		
		while (true){
			clearScreen();
			this.displayGrid();
			myGrid.update();
			this.pause (1);
			clearScreen();
			
		}
		
	}
	
	private void clearScreen(){
		System.out.println("\u001b[2J");
		
	}
	
	public void displayGrid(){
		System.out.println (Arrays.deepToString(myGrid.currentState));
		
	}
	
	public void pause(int seconds){
	    Date start = new Date();
	    Date end = new Date();
	    while(end.getTime() - start.getTime() < seconds * 1000){
	        end = new Date();
	    }
	}
}
