FlindersRedbox-createRdrWebPage
===============================

Purpose
-------
There is a requirement at many universities to store research data
(ie. datasets) in a repository. Research data can be stored in files,
databases, triplestores, etc. The purpose of this command line tool
is to quickly create a simple static web page for research data (and
associated information) stored in files within a folder.

Application environment
-----------------------
Read the INSTALL file.

Installation
------------
Read the INSTALL file.

Typical stakeholders
--------------------
- The dataset owner: The researcher who collected the dataset.
- The dataset manager: The person who manages access to the dataset.
- The RDR administrator: The ICT person who administers the repository
  storage and access to it.

Typical usage scenario
----------------------
The tool is very simple so is probably suitable in the following scenario:
- for use as an interim measure
- for storage of files (eg. datasets in spreadsheets, text documents, etc
  and supplementary material such as a PDF document describing spreadsheet
  columns, how the data was collected, etc).
- for use small-medium sized files (eg. less than 2GB)
- for use with a small number of datasets (say 50) since RDR administration
  involves manually dealing with static web pages and other web content on
  a web site
- for use with open access content (although you could apache IP access control,
  passwords and https to control access)

Features
--------
- Script is a linux/unix command line application (written in ruby).
- Creates a single web page (typically index.html) with hyperlinks to most
  other files within the same directory/folder.
- App shall be run by the RDR administrator (not by web user or dataset
  owner/manager).
- Allows web page branding (according to a web defined template).
- Shows file sizes of hyperlinked (downloadable) files.
- Since the file extension often reflects the file's purpose, hyperlinked
  files are grouped by file extension.

