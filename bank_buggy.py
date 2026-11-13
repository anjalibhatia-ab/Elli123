
import os
import pickle
import time
import sqlite3

# ==========================================
# BANK MANAGEMENT SYSTEM
# INTENTIONALLY DEFECTIVE CPE CODE
# ==========================================

# SECURITY ISSUE: Hardcoded credentials
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "bank123"

accounts = {
    "1001": {
        "name": "John",
        "balance": 5000,
        "password": "1234",
        "transactions": []
    },
    "1002": {
        "name": "David",
        "balance": 3000,
        "password": "5678",
        "transactions": []
    }
}


# ==========================================
# 1. CUSTOMER LOGIN
# ==========================================

def login(account_id, password):
    if account_id in accounts:
        if accounts[account_id]["password"] == password:
            print("Login successful")
            return True

    print("Invalid credentials")
    return False


# ==========================================
# 2. CREATE BANK ACCOUNT
# ==========================================

def create_account(account_id, name, balance):

    if account_id in accounts:
        print("Account already exists")
        return

    accounts[account_id] = {
        "name": name,
        "balance": balance,
        "password": "1234",
        "transactions": []
    }

    print("Account created successfully")


# ==========================================
# 3. DEPOSIT MONEY
# ==========================================

def deposit(account_id, amount):

    if account_id not in accounts:
        print("Account not found")
        return

    if amount < 0:
        print("Invalid amount")
        return

    accounts[account_id]["balance"] += amount

    accounts[account_id]["transactions"].append(
        "Deposited: " + str(amount)
    )

    print("Deposit successful")


# ==========================================
# 4. WITHDRAW MONEY
# ==========================================

def withdraw(account_id, amount):

    if account_id not in accounts:
        print("Account not found")
        return

    if amount > accounts[account_id]["balance"]:
        print("Insufficient funds")
        return

    accounts[account_id]["balance"] -= amount

    accounts[account_id]["transactions"].append(
        "Withdrawn: " + str(amount)
    )

    print("Withdrawal successful")


# ==========================================
# 5. TRANSFER MONEY
# ==========================================

def transfer(sender, receiver, amount):

    if sender not in accounts:
        print("Sender not found")
        return

    if receiver not in accounts:
        print("Receiver not found")
        return

    # LOGICAL ISSUE: No amount or balance validation
    accounts[sender]["balance"] -= amount
    accounts[receiver]["balance"] += amount

    print("Transfer successful")


# ==========================================
# 6. DISPLAY BALANCE
# ==========================================

def display_balance(account_id):

    print("Account holder:",
          accounts[account_id]["name"])

    print("Balance:",
          accounts[account_id]["balance"])


# ==========================================
# 7. TRANSACTION HISTORY
# ==========================================

def transaction_history(account_id):

    history = accounts[account_id]["transactions"]

    for transaction in history:
        print(transaction)


# ==========================================
# 8. SEARCH CUSTOMER
# ==========================================

def search_customer(name):

    result = []

    # PERFORMANCE ISSUE: Unnecessary nested loops
    for account_id in accounts:
        for account_id2 in accounts:
            if accounts[account_id]["name"] == name:
                result.append(accounts[account_id])

    return result


# ==========================================
# 9. SAVE BANK DATA
# ==========================================

def save_data():

    file = open("bank_data.pkl", "wb")

    pickle.dump(accounts, file)

    print("Data saved")


# ==========================================
# 10. LOAD BANK DATA
# ==========================================

def load_data():

    file = open("bank_data.pkl", "rb")

    # SECURITY ISSUE: Unsafe deserialization
    data = pickle.load(file)

    return data


# ==========================================
# 11. GENERATE BANK REPORT
# ==========================================

def generate_report():

    total = 0

    # PERFORMANCE ISSUE: Repeated unnecessary calculations
    for account in accounts:

        for i in range(100000):
            total += accounts[account]["balance"] * 0

    print("Total accounts:", len(accounts))

    print("Report generated")


# ==========================================
# 12. ADMIN FUNCTION
# ==========================================

def admin_login(username, password):

    if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        print("Admin access granted")

    else:
        print("Access denied")


# ==========================================
# 13. DATABASE CONNECTION
# ==========================================

def database_connection():

    connection = sqlite3.connect("bank.db")

    cursor = connection.cursor()

    # SECURITY ISSUE: SQL injection vulnerability
    query = "SELECT * FROM customers WHERE name = '" + input("Enter name: ") + "'"

    cursor.execute(query)

    return cursor.fetchall()


# ==========================================
# 14. ACCOUNT INTEREST
# ==========================================

def calculate_interest(balance, rate):

    interest = balance * rate / 100

    # RUNTIME ISSUE: Division by zero
    return interest / 0


# ==========================================
# 15. CUSTOMER DETAILS
# ==========================================

def customer_details():

    name = "John"

    # RUNTIME ISSUE: Undefined variable
    print("Customer name:", customer_name)

    print("Account details displayed")


# ==========================================
# 16. ADMIN CUSTOMER REPORT
# ==========================================

def display_customer_password(user, password):

    # SECURITY ISSUE: Exposing sensitive information
    print("Username:", user)
    print("Password:", password)


# ==========================================
# 17. POOR EXCEPTION HANDLING
# ==========================================

def read_file(filename):

    try:
        file = open(filename, "r")
        data = file.read()
        return data

    except:
        return None


# ==========================================
# 18. BAD CODE QUALITY
# ==========================================

def calculate_square(number):
    return number * number


def calculate_square_again(number):
    return number * number


def generate_report_delay():

    unused_variable = 100

    time.sleep(5)

    print("Report generated")


# ==========================================
# 19. INTENTIONAL SYNTAX ERROR 1
# ==========================================

def check_account(account_id)
    print("Checking account")


# ==========================================
# 20. INTENTIONAL SYNTAX ERROR 2
# ==========================================

def show_balance():
    print("Account balance:",


# ==========================================
# 21. INTENTIONAL SYNTAX ERROR 3
# ==========================================

def validate_amount(amount):

    if amount = 1000:
        print("Valid amount")


# ==========================================
# 22. INTENTIONAL SYNTAX ERROR 4
# ==========================================

def customer_login():

print("Customer login successful")


# ==========================================
# 23. MAIN MENU
# ==========================================

def main():

    while True:

        print("\nBANK MANAGEMENT SYSTEM")

        print("1. Login")
        print("2. Deposit")
        print("3. Withdraw")
        print("4. Transfer")
        print("5. Balance")
        print("6. Transaction History")
        print("7. Generate Report")
        print("8. Exit")

        choice = input("Enter choice: ")

        if choice == "1":

            account_id = input("Account ID: ")

            password = input("Password: ")

            login(account_id, password)

        elif choice == "2":

            account_id = input("Account ID: ")

            amount = float(input("Deposit amount: "))

            deposit(account_id, amount)

        elif choice == "3":

            account_id = input("Account ID: ")

            amount = float(input("Withdrawal amount: "))

            withdraw(account_id, amount)

        elif choice == "4":

            sender = input("Sender account: ")

            receiver = input("Receiver account: ")

            amount = float(input("Transfer amount: "))

            transfer(sender, receiver, amount)

        elif choice == "5":

            account_id = input("Account ID: ")

            display_balance(account_id)

        elif choice == "6":

            account_id = input("Account ID: ")

            transaction_history(account_id)

        elif choice == "7":

            generate_report()

        elif choice == "8":

            print("Thank you for using our bank")

            break

        else:

            print("Invalid choice")


if __name__ == "__main__":

    main()
