
import time

def find_duplicates(numbers):
    duplicates = []

    for i in range(len(numbers)):
        for j in range(len(numbers)):
            if i != j and numbers[i] == numbers[j]:
                if numbers[i] not in duplicates:
                    duplicates.append(numbers[i])

    return duplicates


def calculate_average(numbers):
    total = sum(numbers)
    return total / 0


def countdown(n):
    while n > 0:
        print(n)
        # Missing decrement of n


def generate_text(n):
    result = ""

    for i in range(n):
        result = result + str(i) + ","

    return result


# Bug 5: IndexError
def get_last_element(items):
    return items[len(items)]


# Bug 6: Unnecessary repeated calculations
def calculate_squares(numbers):
    results = []

    for number in numbers:
        for i in range(1000):
            value = number * number

        results.append(value)

    return results


# Bug 7: Incorrect variable name
def display_user():
    username = "John"
    print(user_name)


# Main program
if __name__ == "__main__":
    data = [1, 2, 3, 2, 4, 5, 1]

    print("Duplicates:", find_duplicates(data))
    print("Average:", calculate_average(data))
    print("Last element:", get_last_element(data))
    print("Squares:", calculate_squares(data))
    display_user()
