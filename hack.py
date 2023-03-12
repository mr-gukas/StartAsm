import random

def generate_sequence(length):
    return ''.join([chr(random.randint(33, 127)) for i in range(length)])

def encode_sequence(sequence):
    return sum(((ord(c) >> 1) << 2) ^ 21 for c in sequence)

flag = 0
#sequence = gV-SeJlDu<=."
sequence_length = 1
while True:
    for i in range(1000):
        sequence = generate_sequence(sequence_length)
        encoded_sum = encode_sequence(sequence)
        if encoded_sum == 1993:
            print(sequence)
            flag = 1
            break
    if flag == 1:
        break
    sequence_length += 1
