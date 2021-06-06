package gui.playground;

import gui.Main;
import gui.employee.EmployeeController;
import gui.employee.EmployeeWindow;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;

public class PlaygroundWindow {
    private final static PlaygroundController controller;
    private final static Stage stage = new Stage();

    static {
        FXMLLoader loader = new FXMLLoader(PlaygroundWindow.class.getResource("playground.fxml"));
        try {
            stage.setScene(new Scene(loader.load()));
        } catch (IOException e) {
            e.printStackTrace();
        }
        controller = loader.getController();
        stage.setResizable(false);
        stage.initOwner(Main.stage);
        stage.setTitle("Playground");
    }

    public static void show(){
        stage.show();
    }
}
