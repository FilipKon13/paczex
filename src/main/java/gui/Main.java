package gui;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;
import utility.Database;

import java.util.Scanner;

public class Main extends Application {
    public static Stage stage;

    @Override
    public void start(Stage primaryStage) throws Exception{
        stage = primaryStage;
        FXMLLoader loader = new FXMLLoader(getClass().getResource("main.fxml"));
        AnchorPane root = loader.load();
        MainController controller = loader.getController();
        controller.commandLabel.setText("Enter username and database name");
        primaryStage.setTitle("Paczex");
        primaryStage.setScene(new Scene(root));
        primaryStage.setResizable(false);
        primaryStage.show();
//        Database.query("select * from tab");
//        Scanner scanner = Database.getResult(); /* test */
//        while(scanner.hasNext()) System.out.println(scanner.nextLine());
    }


    public static void main(String[] args) {
        launch(args);
    }
}
