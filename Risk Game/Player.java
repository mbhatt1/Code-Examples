import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Creates of Risk player objects.
 * @author Samip Neupane, Manish Bhatt
 
 * @date 11/30/2014
 **/
public class Player implements Serializable{
	//to check if player is Computer or not. 
	private boolean isAI;
	private int armies;
	private int turnInCount;
	private HashMap<String, Country> countriesHeld;
    private HashMap<String, Continent> continentsHeld;
	private int index;
	private String name;
	
	private Hand hand;

	public Player(String name, int armies, int index, boolean isAI) {
	
		this.name = name;
		this.armies = armies;
		this.index = index;
		this.isAI = isAI;
		
		countriesHeld = new HashMap<String, Country>();
		continentsHeld = new HashMap<String, Continent>();
		
		hand = new Hand();
		
		turnInCount = 0;
    }
	
	public int getIndex() {
		return index;
	}
	
	public String getName() {
		return name;
	}
	
	
	
	public int getArmies() {
		return armies;
	}
	
	public boolean getAI() {
		return isAI;
	}
	
    
	public void decrementArmies(int numArmies) {
	
		armies = armies - numArmies;
		System.out.println(name + " has " + armies + " reinforcements remaining.");
    }

    /**
     * Increases the count of the number of numArmies the player has on the board
     **/
    public void incrementArmies(int numArmies) {
	
		armies = armies + numArmies;
		System.out.println(name + " has gained " + numArmies + " reinforcements. Total available: " + armies);
    }

    /**
     * that keeps track of all the countries the player occupies
     **/
    public void addCountry(Country country) {
	
		System.out.println(name + " now occupies " + country.getName() + "!");
		countriesHeld.put(country.getName(), country);
    }

    /**
     * Works like addCountry above, but can be used to add multiple countries at once
     **/
    public void addCountry(ArrayList<Country> countriesList) {
	
		for(int i = 0; i < countriesList.size(); i++) {
		
			countriesHeld.put(countriesList.get(i).getName(), countriesList.get(i));
		}
    }

    /**
     
     * tracking which countries the player occupies
     **/
    public void removeCountry(String countryName) {
		
		System.out.println(name + " no longer occupies " + countryName + "!");
		countriesHeld.remove(countryName);
    }

    /**
     
     * a data structure that tracks which continents the player occupies
     **/
    public void addContinent(Continent continent) {
	
		System.out.println(name + " controls " + continent.getName() + ", granting them " + continent.getBonusArmies() + " per turn!");
		continentsHeld.put(continent.getName(), continent);
    }

    /**
     * Adds a risk card hand
     **/
    public void addRiskCard(Card riskCard) {
	
		hand.add(riskCard);
    }
    
    /**
     * Removed a set of risk cards from the players hand to reflect risk cards being turned in
     **/
    public void removeCards(int[] cardsTurnedIn) {
	
		hand.removeCardsFromHand(cardsTurnedIn[0], cardsTurnedIn[1], cardsTurnedIn[2]);
    }
    
    public int getTurnInCount() {
    	
		turnInCount++;
		return turnInCount;
	}
	
	public ArrayList<Country> getOwnedCountries() {
	
		return new ArrayList<Country>(countriesHeld.values());
	}
    /**
     * Removes a contient from the data structure to reflect that the player no longer controls
     * it
     **/
    public void removeContinent(String continentName) {
	
		continentsHeld.remove(continentName);
    }

	public Hand getHandObject() {
		
		return hand;
	}
	
	
	public boolean mustTurnInCards() {
	
		return hand.mustTurnInCards();
	}
	public ArrayList<Card> getHand() {
		
		return hand.getCards();
	}
}