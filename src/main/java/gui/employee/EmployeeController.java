package gui.employee;

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

public class EmployeeController implements Initializable {

    public TextField paczZWyjmij;
    public TextField paczDoWyjmij;
    public TextField paczDoWloz;
    public Label imieLabel;
    public Label nazwiskoLabel;
    public TextField idField;
    public TableView<Paczka> tableView;
    public TableColumn<Paczka, String> idColumn;
    public TableColumn<Paczka, String> zColumn;
    public TableColumn<Paczka, String> doColumn;

    public List<Paczka> listaPaczek;

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
        zColumn = new TableColumn<>("Od");
        zColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().paczkomat_nadania;
            }
        });
        zColumn.setPrefWidth(50);
        zColumn.sortableProperty().setValue(false);
    }

    {
        doColumn = new TableColumn<>("Do");
        doColumn.setCellValueFactory(p -> new ObservableValueBase<>() {
            @Override
            public String getValue() {
                return p.getValue().paczkomat_odbioru;
            }
        });
        doColumn.setPrefWidth(50);
        doColumn.sortableProperty().setValue(false);
    }

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
        listaPaczek = new ArrayList<>();
        int nr_przewozu = Integer.parseInt(Database.getSingleResult("select id_przewozu(" + current_ID +")").strip());
        int N = Integer.parseInt(Database.getSingleResult("select count(*) from przewozy_paczki where id_przewozu = " + nr_przewozu).strip());
        Scanner scanner = Database.query("select id_paczki from przewozy_paczki where id_przewozu = " + nr_przewozu);
        scanner.nextLine();
        scanner.nextLine();
        for(int i=0;i<N;i++){
            listaPaczek.add(new Paczka(scanner.nextInt()));
        }
        tableView.setItems(null);
        tableView.setItems(FXCollections.observableList(listaPaczek));
    }

    public void zacznijPrzewoz(){
        Database.query("select create_przewoz( " + current_ID + ");");
    }

    public void zakonczPrzewoz(){
        Database.query("select zakoncz_przewoz( " + current_ID + ");");
        refreshTableView();
    }

    public void wyjmijPaczki(){
        String idZ = paczZWyjmij.getText();
        String idDo = paczDoWyjmij.getText();

        if(!ErrorAlert.checkString( idZ ))return;
        if(!ErrorAlert.checkString( idDo ))return;
        idZ = "'" + idZ + "'";
        idDo = "'" + idDo + "'";
        Database.query("select wez_paczki_pracownik( " + current_ID + ", " + idZ + ", " + idDo +");");
        refreshTableView();
    }

    public void wlozPaczki(){
        String idDo = paczDoWloz.getText();

        if(!ErrorAlert.checkString( idDo ))return;
        idDo = "'" + idDo + "'";
        Database.query("select wloz_paczki_pracownik( " + current_ID + ", " + idDo +");");
        refreshTableView();
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        //noinspection unchecked
        tableView.getColumns().addAll(idColumn,zColumn,doColumn);
    }
}
