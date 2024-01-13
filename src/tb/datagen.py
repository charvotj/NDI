def main():
    # generate_nbit(4)
    generate_nbit(16, 12)

    # number € <-128, 127.99609375> for n=16
    # tc_au_001 - Correct arithmetic operations
    tc_au_001 = [
        [0.01171875, 0.5, 'REQ_AAU_F_012'],     # Number rounding
        [0.01171875, -0.5, 'REQ_AAU_F_012'],    # Number rounding
        [0.01171875, 0.25, 'REQ_AAU_F_012'],    # Number rounding
        [120.0, 90.0, 'REQ_AAU_F_013'],         # Overflow - Add, Mul overflow
        [-90.0, -100.0, 'REQ_AAU_F_013'],       # Overflow - Add undeflow, Mull overflow 
        [-100.125, 1.5, 'REQ_AAU_F_013'],       # Overflow - Mul undeflow
        [120.0, 2.0, 'REQ_AAU_F_013'],          # Overflow - Mul overflow
    ]
    generate_nbit(16,customDataset=tc_au_001,name='input-data-tc-au-001')

    # tc_spi_001 - Packet and frame format
    tc_spi_001 = [
        [15.12109375, -3.50, 'REQ_AAU_F_011'],          # sthg
    ]
    generate_nbit(16,customDataset=tc_spi_001,name='input-data-tc-spi-001')
   

    # tc_spi_002 - desc
    tc_spi_002 = [
        [15.12109375, -3.50, 'REQ_AAU_I_020'],          # Clock freq
        [100.25, -40.0, 'REQ_AAU_I_020'],          # Clock freq
        [69.421875, 1.69140625, 'REQ_AAU_I_020'],          # Clock freq
    ]
    generate_nbit(16,customDataset=tc_spi_002,name='input-data-tc-spi-002')

# Function generates data for assertion in VHDL testbench
# Desired format is fixed point number with decimal point in the middle of the bits
# Parameters:
#   n   ... number of bits for number generation, e.g. for n=4 generated nubers will be between -2 and 1.75
#   nth ... take only 2**nth element (to generate smaller dataset), default 0 (taking every number)
#       ! WARNING: function always taking the last number, does not depend on nth parameter 
def generate_nbit(n, nth=0, customDataset=None,name='default'):
    binary_numbers = [(i-(2**n)/2)*2**-(n/2) for i in range(2**n)]
    testCases = []
    if(customDataset==None):
        for i,numA in enumerate(binary_numbers):
            if(i % (2**nth) == 0 or i==(2**n)-1):
                for j,numB in enumerate(binary_numbers):
                    if(j % (2**nth) == 0 or j==(2**n)-1):
                        testCases.append(['NOT_REQ_TEST_',numA,numB,sumNums(numA,numB,n),mulNums(numA,numB,n),numA+numB,numB*numA])
    else:
        for nums in customDataset:
                testCases.append([nums[2],nums[0],nums[1],sumNums(nums[0],nums[1],n),mulNums(nums[0],nums[1],n),nums[0]+nums[1],nums[0]*nums[1]])

    fileName = ""
    if(name == 'default'):
        fileName = f"data_test_{n}_{nth}_bit"
    else:
        fileName = name
    with open(fileName+'.txt', "w") as file:
        for i in testCases:
            for ii in range(len(i)):
                file.write(f"{i[ii]}\n")

    with open(fileName+"_human.txt", "w") as file:
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