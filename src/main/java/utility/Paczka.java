package utility;

import java.util.Arrays;
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

    public Paczka(int id, String paczkomat_nadania, String paczkomat_odbioru){
        this.id = id;
        this.paczkomat_nadania = paczkomat_nadania;
        this.paczkomat_odbioru = paczkomat_odbioru;
    }

    public Paczka(Scanner scanner){
        String[] tab = scanner.nextLine().split("\\|");
        id = Integer.parseInt(tab[0].strip());
        nadawca = tab[1].strip();
        odbiorca = tab[2].strip();
        paczkomat_nadania = tab[3].strip();
        paczkomat_odbioru = tab[4].strip();
        klasa = tab[5].strip();
        opis = tab[6].strip();
        stan = tab[7].strip();
    }

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
