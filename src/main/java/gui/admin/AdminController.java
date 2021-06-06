package gui.admin;

import javafx.beans.value.ObservableValueBase;
import javafx.collections.FXCollections;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import utility.Database;
import utility.Pracownik;

import java.net.URL;
import java.util.*;

public class AdminController implements Initializable {

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
    public TableView<Pracownik> tableView;
    public TableColumn<Pracownik, String> idColumn;
    public TableColumn<Pracownik, String> imieColumn;
    public TableColumn<Pracownik, String> nazwiskoColumn;

    public List<Pracownik> listaPlac;

    {
        idColumn = new TableColumn<>("ID");
        idColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return String.valueOf(p.getValue().id);
            }
        });
        idColumn.setPrefWidth(30);
        idColumn.sortableProperty().setValue(false);
    }

    {
        imieColumn = new TableColumn<>("Imię");
        imieColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().imie;
            }
        });
        imieColumn.setPrefWidth(100);
        imieColumn.sortableProperty().setValue(false);
    }

    {
        nazwiskoColumn = new TableColumn<>("Nazwisko");
        nazwiskoColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().nazwisko;
            }
        });
        nazwiskoColumn.setPrefWidth(100);
        nazwiskoColumn.sortableProperty().setValue(false);
    }


    public void dodajPracownika(){
        String imie = pracownikImie.getText();
        String nazwisko = pracownikNazwisko.getText();

        imie = "'" + imie + "'";
        nazwisko = "'" + nazwisko + "'";
        String id = Database.getSingleResult("select create_pracownik( " + imie + ", " + nazwisko + ");");
        pracownikLabel.setText("ID pracownika to: " + id);
        refreshTableView();
    }

    private void refreshTableView() {
        listaPlac = new ArrayList<>();
        int N = Integer.parseInt(Database.getSingleResult("select count(*) from pracownicy").strip());
        Scanner scanner = Database.query("select * from pracownicy");
        scanner.nextLine();
        scanner.nextLine();
        for(int i=0;i<N;i++){
            int id = scanner.nextInt();
            scanner.next();
            String name = scanner.next();
            scanner.next();
            String surname = scanner.next();
            listaPlac.add(new Pracownik(id,name,surname));
        }
        tableView.setItems(null);
        tableView.setItems(FXCollections.observableList(listaPlac));
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

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        refreshTableView();
        //noinspection unchecked
        tableView.getColumns().addAll(idColumn,imieColumn,nazwiskoColumn);
    }
}
