import random
from bitstring import BitArray
import numpy as np

############################ (I) TEST CASE GENERATION ############################

NUMBER_OF_TEST_CASES = 20
sx = "Y"
sy = "Y"

# NUMBER_OF_TEST_CASES = int(input("Please input the number of test cases: "))
print("===========================================================")
print("\nGenerating %i test cases for the input activations and weights... \n" %NUMBER_OF_TEST_CASES)
print("=========================================================== \n")


# sx = str(input("Signed Input Activations? (Y/N): "))
# sy = str(input("Signed Weights? (Y/N): "))

# Instantiate lists for the input activation and weights for writing into text and processing the products
activations = []
weights = []

# Generate random integers and append to list (for calculating the product before converting to hex)
for i in range(NUMBER_OF_TEST_CASES):
    if (sx == "Y"):
        activations.append(random.randrange(-128,127)) # Signed Activations
    else:
        activations.append(random.randrange(0,255)) # Unsigned Activations

    if (sy == "Y"):
        weights.append(random.randrange(-128,127)) # Signed Weights
    else:
        weights.append(random.randrange(0,255)) # Unsigned Weights        

################### Temporary Test Cases to Match Testbench (REMOVE AFTER) ###################
# activations = [15, 30, 42, 61, 89, 101, 124, 168, 180, 240]
# weights = [15, 75, -118, -57, 86, -107, -45, -94, -31, -16]   
# activations = [139, 81, 225, 134, 215, 26, 149, 198, 19, 101]
# weights = [-45, 91, 120, 113, 12, -66, 117, 110, 6, 37]           
######################################v#######################################################

if (sx == "Y"):
    print("(Signed) Input Activations:\n", activations)
else:
    print("(Unsigned) Input Activations:\n", activations)

if (sy == "Y"):
    print("(Signed) Input Weights:\n", weights, "\n")
else:
    print("(Unsigned) Input Weights:\n", weights, "\n")

# Generate separate lists for binary equivalent of the generated test cases
# https://stackoverflow.com/questions/12946116/twos-complement-binary-in-python
    
def tobin(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

activations_b = []
weights_b = []

for i in range(NUMBER_OF_TEST_CASES):
    activations_b.append(tobin(activations[i], 8))
    weights_b.append(tobin(weights[i], 8))

################### Temporary Test Cases to Match Testbench (REMOVE AFTER) ###################
# activations_b = ['00001111', '00011110', '00101010', '00111101', '01011001', '01100101', '01111100', '10101000', '10110100', '11110000']
# weights_b = ['00001111', '01001011', '10001010', '11000111', '01010110', '10010101', '11010011', '10100010', '11100001', '11110000']
######################################v#######################################################

print("Input Activations (Binary):\n", activations_b)
print("Input Weights (Binary):\n", weights_b)

# Create test files for the input activations and weights
a = open("test_activations.txt", "w+")
w = open("test_weights.txt", "w+")

for i in range(NUMBER_OF_TEST_CASES):
    a.write(str(activations_b[i]) + "\n")
    w.write(str(weights_b[i]) + "\n")

    # if (i != NUMBER_OF_TEST_CASES - 1):
    #     a.write(str(activations_b[i]) + "\n")
    #     w.write(str(weights_b[i]) + "\n")
    # else: # Remove newline at last test case
    #     a.write(str(activations_b[i]))
    #     w.write(str(weights_b[i]))        

a.close()
w.close()

print("\n=========================================================== \n")
print("Random Input Activation and Weight Binary Files have been generated :)")
print("\n===========================================================")

############################ (II) TEST CASE VERIFICATION AND PROCESSING ############################

# Split the generated 8-bit binary inputs into 4-bit and 2-bit inputs
activations_4b = []
weights_4b = []
activations_2b = []
weights_2b = []

for i in range(NUMBER_OF_TEST_CASES):
    # https://stackoverflow.com/questions/13673060/split-string-into-strings-by-length
    # https://stackoverflow.com/questions/42397772/converting-binary-representation-to-signed-64-bit-integer-in-python
    if  (sx == 'Y'):
        # Signed Integer Representation of Activations
        activations_4b.append( [ BitArray(bin = activations_b[i][k:k+4]).int for k in range(0, 8, 4) ])
        activations_2b.append( [ BitArray(bin = activations_b[i][k:k+2]).int for k in range(0, 8, 2) ])
    else:
        # Unsigned Integer Representation of Activations
        activations_4b.append( [ int(activations_b[i][k:k+4], 2) for k in range(0, 8, 4) ])
        activations_2b.append( [ int(activations_b[i][k:k+2], 2) for k in range(0, 8, 2) ])

    if (sy == 'Y'):
        # Signed Integer Representation of Weights
        weights_4b.append( [ BitArray(bin = weights_b[i][k:k+4]).int for k in range(0, 8, 4) ])
        weights_2b.append( [ BitArray(bin = weights_b[i][k:k+2]).int for k in range(0, 8, 2) ])
    else:
        # Unsigned Integer Representation of Weights
        weights_4b.append( [ int(weights_b[i][k:k+4], 2) for k in range(0, 8, 4) ])
        weights_2b.append( [ int(weights_b[i][k:k+2], 2) for k in range(0, 8, 2) ])

print("\n4-bit Activations:\n", activations_4b)
print("4-bit Weights:\n", weights_4b, "\n")

print("2-bit Activations:\n", activations_2b)
print("2-bit Weights:\n", weights_2b)

# MAC operation then append on text files
sum8b = [[0]]
sum4b = [[0, 0, 0, 0]]
sum2b =[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

def bitfusion_mult(activations, weights, mode):
    # For 8-bit Input Activations/Weights
    product = []

    if (mode == 4):
        # activations = [H, L], weights = [h, l],  product = [Hh, Hl, Lh, Ll]
        # Eg. [1, 14] * [4, -5] = [4, -5, 56, -70]

        # product = [activations[0]*weights[0], activations[0]*weights[1], 
        #            activations[1]*weights[0], activations[1]*weights[1],]
        
        for i in range(2):
            for j in range(2):
                product.append(activations[i]*weights[j])

        pass
    elif (mode == 2):
        # Append first the results of the HIGH-HIGH Fusion Unit with indices from activations[0:1] and weights[0:1]
        for i in range(2):
            for j in range(2):
                product.append(activations[i]*weights[j])

        # Then the results of the HIGH-LOW Fusion Unit with indices from activations[0:1] and weights[2:3]
        for i in range(2):
            for j in range(2):
                product.append(activations[i]*weights[2+j])

        # Then the results of the LOW-HIGH Fusion Unit with indices from activations[2:3] and weights[0:1]
        for i in range(2):
            for j in range(2):
                product.append(activations[2+i]*weights[j])

        # Then the results of the LOW-LOW Fusion Unit with indices from activations[2:3] and weights[2:3]
        for i in range(2):
            for j in range(2):
                product.append(activations[2+i]*weights[2+j])
        pass

    return product

for i in range(NUMBER_OF_TEST_CASES):
    # Perform MAC with 8b List
    curr_prod8b = np.multiply(activations[i],  weights[i]).tolist()
    sum8b.append(np.add(sum8b[i], curr_prod8b).tolist())

    # Perform MAC with 4b List    
    curr_prod4b = bitfusion_mult(activations_4b[i],  weights_4b[i], 4)
    sum4b.append(np.add(sum4b[i], curr_prod4b).tolist())

    # Perform MAC with 2b List
    curr_prod2b = bitfusion_mult(activations_2b[i],  weights_2b[i], 2)
    sum2b.append(np.add(sum2b[i], curr_prod2b).tolist())    
    
# Convert sum lists into their hex equivalent
# https://stackoverflow.com/questions/12638408/decorating-hex-function-to-pad-zeros (used the implementation from karelv)
# https://stackoverflow.com/questions/7822956/how-to-convert-negative-integer-value-to-hex-in-python

def tohex(val, nbits): 
  return '{:0{}x}'.format(val & ((1 << nbits)-1), int((nbits+3)/4))
#   return hex((val + (1 << nbits)) % (1 << nbits))[2:].zfill(nbits) #slice '0x' and fill leading '0's

def sum_tohex_writefile(filename:str, sum, NUMBER_OF_TEST_CASES, MODE):
    sum_file = open(filename, "w+")
    PADDING = "0"

    if (MODE == 8):
        NUMBER_OF_PRODUCTS = 1
        sum_bitwidth = 20
        # PADDING = "000000000000000000000000000"
    elif (MODE == 4):
        NUMBER_OF_PRODUCTS = 4
        sum_bitwidth = 12
        # PADDING = "00000000000000000000"
    elif (MODE == 2):
        NUMBER_OF_PRODUCTS = 16
        sum_bitwidth = 8

    for i in range(NUMBER_OF_TEST_CASES+1): # Add 1 to consider the 0 index where sum is reset
        sum_hex = ""

        for j in range(NUMBER_OF_PRODUCTS):
            sum_hex = sum_hex + str(tohex(sum[i][j], sum_bitwidth)) 

            if (j == (NUMBER_OF_PRODUCTS-1)):
                if (MODE == 8 or MODE == 4):
                    sum_file.write((PADDING*(sum_bitwidth - len(sum_hex))) + sum_hex + "\n")
                else:
                    sum_file.write(sum_hex + "\n") 

                # if (i == NUMBER_OF_TEST_CASES):
                #     if (MODE == 8 or MODE == 4):
                #         # Add leading 0's for 8b and 4b mode since sum is a 128-bit register
                #         sum_file.write(PADDING + sum_hex)
                #     else:
                #         # Don't add newline for last testcase
                #         sum_file.write(sum_hex) 
                # else:
                #     if (MODE == 8 or MODE == 4):
                #         sum_file.write(PADDING + sum_hex + "\n")
                #     else:
                #         sum_file.write(sum_hex + "\n") 

    sum_file.close()

# Generate text files for the step-by-step MAC Operations of sum hex values for validation from simulation outputs
sum_tohex_writefile("sum8b_python.txt", sum8b, NUMBER_OF_TEST_CASES, 8)
sum_tohex_writefile("sum4b_python.txt", sum4b, NUMBER_OF_TEST_CASES, 4)
sum_tohex_writefile("sum2b_python.txt", sum2b, NUMBER_OF_TEST_CASES, 2)

print("\n=========================================================== \n")
print("Output Buffer (sum) Verification Hex Files have been generated :)")
print("\n=========================================================== \n")
