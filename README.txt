= Bakker

* Project: https://rubyforge.org/projects/aef/
* RDoc: http://aef.rubyforge.org/bakker/

== DESCRIPTION:

Bakker was created to help with simple task of renaming or copying files for
quick backup purposes. For instance by creating a copy of a list of files
while adding .bak to the copies filenames. Bakker gives you control over the
extension to be added to or removed from the file and whether it should be
moved or copied.

== FEATURES/PROBLEMS:

* Usable as library and commandline tool
* Tested and fully working on:
  * Ubuntu Linux 8.10 i386_64 (Ruby 1.8.7 and 1.9.1p0)
  * On Windows XP i386 (Ruby 1.8.6)
* On Windows XP i386 (Ruby 1.8.6) there were some problems testing the
  environment variable choices. Two tests are failing but the programs seems
  to work correctly. If anyone finds the problem, please contact me.
* The commandline tool doesn't work with Ruby 1.9.x because the user-choices gem
  is not yet updated. A patch is available here:
  https://rubyforge.org/tracker/index.php?func=detail&aid=24307&group_id=4192&atid=16176

== SYNOPSIS:

=== Commandline

The following command renames config.ini to config.ini.bak. You can type the
same command a second time to revert the action:

  bakker config.ini

Instead of renaming you can create a copy of config.xml by using the following
command:

  bakker -a copy config.ini

To change the extension which will be appended or removed from the filename use
the following command:

  bakker -e .backup

In a directory with the follwing contents:

  demo1
  demo2.bak
  demo3.bak

if you use the command:

  bakker *

you get the following list of files (because by default Bakker toggles the
extension):

  demo1.bak
  demo2
  demo3

if you now want every file in the folder to have a .bak extension use the
following command:

  bakker -m add *

the result will look like this:

  demo1.bak
  demo2.bak
  demo3.bak

Instead of using the add-mode you could have used the remove-mode like this:

  bakker -m remove *

Then the result would have looked like this:

  demo1
  demo2
  demo3

Bakker also includes a verbose mode which will inform you of any file transfer
in the console:

  bakker -v config.ini

You can specify default values for extension, action, mode and even for the
verbose mode by using environment variables. Notice that you can still override
these by using commandline switches. A list of the variables:

* BAKKER_MODE
* BAKKER_ACTION
* BAKKER_EXTENSION
* BAKKER_VERBOSE

=== Library

Load the gem:

  require 'bakker'

Call Bakker:

  Bakker.process('config.ini', '.backup', :add, :copy)

== REQUIREMENTS:

* user-choices (for commandline tool only)
* rspec (for testing only)
* sys-uname (for testing only)

== INSTALL:

* gem install bakker
* gem install user-choices (only for commandline tool)

== LICENSE:

Copyright 2009 Alexander E. Fischer <aef@raxys.net>

This file is part of Bakker.

Bakker is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
