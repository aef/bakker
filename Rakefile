# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/bakker.rb'

Hoe.new('bakker', Bakker::VERSION) do |p|
  p.rubyforge_name = 'aef'
  p.developer('Alexander E. Fischer', 'aef@raxys.net')
  p.extra_dev_deps = %w{user-choices sys-uname}
  p.url = 'https://rubyforge.org/projects/aef/'
  p.spec_extras = {
    :rdoc_options => ['--main', 'README.txt', '--inline-source', '--line-numbers', '--title', 'Bakker']
  }
end

# vim: syntax=Ruby
