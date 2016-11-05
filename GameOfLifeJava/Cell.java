
public class Cell {
	String defaultDisplay = "-";
	boolean setAlive = false;
	
	public Cell (){
		
		
	}
	
	public boolean isAlive (){
		return setAlive;
		
	}

	
	public void setAlive (boolean t){
		if (t == true){
			this.defaultDisplay = "0";
			
		}
		this.setAlive = t;
		
	}
	
	
	public String toString (){
		return defaultDisplay ;
		
	}
	
	
}
