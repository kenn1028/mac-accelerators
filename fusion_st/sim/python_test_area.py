import numpy as np

NUMBER_OF_TEST_CASES = 10
activations = []
weights = [103, -94, -106, -79, 117, 107, 50, 6, -11, -33]
activations_4b = []
weights_4b = []
activations_2b = [[0, 2, 2, 0], [2, 1, 2, 3], [3, 3, 0, 0], [2, 2, 1, 0], [2, 2, 2, 2], [1, 2, 1, 1], [2, 2, 2, 3], [1, 3, 2, 2], [2, 0, 3, 1], [2, 2, 2, 2]]
weights_2b = []

def bitfusion_mult(activations:list, weights:list, mode):
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
                print("Multiplying: ", activations[i], weights[j], "=", (activations[i]*weights[j]))
                product.append(activations[i]*weights[j])
    print("Done:")
    return product

sum4bx8b = [[0, 0]] # 2 parallel MACs
sum8bx4b = [[0, 0]]

sum2bx8b = [[0, 0, 0, 0]] # 4 parallel MACs
sum8bx2b = [[0, 0, 0, 0]]

sum2bx4b = [[0, 0, 0, 0, 0, 0, 0, 0]] # 8 parallel MACs
sum4bx2b = [[0, 0, 0, 0, 0, 0, 0, 0]]

for i in range(NUMBER_OF_TEST_CASES):
    # # (Asymmetric) Perform 4bx8b MAC with 4b and 8b Lists
    # curr_prod4bx8b = bitfusion_mult(activations_4b[i],  [weights[i]], '4bx8b')
    # sum4bx8b.append(np.add(sum4bx8b[i], curr_prod4bx8b).tolist())
    # # Perform 8bx4b MAC with 4b and 8b Lists
    # curr_prod8bx4b = bitfusion_mult([activations[i]],  weights_4b[i], '8bx4b')
    # sum8bx4b.append(np.add(sum8bx4b[i], curr_prod8bx4b).tolist())           

    # Perform 2bx8b MAC with 8b and 2b Lists
    curr_prod2bx8b = bitfusion_mult(activations_2b[i],  [weights[i]], '2bx8b')
    # test = np.add(sum2bx8b[i], curr_prod2bx8b).tolist()
    sum2bx8b.append(np.add(sum2bx8b[i], curr_prod2bx8b).tolist())    
    # # Perform 8bx2b MAC with 8b and 2b Lists

    # curr_prod8bx2b = bitfusion_mult([activations[i]],  weights_2b[i], '8bx2b')
    # sum8bx2b.append(np.add(sum8bx2b[i], curr_prod8bx2b).tolist())

    # # Perform 2bx4b MAC with 4b and 2b Lists
    # curr_prod2bx4b = bitfusion_mult(activations_2b[i],  weights_4b[i], '2bx4b')
    # sum2bx4b.append(np.add(sum2bx4b[i], curr_prod2bx4b).tolist())    
    # # Perform 4bx2b MAC with 4b and 2b Lists
    # curr_prod4bx2b = bitfusion_mult(activations_4b[i],  weights_2b[i], '4bx2b')
    # sum4bx2b.append(np.add(sum4bx2b[i], curr_prod4bx2b).tolist())

for i in range(NUMBER_OF_TEST_CASES + 1):
    sum2bx8b[i] = sum(sum2bx8b[i])

# print("Sum 4bx8b: ", sum4bx8b, '\n')
# print("Sum 8bx4b: ", sum8bx4b, '\n')

print("Sum 2bx8b: ", sum2bx8b, '\n')
# print("Sum 8bx2b: ", sum8bx2b, '\n')

# print("Sum 2bx4b: ", sum2bx4b, '\n')
# print("Sum 4bx2b: ", sum4bx2b)    