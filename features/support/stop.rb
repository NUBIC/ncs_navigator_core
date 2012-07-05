# -*- coding: utf-8 -*-


# Usage:
#  @wip @stop
#  Scenario: NAME OF SCENARIO
#    ........................
# $ cucumber -p wip
After do |scenario|
  if scenario.failed? && scenario.source_tag_names.include?("@wip") && scenario.source_tag_names.include?("@stop")
    puts "Scenario failed. You are in rails console becuase of @stop. Type exit when you are done"
    require 'irb'
    require 'irb/completion'
    ARGV.clear
    IRB.start
  end
end