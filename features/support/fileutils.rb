require 'fileutils'

# FileUtils is used for manipulating MDES data.  It could be useful in other
# contexts, too.
Cucumber::Rails::World.send(:include, FileUtils)
