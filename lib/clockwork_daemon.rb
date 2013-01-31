#!/usr/bin/env ruby

require 'clockwork'
require 'dante'

clock_path = File.expand_path('../../config/clockwork.rb', __FILE__)

Dante.run('clockwork') do
  $stderr.sync = $stdout.sync = true
  require clock_path
  Clockwork.run
end
