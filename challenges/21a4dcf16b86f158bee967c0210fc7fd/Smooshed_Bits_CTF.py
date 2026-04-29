# Main Function
def main():
    user_input = input("Flag: ")
    if checkPassword(user_input):
        print("You found it!")
    else:
        print("Nope, try again!")

# Converts Password to Numbers
def passwordToIntArray(hex_str):
    numbers = [0] * 8
    hexBytes = hex_str.encode()
    for idx in range(8):
        numbers[idx] = (hexBytes[idx*4] << 24 |
                        hexBytes[idx*4+1] << 16 |
                        hexBytes[idx*4+2] << 8 |
                        hexBytes[idx*4+3])
    return numbers

# Checks Password
def checkPassword(password):
    if len(password) != 32:
        return False
    numbers = passwordToIntArray(password)
    return (numbers[0] == 1718378855
            and numbers[1] == 2071081846
            and numbers[2] == 1165128501
            and numbers[3] == 1600474727
            and numbers[4] == 829305651
            and numbers[5] == 1915842119
            and numbers[6] == 1601198452
            and numbers[7] == 875581053)

# Main Statement
if __name__ == "__main__":
    main()