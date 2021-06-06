package utility;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Scanner;

public final class Database {
    private static String mainCommand = "wsl psql --dbname=\"filip\" --username=\"filip\"";
    private static Scanner scanner;

    public static void query(String command){
        System.out.println(mainCommand + " --command=\"" + command + "\"");
        Process process = null;
        try {
            process = Runtime.getRuntime().exec(mainCommand + " --command=\"" + command + "\"");
        } catch (IOException e) {
            e.printStackTrace();
        }
        assert process != null;
        scanner =  new Scanner(new InputStreamReader(process.getInputStream()));
    }

    public static Scanner getResult() {
        return scanner;
    }

    public static void load(String command){
        mainCommand = command;
        try { //clearing
            System.out.println(mainCommand + " < src/main/java/database/clear.sql");
            Process process = Runtime.getRuntime().exec(mainCommand + " < src/main/java/database/clear.sql");
            Scanner cin = new Scanner(new InputStreamReader(process.getErrorStream()));
            while(cin.hasNext())    System.out.println(cin.nextLine());
            //creating
            System.out.println(mainCommand + " < ");
            process = Runtime.getRuntime().exec(mainCommand + " < src/main/java/database/create.sql");
            cin = new Scanner(new InputStreamReader(process.getInputStream()));
            while(cin.hasNext())    System.out.println(cin.nextLine());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
