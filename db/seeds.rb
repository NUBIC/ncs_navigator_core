# -*- coding: utf-8 -*-


# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if ENV['INITIAL_MDES_VERSION']
  require 'ncs_navigator/core/mdes/version'
  NcsNavigator::Core::Mdes::Version.set!(ENV['INITIAL_MDES_VERSION'])
end

require 'ncs_navigator/core/mdes/code_list_loader'
NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true).load_from_yaml
