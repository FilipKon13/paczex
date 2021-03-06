package gui.customer;

import gui.Main;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class CustomerWindow {
    private final static CustomerController controller;
    private final static Stage stage = new Stage();

    static {
        FXMLLoader loader = new FXMLLoader(CustomerWindow.class.getResource("customer.fxml"));
        try {
            stage.setScene(new Scene(loader.load()));
        } catch (IOException e) {
            e.printStackTrace();
        }
        controller = loader.getController();
        stage.setResizable(false);
        stage.initOwner(Main.stage);
        stage.setTitle("Customer");
    }

    public static void show(){
        stage.show();
    }
}
