

data = ["57", "59", "5c", "5f", "61", "64", "66", "69", "6b", "6d", "6f", "71", "73", "75", "76", "78", "79", "7a", "7a", "7b", "7b", "7b", "7b", "7b", "7b", "7a", "79", "78", "77", "76", "74", "73", "71", "6f", "6d", "6a", "68", "65", "63", "60", "5e", "5b", "58", "56", "53", "50", "4e", "4b", "48", "46", "43", "41", "3f", "3d", "3b", "39", "38", "36", "35", "34", "33", "32", "32", "32", "32", "32", "32", "32", "33", "34", "35", "36", "38", "39", "3b", "3d", "3f", "41", "43", "46", "48", "4b", "4e", "50", "53", "56", "58", "5b", "5e", "60", "63", "65", "68", "6a", "6d", "6f", "71", "73", "74", "76", "77", "78", "79", "7a", "7b", "7b", "7b", "7b", "7b", "7b", "7a", "7a", "79", "78", "76", "75", "73", "71", "6f", "6d", "6b", "69", "66", "64", "61", "5f", "5c", "59", "57", "54", "51", "4e", "4c", "49", "47", "44", "42", "40", "3e", "3c", "3a", "38", "37", "35", "34", "33", "33", "32", "32", "32", "32", "32", "32", "33", "34", "35", "36", "37", "39",
        "3a", "3c", "3e", "40", "43", "45", "48", "4a", "4d", "4f", "52", "55", "57", "5a", "5d", "5f", "62", "65", "67", "6a", "6c", "6e", "70", "72", "74", "75", "77", "78", "79", "7a", "7b", "7b", "7b", "7b", "7b", "7b", "7b", "7a", "79", "78", "77", "75", "74", "72", "70", "6e", "6c", "6a", "67", "65", "62", "5f", "5d", "5a", "57", "55", "52", "4f", "4d", "4a", "48", "45", "43", "40", "3e", "3c", "3a", "39", "37", "36", "35", "34", "33", "32", "32", "32", "32", "32", "32", "33", "33", "34", "35", "37", "38", "3a", "3c", "3e", "40", "42", "44", "47", "49", "4c", "4e", "51", "54", "55", "55", "55", "55", "55", "55", "aa", "aa", "aa", "55", "55", "55", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "ff", "ff", "ff", "aa", "aa", "aa", "ff", "ff", "ff", "ff", "ff", "ff", "ff", "ff", "ff", "aa", "aa", "aa", "ff", "ff", "ff", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "aa", "55", "55", "55", "aa", "aa", "aa", "55", "55", "55", "55", "55", "55", "00"]

sin = [37, 39, 42, 45, 47, 50, 52, 55, 57, 59, 61, 63, 65, 66, 68, 69, 70, 71, 72, 72, 73, 73, 73, 73, 72, 72, 71, 70, 69, 67, 66, 64,
       62, 60, 58, 56, 53, 51, 48, 46, 43, 41, 38, 35, 32, 30, 27, 25, 22, 20, 17, 15, 13, 11, 9, 7, 6, 4, 3, 2, 1, 1, 0, 0,
       0, 0, 1, 1, 2, 3, 4, 5, 7, 8, 10, 12, 14, 16, 18, 21, 23, 26, 28, 31, 34, 37]

output = []

for value in data:

    hex = int(value, 16)
    output.append(hex)
print(output)

output = []

print()

for value in sin:
    output.append(value+50)
print(output)
