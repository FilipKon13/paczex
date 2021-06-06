package gui.customer;

import javafx.event.ActionEvent;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import utility.Database;

public class CustomerController {
    public TextField idField;
    public Label nazwaLabel;
    public Label numerLabel;
    public Label emailLabel;
    public TextField newKlientNazwaField;
    public TextField newKlientNumerField;
    public TextField newKlientEmailField;
    public TextField odbierzIdField;
    public TextField odbierzKodField;
    public TextField nadajPaczNadania;
    public TextField nadajPaczOdbioru;
    public TextField nadajKlasa;
    public TextField nadajTyp;
    public TextField nadajOdbiorca;
    public Label odbiorLabelMessage;
    public Label newLabelMessage;
    public TextField nadajOpis;
    public Label cenaLabel;

    public void loadID() {
        int ID = Integer.parseInt(idField.getText());
        Database.query("select * from klienci where id_klienta = " + ID);
    }

    public void refreshTableView() {

    }

    public void createKlient() {

    }

    public void odbierzPaczke() {

    }

    public void nadajPaczke() {

    }

    public void obliczCene() {

    }

    public void ustalTyp() {

    }
}
