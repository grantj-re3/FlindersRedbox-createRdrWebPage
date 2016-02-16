#!/bin/sh
# notifyVoidLink.sh
#
# Copyright (c) 2016, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Information Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# PURPOSE
#
# Research Data Repository (RDR) web pages typically contain a 'More
# Information' link which points to the Handle.net URL of the metadata.
# The metadata describes the associated RDR data. Our workflow is:
# - create the new RDR web page for the dataset (with a dummy 'More
#   Information' link which points to itself)
# - get approval for the new RDR web page
# - publish the associated (ReDBox) metadata (which creates a handle URL)
# - update the RDR web page with the newly generated handle URL in the
#   'More Information' link
#
# The final step is easily forgetten particularly since the ReDBox steps
# and RDR steps are performed by two different groups. The purpose of
# this program is to notify the groups that web pages exist for which
# the 'More Information' link is not properly configured.
#
# The program is run regularly via cron. The program will not send email
# unless a 'More Information' link is found which requires attention.
#
##############################################################################
PATH=/bin:/usr/bin:/usr/local/bin; export PATH

EMAIL_SUBJECT="Data Repo: More-Info link not configured"	# CUSTOMISE
HTML_FILE_GLOB="/filepath_to_website/VHOST/rdr/*/main*html"	# CUSTOMISE

# mailx: Space separated list of destination email addresses
EMAIL_DEST_LIST="user@example.com"				# CUSTOMISE

##############################################################################
# Find HTML files with '<a href="#">' in the 'More information' link
html_file_list=`egrep -il "href=\"#\".*more info" $HTML_FILE_GLOB`

if [ $? = 0 ]; then
  # The list is populated (ie. not empty)
  url_list=`echo "$html_file_list" |
    awk '
      {
        str = gensub("^.*/VHOST/", "http://VHOST.flinders.edu.au/", 1)		# CUSTOMISE
        printf("[%d] %s\n", NR, gensub("main.*.inc.html", "", 1, str))		# CUSTOMISE
      }
    ' `
  cat <<-EO_MSG |mailx -s "$EMAIL_SUBJECT" $EMAIL_DEST_LIST
		For the Research Data Repository web page(s) below, the More Information
		hyperlink is not properly configured. That is, the link points to itself
		whereas it should point to a handle URL. Please configure it.

		$url_list

		This is an automated email. Please do not reply.
	EO_MSG
fi

