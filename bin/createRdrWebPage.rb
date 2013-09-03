#!/usr/bin/ruby
# createRdrWebPage.rb
#
# Copyright (c) 2013, Flinders University, South Australia. All rights reserved.
# Contributors: eResearch@Flinders, Library, Information Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
##############################################################################
# Purpose:
# The purpose of this script is to allow a Research Data Repository web page 
# to be quickly created. (It can be edited manually later if it is unsuitable.)
#
# The program does the following.
# - Allow user to enter mandatory page title & optional page description
# - Allow user to enter an optional description of each file in the current dir
# - Use an html template (eg. with branding/css) to:
#   * display the above page title & page description
#   * display the above file links (& file sizes) with file descriptions
# - Write the html to a file (eg. index.html)
# - Add symlinks to existing style/image/branding dirs
#
##############################################################################
require 'cgi'
require 'yaml'

##############################################################################
# Constants which are likely to change for each installation
##############################################################################
HTML_OUT_FNAME = "index.html"	# Will be written to current dir

# Create symlinks in the current dir to each of these paths. The paths are
# expected to be CSS/image dirs, but could also be files. The paths should
# be within the Apache web server DocumentRoot.
STYLE_IMAGE_DIRS = [
  # Uncomment the line below if you are using sample_styles provided
  #"../sample_styles",
]

FILE_WARN_MB = 100		# Issue warning if any file exceeds this number of MB

# An html template is a normal web page (including any branding) with
# variable content replaced with 'tags' which will be substituted by
# this program. Eg. "<!-- [[TAG_PAGE_TITLE]] -->" will be replaced
# with the title-text entered into this program by the user.
HTML_TEMPLATE = "#{ENV['HOME']}/opt/createRdrWebPage/etc/createRdrWebPage.tpl.html"

# Subheading html-element used for groups of CSV, PDF, TXT, etc files stored in current/dataset dir
HTML_ELEMENT_SUBHEADING_EXT = "<h3>"

##############################################################################
# Constants which are NOT likely to change for each installation
##############################################################################
# Within the html template file, tags of the following form shall be found
# & replaced with tag_var_pairs["MY_TAG"]:   <!-- [[MY_TAG]] -->
HTML_REPLACEMENT_TAG_REGEX1 = "<!-- \[\["
HTML_REPLACEMENT_TAG_REGEX2 = "\]\] -->"

# Constants used to build the key for the properties[] hash (when pointing
# to files in the current dir)
FILE_KEY = "FILE"
FILE_SEP = "\t"

# Define KB, MB & GB for approx file-size display for users. Generally I
# believe users prefer KB=1000 (rather than 1024).
KB_SIZE = 1000
MB_SIZE = KB_SIZE * KB_SIZE
GB_SIZE = KB_SIZE * KB_SIZE * KB_SIZE

# When this app prompts for file descriptions, it shall ignore filenames
# given in this list. This is an array of filename strings. Since we
# invoke the include() method on this array, it does not support strings
# containing either file wildcards or regular expressions.
IGNORE_FILE_LIST = [
  ".",			# Unix: current directory
  "..",			# Unix: parent directory
  ".htaccess",		# Apache directory-level configuration file
  HTML_OUT_FNAME	# The web page being created by this app
]

##############################################################################
# Extend the File built-in class
class File
  # Write the specified string to the specified file.
  def self.write_string(filename, str)
    begin
      File.open(filename, 'w').write(str)
    rescue Exception => ex
      STDERR.puts "Error writing to file: #{filename}\nPerhaps file is in use?\n#{ex}"
      exit 1
    end
  end
end  # class File

##############################################################################
# Extend the Ingeter built-in class
class Integer
  def mb_to_bytes
    self * MB_SIZE
  end

  def bytes_to_mb
    (self / MB_SIZE).round
  end
end

##############################################################################
# Check that this program will not overwrite an existing file; stop if so.
def check_for_web_page_overwrite
  if File.exist?(HTML_OUT_FNAME)
    STDERR.puts <<-OVERWRITE_EOM

      WARNING: This program will create the file '#{HTML_OUT_FNAME}',
      however this file already exists in this directory!

      1) Please check that you are running this program in the right
         directory.

      2) Otherwise, please move, rename or delete the existing file
         '#{HTML_OUT_FNAME}' before running this program again.

      Program now ending.

    OVERWRITE_EOM
    exit(1)
  end
end

##############################################################################
def show_file_size_warning(large_files)
  return if large_files.empty?
  puts <<-FILE_SIZE_WARN_EOM

    BEWARE: The following files exceed #{FILE_WARN_MB} MB.
#{large_files.join("\n").gsub(/^/, '    * ')}

    This means that users may experience difficulty downloading them from
    this web site. Also, some web servers or web browsers do not permit
    downloading of files larger than 2GB. Hence it is strongly recommended
    that files larger than 2GB not be available for download on this site.
    Solutions include:
    * zipping large files
    * dividing files into several parts
    * a combination of the above
    * do nothing (if the files are less than 2GB)
    * store large files elsewhere
  FILE_SIZE_WARN_EOM

  printf "\nPress the Enter key to continue..."
  gets.chomp.strip
end

##############################################################################
# Display a welcome message.
def welcome(file_descriptions_by_ext_by_fname)
  strings = []
  large_files = []
  file_descriptions_by_ext_by_fname.sort.each{|ext, descs|
    strings << sprintf("File extension %s:", ext=='' ? "[None]" : "'#{ext}'")
    descs.sort.each{|fname, desc|
      strings << "  #{fname}"
      bytes = File.size(fname) 
      large_files << "#{fname} (#{bytes.bytes_to_mb} MB)" if bytes > FILE_WARN_MB.mb_to_bytes
    }
  }
  show_file_size_warning(large_files)

  puts <<-WELCOME_EOM

    This program will create a BASIC WEB PAGE for a DATASET or group of 
    datasets within a web-based Research Data Repository (RDR). The 
    purpose of the page is to create hyperlinks to dataset files and related 
    files in your current directory. Hence it is expected that you will 
    populate the directory with ALL your files BEFORE running this script.
    The files in this directory (sorted by file-extension) are:

#{strings.join("\n").gsub(/^/, '      ')}

    You will be invited to enter an optional description for each file.
  WELCOME_EOM


  printf "\nPress the Enter key to continue..."
  gets.chomp.strip
end

##############################################################################
# Create a hash (initially empty) where each value is a description of
# the corresponding file within the current dir. That is:
#   file_descriptions_by_ext_by_fname[FILE_EXT][FILENAME] = DESC OF FILE
def get_file_descriptions_by_ext_by_fname
  # A hash of hashes. eg.
  # file_descriptions_by_ext_by_fname['.txt']['readme1.txt'] = "description..."
  file_descriptions_by_ext_by_fname = {}
  Dir.foreach(".") {|fname|
    next if File.directory?(fname)	# Ignore any subdirectories
    unless IGNORE_FILE_LIST.include?(fname)
      ext = File.extname(fname)
      file_descriptions_by_ext_by_fname[ext] = {} unless file_descriptions_by_ext_by_fname[ext]
      file_descriptions_by_ext_by_fname[ext][fname] = ""	# Empty description
    end
  }
  file_descriptions_by_ext_by_fname
end

##############################################################################
# Get key for the properties[] hash
def get_prop_key(ext, fname)
  "#{FILE_KEY}#{FILE_SEP}#{ext}#{FILE_SEP}#{fname}"
end

##############################################################################
# Generate properties for all of the fields where we want user input.
# Each field shall have the properties:
# - :order		# Used to sort each field
# - :long_prompt	# Initial (line 1) prompt when seeking user input
# - :short_prompt	# Prompt for lines 2,3,etc of multi-line input
# - :is_mandatory	# true=field must not be blank; false=field can be blank
# - :text		# field text (to be added later by user after issuing the above prompts)	
def generate_content_properties(file_descriptions_by_ext_by_fname)
  # Assign properties for fields which correspond to the web-page as a whole
  properties = {
    "TAG_PAGE_TITLE" => {
      :order		=> 100,
      :long_prompt	=> "Enter a title for this web page (which will list your research data)",
      :short_prompt	=> "Title",
      :is_mandatory	=> true,
    },

    "TAG_PAGE_DESCRIPTION" => {
      :order		=> 200,
      :long_prompt	=> "Enter a description for this web page (which will list your research data)",
      :short_prompt	=> "Page description",
      :is_mandatory	=> false,
    },
  }

  # Generate properties for each file
  order = 5000
  file_descriptions_by_ext_by_fname.sort.each{|ext, descs|
    descs.sort.each{|fname, desc|
      order += 1
      key = get_prop_key(ext, fname)
      properties[key] = {}	# Create a new sub-hash for properties for this file
      properties[key][:order] = order
      properties[key][:long_prompt] = "Enter a description for file '#{fname}'"
      properties[key][:short_prompt] = "'#{fname}' description"
      properties[key][:is_mandatory] = false
    }
  }
  properties
end

##############################################################################
# Get multiline input from user for each field (based on properties[])
def get_user_input(properties)
  field_terminator = '.'
  field_term_msg = "End multi-line info with a '#{field_terminator}' on a line by itself"

  properties.sort{|a,b| a[1][:order] <=> b[1][:order]}.each{|tag,prop|
    mand_text = prop[:is_mandatory] ? 'mandatory' : 'optional'
    is_first_attempt = true
    begin
      if prop[:is_mandatory] && !is_first_attempt
        puts "\nThis is a mandatory field so should not be blank. Please try again."
      end
      is_first_attempt = false
      prop[:text] = ''
      printf "\n%s [%s]: ", prop[:long_prompt], mand_text
      line = gets.chomp.strip
      while line != field_terminator
        prop[:text] += "#{line}\n" if line != ''
        printf "%s [%s]: ", prop[:short_prompt], field_term_msg
        line = gets.chomp.strip
      end
      prop[:text].chomp!
      #puts "INPUT WAS:  #{prop[:text]}"
    end while prop[:is_mandatory] && prop[:text] == ''
  }
  properties
end

##############################################################################
# Return the approx file size in a human readable form
def readable_file_size(size)
  case
    when size >= GB_SIZE: "#{(size/GB_SIZE).round} GB"
    when size >= MB_SIZE: "#{(size/MB_SIZE).round} MB"
    when size >= KB_SIZE: "#{(size/KB_SIZE).round} kB"
    else "#{size} bytes"
  end
end

##############################################################################
# Create an html-fragment containing a list of files (with their optional
# descriptions). Group by file-extension (because differences in
# file-extension often indicates differences in the file's purpose) then
# sort by filename within each grouping.
def create_html_block_links2files(file_descriptions_by_ext_by_fname)
  html_hdr_open = HTML_ELEMENT_SUBHEADING_EXT
  html_hdr_close = HTML_ELEMENT_SUBHEADING_EXT.sub(/^<([^ >]+).*$/, '</\1>')

  strings = []
  file_descriptions_by_ext_by_fname.sort.each{|ext, fnames|
    strings << sprintf("  %sFile extension %s%s", html_hdr_open, (ext=='' ? "[None]" : "'#{CGI::escapeHTML(ext)}'"), html_hdr_close)
    strings << "    <ul>"
    fnames.sort.each{|fname, desc|
      display_file_size = " (#{readable_file_size(File.size(fname))})"
      display_desc = desc == '' ? display_file_size : "#{display_file_size} -- #{desc}"
      strings << sprintf("      <li><a href=\"%s\">%s</a>%s</li>", fname, CGI::escapeHTML(fname), CGI::escapeHTML(display_desc))
    }
    strings << "    </ul>"
    strings << "    <hr>"
  }
  strings.join("\n")
end

##############################################################################
# Generate a web-page string based on all the info collected. Substitute
# strings for any tags found within the HTML_TEMPLATE file.
def generate_web_page(file_descriptions_by_ext_by_fname, properties)
  # Copy the text field/content from properties to file_descriptions_by_ext_by_fname
  file_descriptions_by_ext_by_fname.each{|ext,descs|
    descs.each_key{|fname|
      file_descriptions_by_ext_by_fname[ext][fname] = properties[get_prop_key(ext, fname)][:text]
    }
  }

  # Setup the tag/substitution strings for the html template
  tag_var_pairs = {
    "TAG_PAGE_TITLE"		=> CGI::escapeHTML(properties["TAG_PAGE_TITLE"][:text]),
    "TAG_PAGE_DESCRIPTION"	=> CGI::escapeHTML(properties["TAG_PAGE_DESCRIPTION"][:text]),
    "TAG_PAGE_BODY"		=> create_html_block_links2files(file_descriptions_by_ext_by_fname),
    "TAG_LAST_UPDATED"		=> Time.now.strftime('%d %b %Y'),
  }

  # Substitute any tags we find with the corresponding replacement string
  html_str = ''
  File.foreach(HTML_TEMPLATE){|line|
    tag_var_pairs.each{|tag,repl_str|
        line.sub!("#{HTML_REPLACEMENT_TAG_REGEX1}#{tag}#{HTML_REPLACEMENT_TAG_REGEX2}", repl_str)
    }
    html_str << line
  }
  html_str
end

##############################################################################
# Write the web page to the HTML_OUT_FNAME file. Enable styles by pointing
# to the CSS/image dir with a symlink.
def write_web_page_with_branding(html_str)
  puts
  # Point to CSS & image directories & files
  STYLE_IMAGE_DIRS.each{|file_dir|
    style_image_symlink = File.basename(file_dir)
    if File.exist?(style_image_symlink)
      puts "Symlink/directory/file '#{style_image_symlink}' already exists; no need to create symlink."
    else
      puts "Creating symlink to directory/file '#{file_dir}'."
      File.symlink(file_dir, style_image_symlink)
    end
  }

  puts "Writing basic web page to '#{HTML_OUT_FNAME}'"
  File.write_string(HTML_OUT_FNAME, html_str)
end

##############################################################################
# DEBUG USE ONLY: Show YAML representation of the important components
# of properties[]. Potentially, researchers could provide properties[] in
# a YAML file (formatted as per the dump generated below). [Too unfriendly
# for most users I suspect.]
def show_yaml_properties(properties)
  props_subset = {}
  properties.each{|key, props|
    props_subset[key] = {}
    props_subset[key][:order] = props[:order]
    props_subset[key][:text] = props[:text]
  }
  puts "\nYAML dump BEGIN\n#{YAML.dump(props_subset)}\nYAML dump END\n\n"
end

##############################################################################
# Main()
##############################################################################
check_for_web_page_overwrite

file_descriptions_by_ext_by_fname = get_file_descriptions_by_ext_by_fname
welcome(file_descriptions_by_ext_by_fname)

properties = generate_content_properties(file_descriptions_by_ext_by_fname)
properties = get_user_input(properties)	# Add text field (user input) to properties[]

html_str = generate_web_page(file_descriptions_by_ext_by_fname, properties)
write_web_page_with_branding(html_str)

