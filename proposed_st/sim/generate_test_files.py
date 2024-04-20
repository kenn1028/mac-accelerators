import random
from bitstring import BitArray
import numpy as np

############################ (I) TEST CASE GENERATION ############################

NUMBER_OF_TEST_CASES = 51
sx = "Y"
sy = "Y"
architecture = "ST"
asymmetric = "N"
baseline = "N"

# NUMBER_OF_TEST_CASES = int(input("Please input the number of test cases: "))
# sx = str(input("Signed Input Activations? (Y/N): "))
# sy = str(input("Signed Weights? (Y/N): "))
# architecture = str(input("Sum Together or Sum Apart ('ST'/'SA')?: "))
# asymetric = str(input("Generate Asymmetric (2bx4b, 8bx2b...) Verification Files? (Y/N): "))
# baseline = str(input("Generate Baseline Data-Gated Architecture Verification Files? (Y/N): "))

# print("===========================================================")
# print("\nGenerating %i test cases for the input activations and weights... \n" %NUMBER_OF_TEST_CASES)
# print("=========================================================== \n")

##### (I.a) Instantiate lists for the input activation and weights for writing into text and processing the products
activations = []
weights = []

##### (I.b) Generate random integers and append to list (for calculating the product before converting to hex)
for i in range(NUMBER_OF_TEST_CASES):
    if (sx == "Y"):
        activations.append(np.random.randint(-128,127)) # Signed Activations
    else:
        activations.append(np.random.randint(0,255)) # Unsigned Activations

    if (sy == "Y"):
        weights.append(np.random.randint(-128,127)) # Signed Weights
    else:
        weights.append(np.random.randint(0,255)) # Unsigned Weights        

################### Temporary Test Cases to Match Testbench (REMOVE AFTER) ###################
# activations = [15, 30, 42, 61, 89, 101, 124, 168, 180, 240]
# weights = [15, 75, -118, -57, 86, -107, -45, -94, -31, -16]   
# activations = [139, 81, 225, 134, 215, 26, 149, 198, 19, 101]
# weights = [-45, 91, 120, 113, 12, -66, 117, 110, 6, 37]           
######################################v#######################################################

# if (sx == "Y"):
#     print("(Signed) Input Activations:\n", activations)
# else:
#     print("(Unsigned) Input Activations:\n", activations)

# if (sy == "Y"):
#     print("(Signed) Input Weights:\n", weights, "\n")
# else:
#     print("(Unsigned) Input Weights:\n", weights, "\n")

##### (I.c) Generate separate lists for binary equivalent of the generated test cases
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

# print("Input Activations (Binary):\n", activations_b)
# print("Input Weights (Binary):\n", weights_b)

##### (I.d) Create test files for the input activations and weights
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

# print("\n=========================================================== \n")
# print("Random Input Activation and Weight Binary Files have been generated :)")
# print("\n===========================================================")

############################ (II) TEST CASE VERIFICATION AND PROCESSING ############################

##### (II.a) Split the generated 8-bit binary inputs into 4-bit and 2-bit inputs
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

# print("\n4-bit Activations:\n", activations_4b)
# print("4-bit Weights:\n", weights_4b, "\n")

# print("2-bit Activations:\n", activations_2b)
# print("2-bit Weights:\n", weights_2b)

##### (II.b) Multiplication Function based on BitFusion Dataflow

def bitfusion_mult(activations, weights, mode):
    # For 8-bit Input Activations/Weights
    product = []

    # activations = [H, L], weights = [h, l],  product = [Hh, Hl, Lh, Ll]
    # Eg. [1, 14] * [4, -5] = [4, -5, 56, -70]

    # product = [activations[0]*weights[0], activations[0]*weights[1], 
    #            activations[1]*weights[0], activations[1]*weights[1],]

    if (mode == '2bx2b'): # Manual ordering to match Verilog display during Sum-Apart (SA) Mode
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

    else:
        # Otherwise just iterate through each possible combination.
        for i in range(len(activations)):
            for j in range(len(weights)):
                product.append(activations[i]*weights[j])

    return product

##### (II.c) Performing the MAC operations per precision modes

# Instantiate "emptied" accumulators
sum8b = [[0]]
sum4b = [[0, 0, 0, 0]] # 4 parallel MACs
sum2b =[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # 16 parallel MACs

sum4bx8b = [[0, 0]] # 2 parallel MACs
sum8bx4b = [[0, 0]]

sum2bx8b = [[0, 0, 0, 0]] # 4 parallel MACs
sum8bx2b = [[0, 0, 0, 0]]

sum2bx4b = [[0, 0, 0, 0, 0, 0, 0, 0]] # 8 parallel MACs
sum4bx2b = [[0, 0, 0, 0, 0, 0, 0, 0]]

for i in range(NUMBER_OF_TEST_CASES):
    if (baseline == "Y"):
        # If testing the baseline data-gated architecture, MAC operation is performed only
        # on the MSB or first element of the list.
        sum8b.append([sum(sum8b[i]) + (activations[i]*weights[i])])
        sum4b.append([sum(sum4b[i]) + activations_4b[i][0]*weights_4b[i][0]])
        sum2b.append([sum(sum2b[i]) + activations_2b[i][0]*weights_2b[i][0]])
        sum4bx8b.append([sum(sum4bx8b[i]) + activations_4b[i][0]*weights[i]])
        sum8bx4b.append([sum(sum8bx4b[i]) + activations[i]*weights_4b[i][0]])
        sum2bx8b.append([sum(sum2bx8b[i]) + activations_2b[i][0]*weights[i]])
        sum8bx2b.append([sum(sum8bx2b[i]) + activations[i]*weights_2b[i][0]])
        sum2bx4b.append([sum(sum2bx4b[i]) + activations_2b[i][0]*weights_4b[i][0]])
        sum4bx2b.append([sum(sum4bx2b[i]) + activations_4b[i][0]*weights_2b[i][0]])

        # print("4-Bit Activation: ", activations_4b[i][0], "\n")
        # print("4-Bit Weight: ", weights_4b[i][0], "\n")

    else:
        # (Symmetric) Perform MAC with 8b List
        curr_prod8b = np.multiply(activations[i],  weights[i]).tolist()
        sum8b.append(np.add(sum8b[i], curr_prod8b).tolist())

        # Perform MAC with 4b List    
        curr_prod4b = bitfusion_mult(activations_4b[i],  weights_4b[i], '4bx4b')
        sum4b.append(np.add(sum4b[i], curr_prod4b).tolist())

        # Perform MAC with 2b List
        curr_prod2b = bitfusion_mult(activations_2b[i],  weights_2b[i], '2bx2b')
        sum2b.append(np.add(sum2b[i], curr_prod2b).tolist())

        # (Asymmetric) Perform 4bx8b MAC with 4b and 8b Lists
        curr_prod4bx8b = bitfusion_mult(activations_4b[i],  [weights[i]], '4bx8b')
        sum4bx8b.append(np.add(sum4bx8b[i], curr_prod4bx8b).tolist())
        
        # Perform 8bx4b MAC with 4b and 8b Lists
        curr_prod8bx4b = bitfusion_mult([activations[i]],  weights_4b[i], '8bx4b')
        sum8bx4b.append(np.add(sum8bx4b[i], curr_prod8bx4b).tolist())           

        # Perform 2bx8b MAC with 8b and 2b Lists
        curr_prod2bx8b = bitfusion_mult(activations_2b[i],  [weights[i]], '2bx8b')
        sum2bx8b.append(np.add(sum2bx8b[i], curr_prod2bx8b).tolist())    

        # Perform 8bx2b MAC with 8b and 2b Lists
        curr_prod8bx2b = bitfusion_mult([activations[i]],  weights_2b[i], '8bx2b')
        sum8bx2b.append(np.add(sum8bx2b[i], curr_prod8bx2b).tolist())

        # Perform 2bx4b MAC with 4b and 2b Lists
        curr_prod2bx4b = bitfusion_mult(activations_2b[i],  weights_4b[i], '2bx4b')
        sum2bx4b.append(np.add(sum2bx4b[i], curr_prod2bx4b).tolist())    

        # Perform 4bx2b MAC with 4b and 2b Lists
        curr_prod4bx2b = bitfusion_mult(activations_4b[i],  weights_2b[i], '4bx2b')
        sum4bx2b.append(np.add(sum4bx2b[i], curr_prod4bx2b).tolist())

# for i in range(NUMBER_OF_TEST_CASES + 1):
#     # Summing together all the asymmetric test cases
#     # Note using sum() inside the np.add(sumXbxYb[i], curr_prodWbxZb).tolist() produces weird results otherwise
#     sum2bx4b[i] = sum(sum2bx4b[i])
#     sum4bx2b[i] = sum(sum4bx2b[i])

#     sum2bx8b[i] = sum(sum2bx8b[i])
#     sum8bx2b[i] = sum(sum8bx2b[i])

#     sum4bx8b[i] = sum(sum4bx8b[i])
#     sum8bx4b[i] = sum(sum8bx4b[i])

# print("\n=========================================================== \n")

# print("Sum 8b: ", sum8b, '\n')
# print("Sum 4b: ", sum4b, '\n')
# print("Sum 2b: ", sum2b)

# if (asymmetric == "Y"):
#     print("\n=========================================================== \n")
#     print("Sum 2bx4b: ", sum2bx4b, '\n')
#     print("Sum 4bx2b: ", sum4bx2b, '\n')

#     print("Sum 2bx8b: ", sum2bx8b, '\n')
#     print("Sum 8bx2b: ", sum8bx2b, '\n')

#     print("Sum 4bx8b: ", sum4bx8b, '\n')
#     print("Sum 8bx4b: ", sum8bx4b)

##### (II.d) Convert sum lists into their hex equivalent
# https://stackoverflow.com/questions/12638408/decorating-hex-function-to-pad-zeros (used the implementation from karelv)
# https://stackoverflow.com/questions/7822956/how-to-convert-negative-integer-value-to-hex-in-python

def tohex(val, nbits): 
  return '{:0{}x}'.format(val & ((1 << nbits)-1), int((nbits+3)/4))
#   return hex((val + (1 << nbits)) % (1 << nbits))[2:].zfill(nbits) #slice '0x' and fill leading '0's

# Function for Writing the Hex File for Sum Apart (SA) Architecture
def sum_tohex_writefile_SA(filename:str, sum, NUMBER_OF_TEST_CASES, MODE):
    sum_file = open(filename, "w+")
    PADDING = "0"

    register_width = 32 # 4-bits in Hex * 32 characters = 128-bits Hex Accumulator

    if (MODE == '8bx8b'):
        NUMBER_OF_PRODUCTS = 1
        sum_bitwidth = 20
        # PADDING = "000000000000000000000000000"
    elif (MODE == '4bx4b'):
        NUMBER_OF_PRODUCTS = 4
        sum_bitwidth = 12
        # PADDING = "00000000000000000000"
    elif (MODE == '2bx2b'):
        NUMBER_OF_PRODUCTS = 16
        sum_bitwidth = 8

    for i in range(NUMBER_OF_TEST_CASES+1): # Add 1 to consider the 0 index where sum is reset
        sum_hex = ""

        for j in range(NUMBER_OF_PRODUCTS):
            sum_hex = sum_hex + str(tohex(sum[i][j], sum_bitwidth)) 

            if (j == (NUMBER_OF_PRODUCTS-1)):
                if (MODE == 8 or MODE == 4):
                    sum_file.write((PADDING*(register_width - len(sum_hex))) + sum_hex + "\n")
                else:
                    sum_file.write(sum_hex + "\n") 
                    
    sum_file.close()

# Function for Writing the Hex File for Sum Together (ST) Architecture
def sum_tohex_writefile_ST(filename:str, sum_list, NUMBER_OF_TEST_CASES, MODE):
    sum_file = open(filename, "w+")
    PADDING = "0"

    register_width = 5 # 4-bits in Hex * 5 characters = 20-bits Hex

    if (baseline == "Y"):
        # If testing the baseline data-gated architecture, bitwidth is equal to
        # One Product Width, (x_len + y_len) + 4
        if (MODE == '8bx8b'):
            sum_bitwidth = 20
        elif (MODE == '4bx4b'):
            sum_bitwidth = 12
        elif (MODE == '2bx2b'):
            sum_bitwidth = 8

        # Asymmetric
        elif (MODE == '2bx4b'):
            sum_bitwidth = 10
        elif (MODE == '2bx8b'):
            sum_bitwidth = 14
        elif (MODE == '4bx8b'):
            sum_bitwidth = 16          
    else:
        if (MODE == '8bx8b'):
            sum_bitwidth = 20
        elif (MODE == '4bx4b'):
            sum_bitwidth = 12
        elif (MODE == '2bx2b'):
            sum_bitwidth = 10

        # Asymmetric
        elif (MODE == '2bx4b'):
            sum_bitwidth = 12
        elif (MODE == '2bx8b'):
            sum_bitwidth = 14
        elif (MODE == '4bx8b'):
            sum_bitwidth = 16                

    for i in range(NUMBER_OF_TEST_CASES+1): # Add 1 to consider the 0 index where sum is reset
        if (baseline == "Y"):
            if (MODE == '2bx4b' or MODE == '2bx8b'):
                # (2b/4b)x(2b/4b) and (2b/8b)x(2b/8b) have expected sum_bitwidths that are not divisible
                # by 4 which does not translate properly in Hex, convert to Binary first then add '00' at end
                # to become divisible by 4 before changing back to Hex
                sum_bin = str(tobin(sum(sum_list[i]), sum_bitwidth) + '00')
                sum_int = BitArray(bin = sum_bin).int # Integer Representation after "Left Shifting" by 2

                sum_hex = ""
                sum_hex = sum_hex + str(tohex(sum_int, sum_bitwidth + 2))

                # If testing baseline data-gated architecture, padding is added at the LSB or start
                sum_file.write((sum_hex + PADDING*(register_width - len(sum_hex))) + "\n")                 
            else:
                sum_hex = ""
                sum_hex = sum_hex + str(tohex(sum(sum_list[i]), sum_bitwidth))

                # If testing baseline data-gated architecture, padding is added at the LSB or start
                sum_file.write((sum_hex + PADDING*(register_width - len(sum_hex))) + "\n")            
        else:
            sum_hex = ""
            sum_hex = sum_hex + str(tohex(sum(sum_list[i]), sum_bitwidth))
            sum_file.write((PADDING*(register_width - len(sum_hex))) + sum_hex + "\n")
                    
    sum_file.close()

##### (II.e) Generate text files for the step-by-step MAC Operations of sum hex values for validation from simulation outputs
if (architecture == "SA"):
    # For Sum Apart
    sum_tohex_writefile_SA("sum8b_python.txt", sum8b, NUMBER_OF_TEST_CASES, '8bx8b')
    sum_tohex_writefile_SA("sum4b_python.txt", sum4b, NUMBER_OF_TEST_CASES, '4bx4b')
    sum_tohex_writefile_SA("sum2b_python.txt", sum2b, NUMBER_OF_TEST_CASES, '2bx2b')
elif (architecture == "ST"):
    # For Sum Together
    sum_tohex_writefile_ST("sum8b_python.txt", sum8b, NUMBER_OF_TEST_CASES, '8bx8b')
    sum_tohex_writefile_ST("sum4b_python.txt", sum4b, NUMBER_OF_TEST_CASES, '4bx4b')
    sum_tohex_writefile_ST("sum2b_python.txt", sum2b, NUMBER_OF_TEST_CASES, '2bx2b')

    # For Asymmetric Operation in Original Fusion Unit (FU) only
    if (asymmetric == 'Y'):
        sum_tohex_writefile_ST("sum2bx4b_python.txt", sum2bx4b, NUMBER_OF_TEST_CASES, '2bx4b')
        sum_tohex_writefile_ST("sum4bx2b_python.txt", sum4bx2b, NUMBER_OF_TEST_CASES, '2bx4b')

        sum_tohex_writefile_ST("sum2bx8b_python.txt", sum2bx8b, NUMBER_OF_TEST_CASES, '2bx8b')
        sum_tohex_writefile_ST("sum8bx2b_python.txt", sum8bx2b, NUMBER_OF_TEST_CASES, '2bx8b')        

        sum_tohex_writefile_ST("sum4bx8b_python.txt", sum4bx8b, NUMBER_OF_TEST_CASES, '4bx8b')
        sum_tohex_writefile_ST("sum8bx4b_python.txt", sum8bx4b, NUMBER_OF_TEST_CASES, '4bx8b')

# print("\n=========================================================== \n")
# print("Output Buffer (sum) Verification Hex Files have been generated :)")
# print("\n=========================================================== \n")
