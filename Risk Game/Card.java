import java.io.Serializable;

/**
 * Allows the creation of Risk Card objects.
 * @author Manish Bhatt	
 * 
 * @date 11/31/14
 **/
public final class Card implements Serializable{

    private final String type;
    private final Country country;

    public Card( String type, Country country ) {
		this.type = type;
		this.country = country;
    }
	
	
    public String getType() {
		return type;
    }

    public Country getCountry() {
		return country;
    }
    
    public String getName() {
		return country.getName() + ", " + type;
	}

}
