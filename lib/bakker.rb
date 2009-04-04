# Copyright 2009 Alexander E. Fischer <aef@raxys.net>
#
# This file is part of Bakker.
#
# Bakker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

require 'fileutils'

class BakkerWarning < StandardError; end

# Bakker is a Ruby library and commandline tool to help with simple task of
# renaming or copying files for quick backup purposes.
module Bakker
  VERSION = '1.0.1'
  DEFAULT_EXTENSION = '.bak'
  MODES = [:toggle, :add, :remove]
  ACTIONS = [:move, :copy]

  module_function

  # For possible options see FileUtils methods cp() and mv()
  def process(filename, extension = DEFAULT_EXTENSION, mode = MODES.first, action = ACTIONS.first, options = {})
    raise ArgumentError, 'Action can only be :copy or :move.' unless ACTIONS.include?(action)
    raise ArgumentError, 'Mode can only be :toggle, :add or :remove.' unless MODES.include?(mode)

    # Regex used for determining if an extension should be added or removed
    regexp = /#{Regexp.escape(extension)}$/

    # Find out both the basic file name and the extended file name for every
    # situation possible
    filename_without_extension = filename.gsub(regexp, '')
    filename_with_extension = filename_without_extension + extension

    # Check both cases for existence for further processing
    without_exists = File.exists?(filename_without_extension)
    with_exists = File.exists?(filename_with_extension)

    # Error if both unextended and extended files or none of them exist
    #
    # The mode variable contains symbols :copy or :move which correspond to
    # methods of class FileUtils which are invoked through the send() method.
    if without_exists and with_exists
      raise BakkerWarning, "Both #{filename_without_extension} and #{filename_with_extension} already exist."
    elsif without_exists and not with_exists
      if [:toggle, :add].include?(mode)
        FileUtils.send(action, filename_without_extension, filename_with_extension, options)
        filename_with_extension
      else
        filename_without_extension
      end
    elsif not without_exists and with_exists
      if [:toggle, :remove].include?(mode)
        FileUtils.send(action, filename_with_extension, filename_without_extension, options)
        filename_without_extension
      else
        filename_with_extension
      end
    else
      raise BakkerWarning, "Neither #{filename_without_extension} nor #{filename_with_extension} found."
    end
  end
end
