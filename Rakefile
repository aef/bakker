# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/bakker.rb'

Hoe.new('bakker', Aef::Bakker::VERSION) do |p|
  p.rubyforge_name = 'aef'
  p.developer('Alexander E. Fischer', 'aef@raxys.net')
  p.extra_dev_deps = %w{user-choices rspec sys-uname}
  p.url = 'https://rubyforge.org/projects/aef/'
  p.readme_file = 'README.rdoc'
  p.extra_rdoc_files = %w{README.rdoc}
  p.spec_extras = {
    :rdoc_options => ['--main', 'README.rdoc', '--inline-source', '--line-numbers', '--title', 'Bakker']
  }
end

# vim: syntax=Ruby
