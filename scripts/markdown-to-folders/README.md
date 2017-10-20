
# Word > Markdown > Folders

This document outlines the steps to convert a large word file into smaller markdown files organized in a folder structure.

If you have a word file .docx follow steps 1 and 2. If you already have a markdown file but want it to be broken down into folders and files then just follow step 2 
This is a simple python script that breaks down a large markdown file into sectional folders and subfolders and adds the content into smaller .md files, which follows the e-guide structure for page organization. 

## System Requirements

- [Python 2.x](https://www.python.org/downloads/)
- [Ruby 2.x (Step 1)](https://rubyinstaller.org/downloads/)
- [LibreOffice (Step 1)](https://www.libreoffice.org)

## Process

### Step 1 - Word to Markdown

There are many open source tools that convert word to markdown, we use this one: [word-to-markdown](https://github.com/benbalter/word-to-markdown).

1. After a successful installation of LibreOffice and Ruby open up the command prompt/terminal and install the word-to-markdown package.

```shell
gem install word-to-markdown
```

1. Now run in the command prompt/terminal:

```shell
w2m myfile.docx > myNewMdFile.md
```

This creates a new file called myNewMdFile.md with the content converted to markdown.
>Note: Make sure that your word file isn't too complicated, otherwise the parts of markdown get rendered incorrectly. Follow the guidelines described in this [sample document](./Sample.docx).

### Step 2 - Markdown Breakdown

This is a simple python script that breaks down a large markdown file into sectional folders and subfolders and adds the content into smaller .md files, which follows the e-guide structure for page organization.
To run the script:

```shell
python chop_md.py myNewMdFile.md
```

This creates an _pages directory whcih you can use to replace your original _pages (in the parent directory)

