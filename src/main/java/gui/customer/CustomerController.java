package gui.customer;

import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import utility.Database;

import java.util.Scanner;

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

    private int current_ID;

    public void loadID() {
        current_ID = Integer.parseInt(idField.getText());
        Database.query("select nazwa, numer_telefonu, email from klienci where id_klienta = " + current_ID);
        Scanner scanner = Database.getResult();
        scanner.nextLine();
        scanner.nextLine();
        StringBuilder nazwa = new StringBuilder(scanner.next());
        String tmp = scanner.next();
        while(!tmp.equals("|")){
            nazwa.append(' ');
            nazwa.append(tmp);
            tmp = scanner.next();
        }
        String numer = scanner.next();
        if(!numer.equals("|"))  scanner.next();
        else                    numer = "Nie podany";
        String email = scanner.next();
        if(email.equals("(1"))   email = "Nie podany";
        nazwaLabel.setText(nazwa.toString());
        numerLabel.setText(numer);
        emailLabel.setText(email);
    }

    public void refreshTableView() {

    }

    public void createKlient() {
        String nazwa = newKlientNazwaField.getText();
        String numer = newKlientNumerField.getText();
        String email = newKlientEmailField.getText();
        if(numer.isEmpty() && email.isEmpty()){
            newLabelMessage.setText("Numer lub email musi zostać podany");
            return;
        }
        nazwa = "'" + nazwa + "'";
        if(numer.isEmpty()) numer = "null";
        else numer = "'" + numer + "'";
        if(email.isEmpty()) email = "null";
        else email = "'" + email + "'";
        Database.query("select create_klient( " + nazwa + ", " + numer + ", " + email + ");");
        Scanner scanner = Database.getResult();
        scanner.nextLine();
        scanner.nextLine();
        newLabelMessage.setText("ID klienta to: " + scanner.next());
    }

    public void odbierzPaczke() {

    }

    public void nadajPaczke() {

    }

    public void obliczCene() {
        int typ = Integer.parseInt(nadajTyp.getText());
        int klasa = Integer.parseInt(nadajKlasa.getText());
        Database.query("select cena from cena_klasa_typ where id_typu = " + typ + " and id_klasy = " + klasa + ";");
        Scanner scanner = Database.getResult();
        scanner.nextLine();
        scanner.nextLine();
        cenaLabel.setText(scanner.next());
    }

    public void ustalTyp() {

    }
}
