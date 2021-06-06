package gui.playground;

import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import utility.Database;

import java.util.Scanner;

public class PlaygroundController {
    public TextField queryField;
    public TextArea resultField;

    public void makeQuery() {
        String command = queryField.getText();
        Scanner scanner = Database.query(command);
        resultField.setText("");
        while(scanner.hasNext())    resultField.appendText(scanner.nextLine() + '\n');
    }
}
