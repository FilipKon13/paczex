package gui.admin;

import gui.Main;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class AdminWindow {
    private final static AdminController controller;
    private final static Stage stage = new Stage();

    static {
        FXMLLoader loader = new FXMLLoader(AdminWindow.class.getResource("admin.fxml"));
        try {
            stage.setScene(new Scene(loader.load()));
        } catch (IOException e) {
            e.printStackTrace();
        }
        controller = loader.getController();
        stage.setResizable(false);
        stage.initOwner(Main.stage);
        stage.setTitle("Admin");
    }

    public static void show(){
        stage.show();
    }
}
