# This is a sample Python script.

# Press Umschalt+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.


"""
note that inline command lines such as

x = [1,2,3;4,5,6] % this is an array!

are not counted as characters or lines!
they should therefore be avoided when using this script
"""


def count_no_comments(path):
    line_counter = 0
    commented_lines_counter = 0
    empty_lines_counter = 0
    characters_counter = 0
    with open(path, "r") as file:

        for line in file:
            wordsList = line.split()
            if line.find('%') != -1:
                commented_lines_counter += 1
            elif not line.strip():
                empty_lines_counter += 1
            else:
                line_counter += 1
                characters_counter += sum(len(word) for word in wordsList)
    print("lines: ", line_counter)
    print("characters: ", characters_counter)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    print('analysis raw code:')
    count_no_comments(r'D:\\02_Studium\_bachelor_thesis\xLib\testScripts\frameworkComparisonThesis\ElaborationTestSetupSCLIPraw.m')
    print('----------')
    print('analysis code within xLib framework:')
    count_no_comments(r'D:\\02_Studium\_bachelor_thesis\xLib\testScripts\frameworkComparisonThesis\ElaborationTestSetupSCLIPxLib.m')