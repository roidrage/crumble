require 'rubygems'
require 'rake'
require "spec/rake/spectask"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "crumble"
    gem.summary = %Q{Crumble - It's like breadcrumbs for your Rails application!}
    gem.description = %Q{How did these breadcrumbs in your Rails application? Oh right, with this plugin!}
    gem.email = "meyer@paperplanes.de"
    gem.homepage = "http://github.com/mattmatt/crumble"
    gem.authors = ["Mathias Meyer"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc "Run all specs"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/*.rb"]
end