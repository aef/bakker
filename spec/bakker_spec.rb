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

require 'lib/bakker'

require 'tmpdir'
require 'fileutils'

require 'rubygems'
require 'sys/uname'

module BakkerSpecHelper
  # If there is a way to get the executable path of the currently running ruby
  # interpreter, please tell me how.
  warn 'Attention: If the ruby interpreter to be tested with is not ruby in the' +
       'default path, you have to change this manually in spec/bakker_spec.rb'
  RUBY_PATH = 'ruby'

  def tempfile_path(name, options = {})
    path = File.join(@folder_path, name)

    FileUtils.touch(path) if options[:create]

    path
  end

  def executable_path
    "#{RUBY_PATH} bin/bakker"
  end

  def windows?
    Sys::Uname.sysname.downcase.include?('windows')
  end
end

describe Bakker do
  include BakkerSpecHelper

  before(:each) do
    @folder_path = Dir.mktmpdir('bakker_spec')
  end

  after(:each) do
    FileUtils.rm_rf(@folder_path)
  end

  context 'library' do
    it "should throw an exception when source file does not exist" do
      source_path = tempfile_path('abc')

      lambda {
        Bakker.process(source_path)
      }.should raise_error(BakkerWarning)
    end

    it "should throw an exception when source and target file do exist" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak', :create => true)

      lambda {
        Bakker.process(source_path)
      }.should raise_error(BakkerWarning)
    end

    it "should extend a non-extended file correctly" do
      source_path = tempfile_path('def', :create => true)
      target_path = tempfile_path('def.bak')

      lambda {
        Bakker.process(source_path, '.bak', :toggle, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should extend a non-extended file correctly even if only the target is given" do
      source_path = tempfile_path('def', :create => true)
      target_path = tempfile_path('def.bak')

      lambda {
        Bakker.process(target_path, '.bak', :toggle, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should not extend a non-extended file if mode is remove" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Bakker.process(source_path, '.ext', :remove, :move)
      }.should_not change{ File.exist?(target_path) == false } and
                   change{ File.exist?(source_path) == true }
    end

    it "should not extend a non-extended file if mode is remove even if only the target is given" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Bakker.process(target_path, '.ext', :remove, :move)
      }.should_not change{ File.exist?(target_path) == false } and
                   change{ File.exist?(source_path) == true }
    end

    it "should extend a non-extended file if mode is add" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Bakker.process(source_path, '.ext', :add, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should extend a non-extended file if mode is add even if only the target is given" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Bakker.process(source_path, '.ext', :add, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should create an extended copy of a non-extended file if action is copy" do
      source_path = tempfile_path('xyz', :create => true)
      target_path = tempfile_path('xyz.tar.gz')

      lambda {
        Bakker.process(source_path, '.tar.gz', :toggle, :copy)
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end

    it "should create an extended copy of a non-extended file if action is copy even if only the target is given" do
      source_path = tempfile_path('xyz', :create => true)
      target_path = tempfile_path('xyz.tar.gz')

      lambda {
        Bakker.process(target_path, '.tar.gz', :toggle, :copy)
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end
    
    it "should unextend an extended file correctly" do
      source_path = tempfile_path('xyz.zirbel', :create => true)
      target_path = tempfile_path('xyz')

      lambda {
        Bakker.process(source_path, '.zirbel', :toggle, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should unextend an extended file correctly even if only the target is given" do
      source_path = tempfile_path('xyz.zirbel', :create => true)
      target_path = tempfile_path('xyz')

      lambda {
        Bakker.process(target_path, '.zirbel', :toggle, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should not unextend an extended file if mode is add" do
      source_path = tempfile_path('1234.bak', :create => true)
      target_path = tempfile_path('1234')

      lambda {
        Bakker.process(source_path, '.bak', :add, :move)
      }.should_not change{ File.exist?(target_path) == false } and
                   change{ File.exist?(source_path) == true }
    end

    it "should not unextend an extended file if mode is add even if only the target is given" do
      source_path = tempfile_path('1234.bak', :create => true)
      target_path = tempfile_path('1234')

      lambda {
        Bakker.process(target_path, '.bak', :add, :move)
      }.should_not change{ File.exist?(target_path) == false } and
                   change{ File.exist?(source_path) == true }
    end

    it "should unextend an extended file if mode is remove" do
      source_path = tempfile_path('testfile.1234', :create => true)
      target_path = tempfile_path('testfile')

      lambda {
        Bakker.process(source_path, '.1234', :remove, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should unextend an extended file if mode is remove even if only the target is given" do
      source_path = tempfile_path('testfile.1234', :create => true)
      target_path = tempfile_path('testfile')

      lambda {
        Bakker.process(target_path, '.1234', :remove, :move)
      }.should change{ File.exist?(target_path) }.from(false).to(true) and
               change{ File.exist?(source_path) }.from(true).to(false)
    end

    it "should create an unextended copy of an extended file if action is copy" do
      source_path = tempfile_path('demo.exe', :create => true)
      target_path = tempfile_path('demo')

      lambda {
        Bakker.process(source_path, '.exe', :toggle, :copy)
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end

    it "should create an unextended copy of an extended file if action is copy even if only the target is given" do
      source_path = tempfile_path('demo.exe', :create => true)
      target_path = tempfile_path('demo')

      lambda {
        Bakker.process(target_path, '.exe', :toggle, :copy)
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end
  end

  context 'commandline tool' do
    it "use action move, extension .bak and mode toggle by default" do
      source_path = tempfile_path('test.bak', :create => true)
      target_path = tempfile_path('test')
      
      lambda {
        `#{executable_path} #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)

      lambda {
        `#{executable_path} #{target_path}`
      }.should change{ File.exists?(target_path) }.from(true).to(false) and
               change{ File.exists?(source_path) }.from(false).to(true)
    end

    it "should use -a to select the action" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} -a copy #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end

    it "should use --action to select the action" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} --action copy #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end

    it "should use -e to select an extension" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        `#{executable_path} -e .zirbel #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)
    end

    it "should use --extension to select an extension" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        `#{executable_path} --extension .zirbel #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)
    end

    it "should use -m to select a processing mode" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} -m remove #{source_path}`
      }.should_not change{ File.exists?(target_path) == false } and
                   change{ File.exists?(source_path) == true }

      lambda {
        `#{executable_path} -m toggle #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)

      lambda {
        `#{executable_path} -m add #{source_path}`
      }.should_not change{ File.exists?(target_path) == true } and
                   change{ File.exists?(source_path) == false }
    end

    it "should use --mode to select a processing mode" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} --mode remove #{source_path}`
      }.should_not change{ File.exists?(target_path) == false } and
                   change{ File.exists?(source_path) == true }

      lambda {
        `#{executable_path} --mode toggle #{source_path}`
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)

      lambda {
        `#{executable_path} --mode add #{source_path}`
      }.should_not change{ File.exists?(target_path) == true } and
                   change{ File.exists?(source_path) == false }
    end

    it "should allow multiple files as argument" do
      source_path_a = tempfile_path('abc', :create => true)
      target_path_a = tempfile_path('abc.bak')
      source_path_b = tempfile_path('def.bak', :create => true)
      target_path_b = tempfile_path('def')
      source_path_c = tempfile_path('xyz', :create => true)
      target_path_c = tempfile_path('xyz.bak')

      lambda {
        `#{executable_path} #{source_path_a} #{source_path_b} #{source_path_c}`
      }.should change{ File.exists?(target_path_a) }.from(false).to(true) and
               change{ File.exists?(source_path_a) }.from(true).to(false) and
               change{ File.exists?(target_path_b) }.from(false).to(true) and
               change{ File.exists?(source_path_b) }.from(true).to(false) and
               change{ File.exists?(target_path_c) }.from(false).to(true) and
               change{ File.exists?(source_path_c) }.from(true).to(false)
    end

    it "should accept action config via environment variables" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        if windows?
          `set BAKKER_ACTION=copy`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_ACTION=copy #{executable_path} #{source_path}`
        end
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               not change{ File.exists?(source_path) == true }
    end

    it "should prefer commandline setting over environment for action" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        if windows?
          `set BAKKER_ACTION=copy`
          `#{executable_path} -a move #{source_path}`
        else
          `env BAKKER_ACTION=copy #{executable_path} -a move #{source_path}`
        end
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)
    end

    it "should accept extension config via environment variables" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        if windows?
          `set BAKKER_EXTENSION=.zirbel`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_EXTENSION=.zirbel #{executable_path} #{source_path}`
        end
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)
    end

    it "should prefer commandline setting over environment for extension" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        if windows?
          `set BAKKER_EXTENSION=.1234`
          `#{executable_path} -e .zirbel #{source_path}`
        else
          `env BAKKER_EXTENSION=.1234 #{executable_path} -e .zirbel #{source_path}`
        end
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)
    end

    it "should accept extension config via environment variables" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        if windows?
          `set BAKKER_MODE=remove`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_MODE=remove #{executable_path} #{source_path}`
        end
      }.should_not change{ File.exists?(target_path) == false } and
                   change{ File.exists?(source_path) == true }

      lambda {
        if windows?
          `set BAKKER_MODE=toggle`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_MODE=toggle #{executable_path} #{source_path}`
        end
      }.should change{ File.exists?(target_path) }.from(false).to(true) and
               change{ File.exists?(source_path) }.from(true).to(false)

      lambda {
        if windows?
          `set BAKKER_MODE=add`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_MODE=add #{executable_path} #{source_path}`
        end
      }.should_not change{ File.exists?(target_path) == true } and
                   change{ File.exists?(source_path) == false }
    end

    it "should prefer commandline setting over environment for mode" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        if windows?
          `set BAKKER_MODE=add`
          `#{executable_path} -m remove #{source_path}`
        else
          `env BAKKER_MODE=add #{executable_path} -m remove #{source_path}`
        end
      }.should_not change{ File.exists?(target_path) == false } and
                   change{ File.exists?(source_path) == true }
    end
  end
end
