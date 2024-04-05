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

# activations = input("Please enter the input activations: ")
# weights = input("Please enter the input weights: ")
# mode = input("Please enter the precision mode: ")

def tobin(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

activations = [9, 10]
weights = [-6, -7]
mode = 4

n = -70

print(bitfusion_mult(activations, weights, mode))
print(tobin(n, 8))