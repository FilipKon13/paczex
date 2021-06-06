package gui.employee;

import gui.Main;
import gui.admin.AdminWindow;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;

public class EmployeeWindow {
    private final static EmployeeController controller;
    private final static Stage stage = new Stage();

    static {
        FXMLLoader loader = new FXMLLoader(EmployeeWindow.class.getResource("employee.fxml"));
        try {
            stage.setScene(new Scene(loader.load()));
        } catch (IOException e) {
            e.printStackTrace();
        }
        controller = loader.getController();
        stage.setResizable(false);
        stage.initOwner(Main.stage);
        stage.setTitle("Employee");
    }

    public static void show(){
        stage.show();
    }
}
