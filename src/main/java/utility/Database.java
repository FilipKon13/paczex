package utility;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

public final class Database {
    private static String mainCommand = "wsl psql --dbname=\"filip\" --username=\"filip\"";

    public static void query(String command){
        System.out.println(mainCommand + " --command=\"" + command + "\" > tmp.txt");
        try {
            Runtime.getRuntime().exec(mainCommand + " --command=\"" + command + "\" > tmp.txt");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static Scanner getResult() {
        try {
            return new Scanner(new File("tmp.txt"));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void load(String command){
        mainCommand = command;
    }
}
