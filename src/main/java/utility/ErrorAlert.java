package utility;

import javafx.scene.control.Alert;
import javafx.stage.Modality;

import java.awt.*;

public abstract class ErrorAlert {
    public static void showErrorAlert(String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.initModality(Modality.APPLICATION_MODAL);
        alert.setContentText(message);
        Toolkit.getDefaultToolkit().beep();
        alert.show();
    }
}
