package utility;

import javax.xml.crypto.Data;
import java.util.Scanner;

public final class Paczka {
    public int id;
    public String nadawca;
    public String odbiorca;
    public String paczkomat_nadania;
    public String paczkomat_odbioru;
    public String klasa;
    public String opis;
    public String stan;

    public Paczka(int id){
        this.id = id;
        stan = getStan();
        Scanner scanner = Database.query("select * from paczki where id_paczki = " + id);
        scanner.nextLine();
        scanner.nextLine();
        scanner.next();
        scanner.next();
        scanner.next();
        scanner.next();
        klasa = Database.getSingleResult("select nazwa from klasy where id_klasy = " + scanner.next());
        scanner.next();
        paczkomat_nadania = scanner.next();
        scanner.next();
        paczkomat_odbioru = scanner.next();
        scanner.next();
        nadawca = Database.getSingleResult("select nazwa from klienci where id_klienta = " + scanner.next());
        scanner.next();
        odbiorca = Database.getSingleResult("select nazwa from klienci where id_klienta = " + scanner.next());
        scanner.next();
        opis = scanner.nextLine();
    }

    private String getStan(){
        return Database.getSingleResult("select get_opis_stanu_paczki(" + id + ")");
    }
}
