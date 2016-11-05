import java.util.Observer;
import java.util.Observable;
import java.util.ArrayList;

import javax.swing.DefaultListModel;

/**
 * Allows the creation of JLists with updating strings from the Model.
 * @author Samip Neupane, Manish Bhatt
 * 
 * @date 12/02/14
 **/
public class ListModel extends DefaultListModel implements Observer {

	private int i;
	private String type;
	private String display;
	private ArrayList<String> stringList;
    private Model model;
	
    public ListModel (Model model, String type) {
	
        super();
        this.model = model;
		this.type = type;
    }
	
	public void update(Observable obs, Object obj) {
		display = (String)obj;
		
		if (type == "cards" && type == display) {
		
			removeAllElements();
			
			for (i = 0; i < model.getCardsList().size(); i++) {
			
				addElement(model.getCardsList().get(i));
			}
			
		} else if (type == "countryA" && type == display) {
		
			removeAllElements();
			
			for (i = 0; i < model.getCountryAList().size(); i++) {
			
				addElement(model.getCountryAList().get(i));
			}
			
		} else if (type == "countryB" && type == display) {
		
			removeAllElements();
			
			for (i = 0; i < model.getCountryBList().size(); i++) {
			
				addElement(model.getCountryBList().get(i));
			}
		} else {
		
		}
	}
}