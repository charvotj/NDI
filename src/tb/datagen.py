
def main():
    generate_nbit(4)
    generate_nbit(8)

def generate_nbit(n):
    binary_numbers = [(i-(2**n)/2)*2**-(n/2) for i in range(2**n)]
    #print(type(binary_numbers[0]))
    #print(binary_numbers)
    testCases = []
    for numA in binary_numbers:
        for numB in binary_numbers:
            testCases.append([numA,numB,sumNums(numA,numB,n),mulNums(numA,numB,n)])
    #print(testCases)
    with open(f"data_test_{n}_bit.txt", "w") as file:
        for i in testCases:
            # file.write(f"{i[0]},{i[1]},{i[2]},{i[3]}\n")
            for ii in range(len(i)):
                file.write(f"{i[ii]}\n")
    with open(f"data_test_{n}_bit_human.txt", "w") as file:
        for i in testCases:
            file.write(f"{i[0]},{i[1]},{i[2]},{i[3]}\n")

def sumNums(numA:float,numB:float,n:int) -> float:
    min = (0-(2**n)/2)*2**-(n/2)
    max = ((2**n-1)-(2**n)/2)*2**-(n/2)
    sum = numA + numB
    if(sum > max):
        sum = max
    if(sum < min):
        sum = min

    return sum

def mulNums(numA:float,numB:float,n:int) -> float:
    min = (0-(2**n)/2)*2**-(n/2)
    max = ((2**n-1)-(2**n)/2)*2**-(n/2)
    mul = numA * numB
    if(mul > max):
        mul = max
    if(mul < min):
        mul = min

    factor = 2 ** (n / 2)
    floored_result = (mul * factor) // 1 / factor

    if floored_result == -0.0:
        floored_result = 0.0

    return floored_result
    
if __name__ == '__main__':
    main()