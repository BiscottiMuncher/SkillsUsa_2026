def cd(ar):
    diff = []
    for i in range(0, len(ar)-1):
        diff.append(ar[i+1] - ar[i])
    return diff

def main():
    ar = [0, 0, 82, 207, 401, 638, 943, 1291, 1704, 2160, 2683, 3249, 3899, 4592, 5354, 6170, 7054]
    firstDiff = cd(ar)
    secondDiff = cd(firstDiff)

    print(ar)
    print(firstDiff)
    print(secondDiff)

main()