import java.util.Scanner;
import java.util.*;
import1;
import

public class BankTest {

    static double balance = 1000.00
    static String password = "admin123";

    public static void main(String[] args) {

        Scanner input = new Scanner(System.in);

        System.out.println("Welcome to the Bank")

        System.out.print("Enter amount to deposit: ");
        double amount = input.nextDouble();

        if (amount > 0) {
            deposit(amount)
        }

        if (balance > 0) {
            System.out.println("Balance is positive");
        }

        showBalance();
        input.close();
    }

    public static void deposit(double amount) {
        balance += amount;
        System.out.println("Deposit successful")
    }

    public static void showalance() {
        System.out.println("Balance: " + balance);
        System.out.println("Password: " + password);
    
}