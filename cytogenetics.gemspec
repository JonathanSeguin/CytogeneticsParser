$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'cytogenetics/version'

Gem::Specification.new do |s|
  s.name = "cytogenetics"
  s.author = "Original code by Sarah Killcoyne"
  s.email = "sarah.killcoyne@uni.lu"
  s.license = "http://www.apache.org/licenses/LICENSE-2.0.html"
  s.version = Cytogenetics::VERSION
  s.date = "2013-12-16"
  s.summary = "Karyotype parser based on ISCN specification."
  s.description = "Karyotype parser based on ISCN specification. Note that there are still many bugs. The ISCN language is poorly followed by most users so the parser is still being developed."
  #s.files = Dir.glob("lib/**/*.rb") + Dir['resources'] + Dir['test']
  s.files = Dir['Rakefile', '{bin,lib,man,test,spec,resources}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.require_path = 'lib'
end

