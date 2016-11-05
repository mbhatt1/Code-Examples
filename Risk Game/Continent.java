import java.io.Serializable;
import java.util.ArrayList;

/**
 * Allows the creation of Risk Continent objects.
 * @author Samip Neupane, Manish Bhatt
 * @date 11/30/2014
 **/
public class Continent implements Serializable {

    private String name;
    private int bonusArmies;
    private ArrayList<Country> countries;

    
    public Continent(String name, int bonusArmies, ArrayList<Country> memberCountries) {
		this.name = name;
		this.bonusArmies = bonusArmies;
		countries = memberCountries;
		
		System.out.println("Created continent: " + name + "\nBonus armies: " + bonusArmies);
    }

    public String getName() {
		return name;
    }

    /**
     *  Returns the number of bonus armies a player gets per round when the player controls this
     * continent
     **/
    public int getBonusArmies() {
		return bonusArmies;
    }

    /**
     * Retuens a list of the country objects that are on this continent
     **/
    public ArrayList<Country> getMemberCountries() {
		return countries;
    }
}
