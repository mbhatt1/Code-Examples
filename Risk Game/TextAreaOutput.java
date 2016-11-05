import java.io.OutputStream;
import java.io.Serializable;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

/**
 * This is utilized in order to allow easy printing of messages on the Risk GUI.
 * @author Samip Neupane, Manish Bhatt
 **/
public class TextAreaOutput extends OutputStream implements Serializable {

    
    private StringBuilder stringBuilder = new StringBuilder();
    private JTextArea textA;
    public TextAreaOutput(JTextArea textArea) {
        this.textA = textArea;
    }
	
	
	
	public void write(int b) {
		
		
		if (b == '\n') {
			final String text = stringBuilder.toString();
			
			SwingUtilities.invokeLater(new Runnable() {
				
				public void run()
				{
					textA.append(text);
				}
            });
			
            stringBuilder.setLength(0);
        }

        stringBuilder.append((char) b);
    }
}