FlindersRedbox-createRdrWebPage
===============================

Purpose
-------
There is a requirement at many universities to store research data
(ie. datasets) in a repository. Research data can be stored in files,
databases, triplestores, etc. however this tool focusses on file
storage only. The purpose of this command line tool is to quickly
create a simple static web page for research data (and associated
information) stored in files within a folder. If you don't like the
created page, the intention is that you tweak the html file later.

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
- for use as an interim measure
- for storage of files (eg. datasets in spreadsheets, text documents, etc
  and supplementary material such as a PDF document describing spreadsheet
  columns, how the data was collected, etc).
- for use with files which are less than 2GB
- for use with a small number of datasets (say 50) since RDR administration
  involves *manually* dealing with static web pages and other web content on
  a web site
- for use with open access content (although you could apache IP access control,
  passwords and https to control access)
- where the user is the RDR administrator (ie. typically not the dataset
  owner or manager)

Features
--------
- The script is a linux/unix command line application (written in ruby).
- It creates a single web page (typically index.html) with hyperlinks to most
  other files within the same directory/folder.
- The app shall be run by the RDR administrator (not by web user or dataset
  owner/manager).
- It allows web page branding (via an html-template).
- It shows file sizes of hyperlinked (downloadable) files.
- Since the file extension often reflects the file's purpose, hyperlinked
  files are grouped by file extension.

