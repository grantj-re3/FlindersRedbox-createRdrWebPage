FlindersRedbox-createRdrWebPage
===============================

Purpose
-------
There is a requirement at many universities to store research data
(ie. datasets) in a repository. Research data can be stored in files,
databases, triplestores, etc. however this tool focusses on file
storage only. The purpose of this command line tool is to quickly
create a simple static web page for research data (and associated
information) stored in files within a folder. If you don't like some
minor feature of the created page, the intention is that you can
tweak the html file later.

Application environment
-----------------------
Read the INSTALL file.

Installation
------------
Read the INSTALL file.

Typical stakeholders
--------------------
- The dataset owner(s): The researcher(s) who collected the dataset.
- The dataset manager: The person who manages access to the dataset.
- The RDR administrator: The ICT person who administers the research
  data repository (RDR) storage and access to it.

Typical usage scenario
----------------------
The tool is very simple so is probably suitable in the following scenario:
- where the user is the RDR administrator (ie. typically not the dataset
  owner or manager or other web user)
- for use as an interim measure
- for storage of files (eg. datasets in spreadsheets, text documents, etc
  and supplementary material such as a PDF document describing spreadsheet
  columns, how the data was collected, etc).
- for use with files which are less than 2GB
- for use with a small number of datasets (say 50) since RDR administration
  involves *manually* dealing with static web pages and other web content on
  a web site
- for use with open access content (although you could control access with
  apache IP access controls, passwords and https)

Features
--------
- The script is a linux/unix command line application written in ruby.
- It creates a single web page and allows the user to:
  * enter a mandatory page title and optional page description
  * enter an optional description of each file in the current directory
- Via ruby script configuration, it allows:
  * The file name of the resulting web page to be configured (eg. index.html)
  * Use of an html template (eg. with branding/css) to:
    - display the above page title and page description
    - display the above file links with file descriptions
  * for the creation of one or more symbolic links to existing style/image/branding
    directories
- The app shall be run by the RDR administrator linux/unix user (not by a web
  user such as the dataset owner/manager).
- It shows file sizes of hyperlinked (downloadable) files.
- Since the file extension often reflects the file's purpose, hyperlinked
  files are grouped by file extension.
- User input (eg. description fields) can be entered over several lines of
  input text (which may be ultimately displayed as one or more
  automatically-wrapped lines of html).

