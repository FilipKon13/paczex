package gui.employee;

import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import utility.Database;

import java.util.Scanner;

public class EmployeeController {

    public TextField paczZWyjmij;
    public TextField paczDoWyjmij;
    public TextField paczDoWloz;
    public Label imieLabel;
    public Label nazwiskoLabel;
    public TextField idField;

    private int current_ID;

    public void loadID(){
        current_ID = Integer.parseInt(idField.getText());
        Scanner scanner = Database.query(
                "select imie, nazwisko from pracownicy where id_pracownika = " + current_ID);
        scanner.nextLine();
        scanner.nextLine();
        imieLabel.setText(scanner.next());
        scanner.next();
        nazwiskoLabel.setText(scanner.next());
    }

    public void refreshTableView(){

    }

    public void zacznijPrzewoz(){
        Database.query("select create_przewoz( " + current_ID + ");");
    }

    public void zakonczPrzewoz(){
        Database.query("select zakoncz_przewoz( " + current_ID + ");");
    }

    public void wyjmijPaczki(){
        String idZ = paczZWyjmij.getText();
        String idDo = paczDoWyjmij.getText();

        idZ = "'" + idZ + "'";
        idDo = "'" + idDo + "'";
        Database.query("select wez_paczki_pracownik( " + current_ID + ", " + idZ + ", " + idDo +");");
    }

    public void wlozPaczki(){
        String idDo = paczDoWloz.getText();

        idDo = "'" + idDo + "'";
        Database.query("select wloz_paczki_pracownik( " + current_ID + ", " + idDo +");");
    }

}
