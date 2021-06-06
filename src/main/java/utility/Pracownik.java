package utility;

import java.util.Scanner;

public class Pracownik {
    public int id;
    public String imie;
    public String nazwisko;

    public Pracownik(int id){
        this.id = id;
        Scanner scanner = Database.query("select imie, nazwisko from pracownicy where id = " + id);
        scanner.nextLine();
        scanner.nextLine();
        imie = scanner.next();
        nazwisko = scanner.next();
    }

    public Pracownik(int id, String imie, String nazwisko){
        this.id = id;
        this.imie = imie;
        this.nazwisko = nazwisko;
    }
}
