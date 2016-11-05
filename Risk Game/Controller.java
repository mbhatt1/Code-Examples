
import java.util.ArrayList;
import java.lang.Integer;
import java.io.File;
import java.io.FileInputStream;
import java.io.DataInputStream;
import java.io.ObjectInputStream;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.io.FileOutputStream;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JOptionPane;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

/**
 * This class maps the user's actions in the View to the data and methods in the model.
 * @author Manish Bhatt, Samip Neupane
 * 
 * @date 11/30/14
 **/
public class Controller implements ActionListener, Serializable {

	private Model model;
	private Model loadedModel;
	private View view;
	private View view1;
	private  JFileChooser fileChooser;
	private ObjectInputStream objectReader;
	
	private PlayerCountDialog playerCountDialog;
	private BoardView boardView;
	private View loadedView;	
	//Constructor
	public Controller(Model model, View view) {
	
		System.out.println("Loaded Risk!");
		
		this.model = model;
		this.view = view;
		view.ViewActionListeners(this);
	}
	
	public void actionPerformed(ActionEvent evt) {
	
		String actionEvent = evt.getActionCommand();
		
		if (actionEvent.equals("newGameButton")) {
		
			
			playerCountDialog = new PlayerCountDialog(view, true);
			playerCountDialog.addActionListeners(new PlayerCountController(model, playerCountDialog));
			playerCountDialog.setVisible(true);
			/**
			 * The following lines of code will enable a user to load a saved game
			 * The file to load from won't be displayed in the File Chooser, but if
			 * the user knows the filename he used to save it with, he can input the
			 * filename, and hence can load the value from the file. 
			 * 
			 * FOr instance, if he saved it earlier with a name of "Manish", then in the
			 * screen that will be displayed, he needs to input the filename as 
			 * "Manish" to get the serialized model object back
			 */
		} else if (actionEvent.equals("loadGameButton")) {
			fileChooser = new JFileChooser();
			FileNameExtensionFilter filter = new FileNameExtensionFilter("Java-Risk Save Files", "jrs");
			fileChooser.setFileFilter(filter);
			
			if (fileChooser.showOpenDialog(view) == JFileChooser.APPROVE_OPTION) {
			
				try {
				objectReader = new ObjectInputStream(new FileInputStream(fileChooser.getSelectedFile()));
				loadedModel = (Model)objectReader.readObject();
				objectReader.close();
				view1 = new View();
				boardView = new BoardView(view1, true, loadedModel);
				
				boardView.addActionListeners(new BoardViewController(loadedModel, boardView), new RiskListController(loadedModel, boardView));
				boardView.pack();
				boardView.setVisible(true);
				
				} catch (IOException e) {
				System.out.println(e.getMessage());
				
				} catch (ClassNotFoundException e)	{
					e.printStackTrace();
				}
			}
		} else if (actionEvent.equals("quitButton")) {
				model.quitGame();
				
		} else {
				System.out.println("Error: " + actionEvent + " actionEvent not found!");
		}
	}
}

/**
 * This class maps the user's actions in the PlayerCountDialog to the data and methods in 
 * the model.
 * @author Manish Bhatt, Samip Neupane
 * 
 * @date 11/30/14
 **/
class PlayerCountController implements ActionListener {

	private Model model;
	private PlayerCountDialog view;
	
	private PlayerSettingsDialog playerSettingsDialog;
	public PlayerCountController(Model model, PlayerCountDialog view)
	{
		
		this.model = model;
		this.view = view;
	}
	
	public void actionPerformed(ActionEvent evt) {
	
		String actionEvent = evt.getActionCommand();
		
		if (actionEvent.equals("threePlayersButton")) {
		
			model.setPlayerCount(3);
			
			playerSettingsDialog = new PlayerSettingsDialog(view, true, model.getPlayerCount());
			playerSettingsDialog.addActionListeners(new PlayerSettingsController(model, playerSettingsDialog));
			playerSettingsDialog.setVisible(true);
		}
		
		else if (actionEvent.equals("fourPlayersButton")) {
		
			model.setPlayerCount(4);
			
			playerSettingsDialog = new PlayerSettingsDialog(view, true, model.getPlayerCount());
			playerSettingsDialog.addActionListeners(new PlayerSettingsController(model, playerSettingsDialog));
			playerSettingsDialog.setVisible(true);
		}
		
		else if (actionEvent.equals("fivePlayersButton"))
		{
			model.setPlayerCount(5);
			
			
			playerSettingsDialog = new PlayerSettingsDialog(view, true, model.getPlayerCount());
			playerSettingsDialog.addActionListeners(new PlayerSettingsController(model, playerSettingsDialog));
			playerSettingsDialog.setVisible(true);
		}
		
		else if (actionEvent.equals("sixPlayersButton"))
		{
			model.setPlayerCount(6);
			
			playerSettingsDialog = new PlayerSettingsDialog(view, true, model.getPlayerCount());
			playerSettingsDialog.addActionListeners(new PlayerSettingsController(model, playerSettingsDialog));
			playerSettingsDialog.setVisible(true);
		}
		
		else if (actionEvent.equals("backButton"))
		{
			view.dispose();
		}
		
		else
		{
			System.out.println("Error: " + actionEvent + " actionEvent not found!");
		}
	}
}

/**
 * This class maps the user's actions in the PlayerSettingsDialog to the data and methods in 
 * the model.
 * @author Manish Bhatt, Samip Neupane
 * 
 * @date 11/30/14
 **/
class PlayerSettingsController implements ActionListener {
	private boolean isLoaded;
	
	private ArrayList<String> playerNames;
	private ArrayList<String> playerTypes;
	
	private Model model;
	private PlayerSettingsDialog view;

	private BoardView boardView;
	
	public PlayerSettingsController(Model model, PlayerSettingsDialog view) {
		System.out.println("Loaded PlayerSettingsController!");
		this.model = model;
		this.view = view;
	}
	
	public void actionPerformed(ActionEvent evt) {
		isLoaded = false;
		String actionEvent = evt.getActionCommand();
		playerNames = new ArrayList<String>();
		playerTypes = new ArrayList<String>();
		
		if (actionEvent.equals("startButton")) {
		
			
			playerNames.add(view.getPlayerTextField(1));
			playerNames.add(view.getPlayerTextField(2));
			playerNames.add(view.getPlayerTextField(3));
			playerTypes.add(view.getPlayerComboBox(1));
			playerTypes.add(view.getPlayerComboBox(2));
			playerTypes.add(view.getPlayerComboBox(3));
			if (model.getPlayerCount() > 3) {
				playerNames.add(view.getPlayerTextField(4));
				playerTypes.add(view.getPlayerComboBox(4));
			}
			if (model.getPlayerCount() > 4) {
				playerNames.add(view.getPlayerTextField(5));
				playerTypes.add(view.getPlayerComboBox(5));
			}
			if (model.getPlayerCount() > 5) {
				playerNames.add(view.getPlayerTextField(6));
				playerTypes.add(view.getPlayerComboBox(6));
			}
	
			System.out.println("Initializing game...");
			try {
				isLoaded = model.initializeGame(playerNames, playerTypes);
			} catch (FileNotFoundException error) {
				System.out.println(error.getMessage());
			}
			
			if (isLoaded == true) {
				
				boardView = new BoardView(view, true, model);
				boardView.addActionListeners(new BoardViewController(model, boardView), new RiskListController(model, boardView));
				boardView.setVisible(true);
			}
		} else if (actionEvent.equals("backButton")) {
			view.dispose();
		
		} else {
			System.out.println("Error: " + actionEvent + " actionEvent not found!");
		}
	}
}

/**
 * This class maps the user's actions in the BoardView to the data and methods in the model.
 **/
class BoardViewController implements ActionListener {

	private Model model;
	private BoardView view;
	private MenuDialog menuDialog;
	
	public BoardViewController(Model model, BoardView view) {		
		this.model = model;
		this.view = view;
		model.startGame();
	}
	
	public void actionPerformed(ActionEvent evt) {
	
		String actionEvent = evt.getActionCommand();
		
		if (actionEvent.equals("menuButton")) {
			menuDialog = new MenuDialog(view, true);
			menuDialog.addActionListeners(new MenuController(model, menuDialog));
			menuDialog.setVisible(true);
			
		} else if (actionEvent.equals("turnInButton")) {
			model.turnInCards(view.getCardsToRemove());
			
		} else if (actionEvent.equals("reinforceButton")) {
			model.reinforce(view.getCountryA().replaceAll("[0-9]", "").replaceAll("\\-", ""));
			
		} else if (actionEvent.equals("attackButton")) {
			if(view.getCountryA() == null || view.getCountryB() == null){
				JOptionPane.showMessageDialog(view, "Select country to attack from and to attack from both panels");
			}
			model.attack(view.getCountryA().replaceAll("[0-9]", "").replaceAll("\\-", ""), view.getCountryB().replaceAll("[0-9]", "").replaceAll("\\-", ""));
			
		} else if (actionEvent.equals("fortifyButton")) {
			if(view.getCountryA() == null || view == null){
				JOptionPane.showMessageDialog(view, "Select country to attack from and to attack from both panels");
			}
			model.fortify(view.getCountryA().replaceAll("[0-9]", "").replaceAll("\\-", ""), view.getCountryB().replaceAll("[0-9]", "").replaceAll("\\-", ""));
			
		} else if (actionEvent.equals("endTurnButton")) {
			model.nextPlayer();
		
		} else {
			System.out.println("actionEvent: " + actionEvent);
		}
	}
}

/**
 * This class maps the user's actions in RiskList objects to the data and methods in the 
 * model.
 **/
class RiskListController implements ListSelectionListener {
	
	private Model model;
	private BoardView view2;
	
	public RiskListController(Model model, BoardView view3) {
		this.model = model;
		this.view2 = view3;
	}

	public void valueChanged(ListSelectionEvent evt) {
	
		if (evt.getValueIsAdjusting() == false) {
			
			if (view2.getCountryAIndex() == -1) {
			
			} else {
				model.setCountryASelection(view2.getCountryA().replaceAll("[0-9]", "").replaceAll("\\-", ""));
			}
		}
	}
}

/**
 * This class maps the user's actions in the MenuDialog to the data and methods in the model.
 **/
class MenuController implements ActionListener {

	private Model model;
	private MenuDialog view;
	
	private  JFileChooser fileChooser;
	private ObjectOutputStream objectWriter;
	private ObjectInputStream objectReader;
	private  BufferedReader reader;
	private  FileNameExtensionFilter filter;
	
	public MenuController(Model model, MenuDialog view) {
	
		this.model = model;
		this.view = view;
	}
	
	public void actionPerformed(ActionEvent evt) {
	
		String actionEvent = evt.getActionCommand();
		if (actionEvent.equals("returnButton")) {
			view.dispose();
			
		} 
		/**
		 * The following lines checks if the players have deployed and taken a turn. If 
		 * they have done that already, then the file can be saved. The filename entered here 
		 * must be remembered and must be entered in the load-game file chooser to load the 
		 * game. The filechooser doesn't show the name of the file- why? I haven't figured it out. 
		 */
		else if (actionEvent.equals("saveButton")) {
			int size = 0;
			
			for(int i = 0; i< model.players.size(); i++){
				if(model.players.get(i).getOwnedCountries() != null){
					size = size+ model.players.get(i).getOwnedCountries().size();
					
				}
				
			}
			//check if all countries have been claimed
			if(size == 42){
			fileChooser = new JFileChooser();
			filter = new FileNameExtensionFilter("Java-Risk Save Files", "jrs");
			fileChooser.setFileFilter(filter);
			if (fileChooser.showSaveDialog(view) == JFileChooser.APPROVE_OPTION) {
				try {
					objectWriter = new ObjectOutputStream(new FileOutputStream(fileChooser.getSelectedFile(), true));
					objectWriter.writeObject(model);
					objectWriter.close();
					
				} catch (IOException e) {
					System.out.println(e.getMessage()); 
				}
			}
		} 
			else{
				
			JOptionPane.showMessageDialog(view, "Can't Save Game. Please Select the territories first", "Alert Message!!!", JOptionPane.INFORMATION_MESSAGE );
			JOptionPane.showMessageDialog(view, "Game can only be saved After each player has taken a turn", "Alert Message!!!", JOptionPane.INFORMATION_MESSAGE );
			
			}
		}else if (actionEvent.equals("quitButton")) {
			model.quitGame();
			
		} else {
			System.out.println("actionEvent not found: " + actionEvent);
		}
	}
}