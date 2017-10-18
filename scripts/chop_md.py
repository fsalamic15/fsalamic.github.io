"""This script converts a markdown file into folders and files that 
play nice with the e-guide template"""
import os
import re
from sys import argv

def markdown_to_eguide(markdown):
    """This function does the conversion from markdown to eguide _pages"""
    with open(markdown, "rt") as mdFile:
        LINES = mdFile.read().split("\n")
        # Regular expressions to match headings, sub headings and sub sub headings
        HEADING_PATTERN = re.compile('^(# )')
        SUBHEADING_PATTERN = re.compile('^(## )')
        SUBSUBHEADING_PATTERN = re.compile('^(### )')
        PAGES = "./_pages"
        if not os.path.exists(PAGES):
            os.makedirs(PAGES)
        for lineIndex in range(len(LINES)):
            line = LINES[lineIndex]
            # If it is the heading,
            # make a folder with the same name as heading
            # make a file with the same name as heading
            if HEADING_PATTERN.match(line):
                dirName = line[2:]
                fileName = dirName + ".md"
                mainFile = open(PAGES+"/"+fileName, "w")
                mainFile.write("---\n")
                mainFile.write("title: " + dirName + "\n")
                mainFile.write("navtitle: " + dirName +"\n")
                mainFile.write("---\n")
                # mainFile.write(line + "\n")
                if not os.path.exists(PAGES+"/"+dirName):
                    os.makedirs(PAGES+"/"+dirName)
                lineIndex += 1
                line = LINES[lineIndex]
                # Iterate over the text in the section description and add it to the new md file
                while not HEADING_PATTERN.match(line) and not SUBHEADING_PATTERN.match(line):
                    mainFile.write(line+ "\n")
                    if lineIndex < len(LINES):
                        lineIndex += 1
                        line = LINES[lineIndex]
                    else:
                        break
            # Inside each of the folders make md files for each of the
            # subsections and fill in content
            if SUBHEADING_PATTERN.match(line):
                subFileName = line[3:]
                subFile = open(PAGES+"/"+dirName + "/" + subFileName + ".md", "w")
                subFile.write("---\n")
                subFile.write("title: " + dirName + "\n")
                subFile.write("navtitle: " + subFileName +"\n")
                subFile.write("---\n")
                subFile.write(line + "\n")
                lineIndex += 1
                if lineIndex < len(LINES):
                    line = LINES[lineIndex]
                    while not HEADING_PATTERN.match(line) and not SUBHEADING_PATTERN.match(line):
                        subFile.write(line +"\n")
                        if SUBSUBHEADING_PATTERN.match(line):
                            subFile.write("---\n")
                        lineIndex += 1
                        if lineIndex < len(LINES):
                            line = LINES[lineIndex]
                        else:
                            break
                else:
                    break
    mdFile.close()

if __name__ == '__main__':
    markdown_to_eguide(argv[1])
