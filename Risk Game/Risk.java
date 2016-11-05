import javax.swing.JFrame;

/**
 * This class creates a model, a view, and a controller, passing the
 * model and the view to the controller.
 * @author Manish Bhatt, Samip Neupane
 
 * @date 11/28/2014
 **/
public class Risk {

	public static void main(String[] args) {
		Model model = new Model();
		View view = new View();
		Controller controller = new Controller(model, view);
	}
}