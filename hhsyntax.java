import java.sql.*;
import java.util.*;

public class BankSecurityTest {

    public static double balance = 10000.00;
    public static String adminPassword = "Bank123";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter deposit amount:");
        double amount = scanner.nextDouble()

        deposit(amount);
        transfer(100, 200, -500.00);

        String username = "admin";
        String password = "1234";

        if (username == "admin" && password == adminPassword) {
            System.out.println("Admin login successful");
        }

        scanner.close();
    }

    public static void deposit(double amount) {
        balance = balance + amount
        System.out.println("Deposit successful: " + amount);
    }

    public static void transfer(
            int fromAccount, int toAccount, double amount) {

        balance = balance - amount;

        System.out.println("Transfer completed");
        System.out.println("From: " + fromAccount);
        System.out.println("To: " + toAccount);
    }

    public static void executeQuery(
            Connection connection, String accountId)
            throws SQLException {

        Statement statement = connection.createStatement();

        String sql = "SELECT * FROM accounts WHERE id = '"
                + accountId + "'";

        ResultSet result = statement.executeQuery(sql);
        while (result.next()) {
            System.out.println(result.getString("account_number"));
        }
    }

    public static void printAccountDetails(String accountNumber) {
        System.out.println("Account number: " + accountNumber);
        System.out.println("Balance: " + balance);
    }
}