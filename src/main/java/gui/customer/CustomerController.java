package gui.customer;

import javafx.beans.value.ObservableValueBase;
import javafx.collections.FXCollections;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import utility.Database;
import utility.ErrorAlert;
import utility.Paczka;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;
import java.util.Scanner;

public class CustomerController implements Initializable {
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
    public TableView<Paczka> tableView;
    public TableColumn<Paczka, String> idColumn;
    public TableColumn<Paczka, String> nadawcaColumn;
    public TableColumn<Paczka, String> odbiorcaColumn;
    public TableColumn<Paczka, String> klasaColumn;
    public TableColumn<Paczka, String> opisColumn;
    public TableColumn<Paczka, String> stanColumn;

    public List<Paczka> listaPaczek;
    public Label stanLabel;
    public Label typLabel;
    public TextField xTypField;
    public TextField yTypField;
    public TextField zTypField;

    private int current_ID;

    {
        idColumn = new TableColumn<>("ID");
        idColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return String.valueOf(p.getValue().id);
            }
        });
        idColumn.setPrefWidth(10);
        idColumn.sortableProperty().setValue(false);
    }

    {
        nadawcaColumn = new TableColumn<>("Nadawca");
        nadawcaColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().nadawca;
            }
        });
        nadawcaColumn.setPrefWidth(50);
        nadawcaColumn.sortableProperty().setValue(false);
    }

    {
        odbiorcaColumn = new TableColumn<>("Odbiorca");
        odbiorcaColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().odbiorca;
            }
        });
        odbiorcaColumn.setPrefWidth(50);
        odbiorcaColumn.sortableProperty().setValue(false);
    }

    {
        klasaColumn = new TableColumn<>("Klasa");
        klasaColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().klasa;
            }
        });
        klasaColumn.setPrefWidth(20);
        klasaColumn.sortableProperty().setValue(false);
    }

    {
        opisColumn = new TableColumn<>("Opis");
        opisColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().opis;
            }
        });
        opisColumn.setPrefWidth(50);
        opisColumn.sortableProperty().setValue(false);
    }

    {
        stanColumn = new TableColumn<>("Stan");
        stanColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().stan;
            }
        });
        stanColumn.setPrefWidth(50);
        stanColumn.sortableProperty().setValue(false);
    }

    public void loadID() {
        try {
            current_ID = Integer.parseInt(idField.getText());
        } catch(NumberFormatException e){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        Scanner scanner = Database.query(
                "select nazwa, numer_telefonu, email from klienci where id_klienta = " + current_ID);
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
        refreshTableView();
    }

    public void refreshTableView() {
        listaPaczek = new ArrayList<>();
        int N = Integer.parseInt(Database.getSingleResult
                ("select count(*) from paczki where id_nadawcy = " + current_ID + " or id_odbiorcy = " + current_ID).strip());
        Scanner scanner = Database.query("select * from get_moje_paczki_klient(" + current_ID +")");
        scanner.nextLine();
        scanner.nextLine();
//        while(scanner.hasNext())    System.out.println(scanner.nextLine());
        for(int i=0;i<N;i++){
            listaPaczek.add(new Paczka(scanner));
        }
        tableView.setItems(null); //forcing refresh
        tableView.setItems(FXCollections.observableList(listaPaczek));
    }

    public void createKlient() {
        String nazwa = newKlientNazwaField.getText();
        String numer = newKlientNumerField.getText();
        String email = newKlientEmailField.getText();
        if(numer.isEmpty() && email.isEmpty()){
            newLabelMessage.setText("Numer lub email musi zostać podany");
            return;
        }
        if(!ErrorAlert.checkString( nazwa ))return;
        if(!ErrorAlert.checkString( numer ))return;
        if(!ErrorAlert.checkString( email ))return;
        nazwa = "'" + nazwa + "'";
        if(numer.isEmpty()) numer = "null";
        else numer = "'" + numer + "'";
        if(email.isEmpty()) email = "null";
        else email = "'" + email + "'";
        String new_id = Database.getSingleResult("select create_klient( " + nazwa + ", " + numer + ", " + email + ");");
        newLabelMessage.setText("ID klienta to: " + new_id);
    }

    public void odbierzPaczke() {
        int id_klienta = current_ID;
        int id_paczki;
        try{
            id_paczki = Integer.parseInt(odbierzIdField.getText());
        }catch (NumberFormatException e){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        String kod = odbierzKodField.getText();
        if(!ErrorAlert.checkString( kod ))  return;
        kod = "'" + kod + "'";
        Scanner scanner = Database.query(
                "select odbierz_paczke_klient( " + id_klienta + ", " + id_paczki + ", " +kod + ");");
        Database.printResult(scanner);
        refreshTableView();
    }

    public void nadajPaczke() {
        int nadawca = current_ID;
        int odbiorca, paczkomat_nadania, paczkomat_odbioru, klasa, typ;
        try {
            odbiorca = Integer.parseInt(nadajOdbiorca.getText());
            paczkomat_nadania = Integer.parseInt(nadajPaczNadania.getText());
            paczkomat_odbioru = Integer.parseInt(nadajPaczOdbioru.getText());
            klasa = Integer.parseInt(nadajKlasa.getText());
            typ = Integer.parseInt(nadajTyp.getText());
        } catch(NumberFormatException e){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        String opis = nadajOpis.getText();
        if(!ErrorAlert.checkString( opis ))return;
        String new_id = Database.getSingleResult(
                "select zloz_zamowienie(" + klasa + ", " + typ + ", " + paczkomat_nadania
                + ", " + paczkomat_odbioru + ", " + nadawca + ", " + odbiorca + ", '" + opis + "');");
        odbiorLabelMessage.setText("Nadano paczke: " + new_id);
        String res = Database.getSingleResult("select wloz_paczke_klient(" + nadawca + ", " + new_id + ");");
        System.out.println(res);
        refreshTableView();
    }

    public void sprawdzStan(){
        int id;
        try{
            id = Integer.parseInt(odbierzIdField.getText());
        } catch(NumberFormatException w){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        String stan = Database.getSingleResult("select get_opis_stanu_paczki(" + id + ")").strip();
        if(stan.equals("gotowa do odbioru")){
            stanLabel.setText("Paczka " + id + "jest gotowa do odbioru\n Kod: "
                    + Database.getSingleResult("select hasz from hasze where id_paczki = " + id));
        }
        else    stanLabel.setText("Stan paczki " + id + ": " + stan);
    }

    public void obliczCene() {
        int typ,klasa;
        try {
            typ = Integer.parseInt(nadajTyp.getText());
            klasa = Integer.parseInt(nadajKlasa.getText());
        }catch(NumberFormatException e){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        String cena = Database.getSingleResult(
                "select cena from cena_klasa_typ where id_typu = " + typ + " and id_klasy = " + klasa + ";");
        cenaLabel.setText(cena);
    }

    public void ustalTyp() {
        int x,y,z;
        try {
            x = Integer.parseInt(xTypField.getText());
            y = Integer.parseInt(yTypField.getText());
            z = Integer.parseInt(zTypField.getText());
        }catch (NumberFormatException e){
            ErrorAlert.showErrorAlert("Pole musi zawierać liczbę");
            return;
        }
        String typy = Database.getSingleResult("select znajdz_pasujace_paczki("+x+","+y+","+z+");");
        if(typy.equals(" {}"))typy="brak";
        typLabel.setText("Możliwe typy: "+typy);
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        nazwaLabel.setText("");
        numerLabel.setText("");
        emailLabel.setText("");
        //noinspection unchecked
        tableView.getColumns().addAll(idColumn, nadawcaColumn, odbiorcaColumn, klasaColumn, opisColumn, stanColumn);
    }
}
