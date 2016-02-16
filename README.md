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
    * The creation of one or more symbolic links to existing style/image/branding
      directories
- The app shall be run by the RDR administrator linux/unix user (not by a web
  user such as the dataset owner/manager).
- It shows file sizes of hyperlinked (downloadable) files.
- Since the file extension often reflects the file's purpose, hyperlinked
  files are grouped by file extension.
- User input (eg. description fields) can be entered over several lines of
  input text (which may be ultimately displayed as one or more
  automatically-wrapped lines of html).

Notes
-----
 - All dataset web-pages will use the same html-template and hence have the same
   branding integrated into the static web page which is created. This means
   that changing the branding on each static page at a later time may be a long
   and tedious task if you have created many web pages using this program.
   Hence, if you wish to cleanly separate the page content from the branding,
   consider using an HTML templating system such as STEN in conjunction with
   this program. See https://github.com/grantj-re3/SimpleTemplateENgine-Sten.

Utilities
---------
- _notifyVoidLink.sh_: In a Flinders web page created by the above script,
  there is typically a 'More Information' link. The workflow requires it be
  populated during the final step, however this step is easily forgotten. The
  purpose of this program is to email interested parties that web pages
  exist for which the 'More Information' link is not properly configured.

