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
require 'file_transfer_matchers'
require 'sys/uname'

module BakkerSpecHelper
  # If there is a way to get the executable path of the currently running ruby
  # interpreter, please tell me how.
  warn 'Attention: If the ruby interpreter to be tested with is not ruby in the ' +
       "default path, you have to change this manually in #{__FILE__} line #{__LINE__ + 1}"
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

describe Aef::Bakker do
  include BakkerSpecHelper
  include Aef::FileTransferMatchers

  before(:each) do
    # Before ruby 1.8.7, the tmpdir standard library had no method to create
    # a temporary directory (mktmpdir).
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.8.7')
      @folder_path = File.join(Dir.tmpdir, 'bakker_spec')
      Dir.mkdir(@folder_path)
    else
      @folder_path = Dir.mktmpdir('bakker_spec')
    end
  end

  after(:each) do
    FileUtils.rm_rf(@folder_path)
  end

  context 'library' do
    it "should throw an exception when source file does not exist" do
      source_path = tempfile_path('abc')

      lambda {
        Aef::Bakker.process(source_path)
      }.should raise_error(Aef::BakkerWarning)
    end

    it "should throw an exception when source and target file do exist" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak', :create => true)

      lambda {
        Aef::Bakker.process(source_path)
      }.should raise_error(Aef::BakkerWarning)
    end

    it "should extend a non-extended file correctly" do
      source_path = tempfile_path('def', :create => true)
      target_path = tempfile_path('def.bak')

      lambda {
        Aef::Bakker.process(source_path, '.bak', :toggle, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should extend a non-extended file correctly even if only the target is given" do
      source_path = tempfile_path('def', :create => true)
      target_path = tempfile_path('def.bak')

      lambda {
        Aef::Bakker.process(target_path, '.bak', :toggle, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should not extend a non-extended file if mode is remove" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Aef::Bakker.process(source_path, '.ext', :remove, :move)
      }.should_not move(source_path, :to => target_path)
    end

    it "should not extend a non-extended file if mode is remove even if only the target is given" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Aef::Bakker.process(target_path, '.ext', :remove, :move)
      }.should_not move(source_path, :to => target_path)
    end

    it "should extend a non-extended file if mode is add" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Aef::Bakker.process(source_path, '.ext', :add, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should extend a non-extended file if mode is add even if only the target is given" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.ext')

      lambda {
        Aef::Bakker.process(source_path, '.ext', :add, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should create an extended copy of a non-extended file if action is copy" do
      source_path = tempfile_path('xyz', :create => true)
      target_path = tempfile_path('xyz.tar.gz')

      lambda {
        Aef::Bakker.process(source_path, '.tar.gz', :toggle, :copy)
      }.should copy(source_path, :to => target_path)
    end

    it "should create an extended copy of a non-extended file if action is copy even if only the target is given" do
      source_path = tempfile_path('xyz', :create => true)
      target_path = tempfile_path('xyz.tar.gz')

      lambda {
        Aef::Bakker.process(target_path, '.tar.gz', :toggle, :copy)
      }.should copy(source_path, :to => target_path)
    end
    
    it "should unextend an extended file correctly" do
      source_path = tempfile_path('xyz.zirbel', :create => true)
      target_path = tempfile_path('xyz')

      lambda {
        Aef::Bakker.process(source_path, '.zirbel', :toggle, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should unextend an extended file correctly even if only the target is given" do
      source_path = tempfile_path('xyz.zirbel', :create => true)
      target_path = tempfile_path('xyz')

      lambda {
        Aef::Bakker.process(target_path, '.zirbel', :toggle, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should not unextend an extended file if mode is add" do
      source_path = tempfile_path('1234.bak', :create => true)
      target_path = tempfile_path('1234')

      lambda {
        Aef::Bakker.process(source_path, '.bak', :add, :move)
      }.should_not move(source_path, :to => target_path)
    end

    it "should not unextend an extended file if mode is add even if only the target is given" do
      source_path = tempfile_path('1234.bak', :create => true)
      target_path = tempfile_path('1234')

      lambda {
        Aef::Bakker.process(target_path, '.bak', :add, :move)
      }.should_not move(source_path, :to => target_path)
    end

    it "should unextend an extended file if mode is remove" do
      source_path = tempfile_path('testfile.1234', :create => true)
      target_path = tempfile_path('testfile')

      lambda {
        Aef::Bakker.process(source_path, '.1234', :remove, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should unextend an extended file if mode is remove even if only the target is given" do
      source_path = tempfile_path('testfile.1234', :create => true)
      target_path = tempfile_path('testfile')

      lambda {
        Aef::Bakker.process(target_path, '.1234', :remove, :move)
      }.should move(source_path, :to => target_path)
    end

    it "should create an unextended copy of an extended file if action is copy" do
      source_path = tempfile_path('demo.exe', :create => true)
      target_path = tempfile_path('demo')

      lambda {
        Aef::Bakker.process(source_path, '.exe', :toggle, :copy)
      }.should copy(source_path, :to => target_path)
    end

    it "should create an unextended copy of an extended file if action is copy even if only the target is given" do
      source_path = tempfile_path('demo.exe', :create => true)
      target_path = tempfile_path('demo')

      lambda {
        Aef::Bakker.process(target_path, '.exe', :toggle, :copy)
      }.should copy(source_path, :to => target_path)
    end
  end

  context 'commandline tool' do
    it "use action move, extension .bak and mode toggle by default" do
      source_path = tempfile_path('test.bak', :create => true)
      target_path = tempfile_path('test')
      
      lambda {
        `#{executable_path} #{source_path}`
      }.should move(source_path, :to => target_path)

      lambda {
        `#{executable_path} #{target_path}`
      }.should move(target_path, :to => source_path)
    end

    it "should use -a to select the action" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} -a copy #{source_path}`
      }.should copy(source_path, :to => target_path)
    end

    it "should use --action to select the action" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} --action copy #{source_path}`
      }.should copy(source_path, :to => target_path)
    end

    it "should use -e to select an extension" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        `#{executable_path} -e .zirbel #{source_path}`
      }.should move(source_path, :to => target_path)
    end

    it "should use --extension to select an extension" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.zirbel')

      lambda {
        `#{executable_path} --extension .zirbel #{source_path}`
      }.should move(source_path, :to => target_path)
    end

    it "should use -m to select a processing mode" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} -m remove #{source_path}`
      }.should_not move(source_path, :to => target_path)

      lambda {
        `#{executable_path} -m toggle #{source_path}`
      }.should move(source_path, :to => target_path)

      lambda {
        `#{executable_path} -m add #{source_path}`
      }.should_not move(target_path, :to => source_path)
    end

    it "should use --mode to select a processing mode" do
      source_path = tempfile_path('abc', :create => true)
      target_path = tempfile_path('abc.bak')

      lambda {
        `#{executable_path} --mode remove #{source_path}`
      }.should_not move(source_path, :to => target_path)

      lambda {
        `#{executable_path} --mode toggle #{source_path}`
      }.should move(source_path, :to => target_path)

      lambda {
        `#{executable_path} --mode add #{source_path}`
      }.should_not move(target_path, :to => source_path)
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
      }.should move(source_path_a, :to => target_path_a) and
               move(source_path_b, :to => target_path_b) and
               move(source_path_c, :to => target_path_c)
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
      }.should copy(source_path, :to => target_path)
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
      }.should move(source_path, :to => target_path)
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
      }.should move(source_path, :to => target_path)
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
      }.should move(source_path, :to => target_path)
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
      }.should_not move(source_path, :to => target_path)

      lambda {
        if windows?
          `set BAKKER_MODE=toggle`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_MODE=toggle #{executable_path} #{source_path}`
        end
      }.should move(source_path, :to => target_path)

      lambda {
        if windows?
          `set BAKKER_MODE=add`
          `#{executable_path} #{source_path}`
        else
          `env BAKKER_MODE=add #{executable_path} #{source_path}`
        end
      }.should_not move(target_path, :to => source_path)
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
      }.should_not move(source_path, :to => target_path)
    end

    it 'should display correct version and licensing information with the --version switch' do
      message = <<-EOF
Bakker 1.1.0

Project: https://rubyforge.org/projects/aef/
RDoc: http://aef.rubyforge.org/bakker/
Github: http://github.com/aef/bakker/

Copyright 2009 Alexander E. Fischer <aef@raxys.net>

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
EOF
      `#{executable_path} --version`.should eql(message)
    end
  end
end
