package utility;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Scanner;

public final class Database {
    private static String mainCommand = "wsl psql --dbname=\"filip\" --username=\"filip\"";

    public static Scanner query(String command){
        System.out.println(mainCommand + " --command=\"" + command + "\"");
        Process process = null;
        try {
            process = Runtime.getRuntime().exec(mainCommand + " --command=\"" + command + "\"");
            Scanner error = new Scanner(new InputStreamReader(process.getErrorStream()));
            while(error.hasNext())  System.out.println(error.nextLine());
        } catch (IOException e) {
            e.printStackTrace();
        }
        assert process != null;
        return new Scanner(new InputStreamReader(process.getInputStream()));
    }

    public static void load(String command){
        mainCommand = command;
        try { //clearing
            //wsl psql --dbname="rafi" --username="rafi"
            //added paczex/ to path you might want to change that
            System.out.println(mainCommand + " < src/main/java/database/clear.sql");
            Process process = Runtime.getRuntime().exec(mainCommand + " < src/main/java/database/clear.sql");
            Scanner cin = new Scanner(new InputStreamReader(process.getErrorStream()));
            while(cin.hasNext())    System.out.println(cin.nextLine());
            //creating
            System.out.println(mainCommand + " < src/main/java/database/create.sql");
            process = Runtime.getRuntime().exec(mainCommand + " < src/main/java/database/create.sql");
            cin = new Scanner(new InputStreamReader(process.getErrorStream()));
            while(cin.hasNext())    System.out.println(cin.nextLine());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void printResult(Scanner scanner){
        while(scanner.hasNext())    System.out.println(scanner.nextLine());
    }

    public static String getSingleResult(String command){
        Scanner scanner = query(command);
        scanner.nextLine();
        scanner.nextLine();
        return scanner.nextLine();
    }
}
