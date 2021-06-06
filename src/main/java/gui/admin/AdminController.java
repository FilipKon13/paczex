package gui.admin;

import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import utility.Database;

import java.util.Scanner;

public class AdminController {

    public TextField zmienKlasa;
    public TextField zmienTyp;
    public TextField zmienCenaWartosc;
    public TextField pracownikImie;
    public TextField pracownikNazwisko;
    public TextField paczAddMiasto;
    public TextField paczAddUlica;
    public TextField paczDeleteId;
    public TextField rabatKlientId;
    public TextField rabatWartosc;
    public Label pracownikLabel;
    public Label paczkomatLabel;

    public void dodajPracownika(){
        String imie = pracownikImie.getText();
        String nazwisko = pracownikNazwisko.getText();

        imie = "'" + imie + "'";
        nazwisko = "'" + nazwisko + "'";
        String id = Database.getSingleResult("select create_pracownik( " + imie + ", " + nazwisko + ");");
        pracownikLabel.setText("ID pracownika to: " + id);
    }

    public void dodajPaczkomat(){
        String miasto = paczAddMiasto.getText();
        String ulica = paczAddUlica.getText();

        ulica = "'" + ulica + "'";
        miasto = "'" + miasto + "'";
        String pacz = Database.getSingleResult("select create_paczkomat( " + miasto + ", " + ulica + ");");
        paczkomatLabel.setText("ID paczkomatu to: " + pacz);
    }

    public void zdezaktywujPaczkomat(){
        String id = paczDeleteId.getText();

        id = "'" + id + "'";
        Database.query("update paczkomaty set aktywny='F'::boolean where id_paczkomatu=" + id + ";");
    }

    public void dodajRabat(){
        String klientId = rabatKlientId.getText();
        String rabat = rabatWartosc.getText();

        klientId = "'" + klientId + "'";
        rabat = "'" + rabat + "'";
        Database.query("select dodaj_rabat( " + klientId + ", " + rabat + ");");
    }

    public void zmienCene(){
        String klasa = zmienKlasa.getText();
        String typ = zmienTyp.getText();
        String cena = zmienCenaWartosc.getText();

        klasa = "'" + klasa + "'";
        typ = "'" + typ + "'";
        cena = "'" + cena + "'";
        Database.query("select zmien_cena( " + typ + ", " + klasa + ", " + cena + ");");
    }
}
