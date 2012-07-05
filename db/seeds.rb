# -*- coding: utf-8 -*-


# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'ncs_navigator/core/mdes_code_list_loader'
NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true).load_from_yaml
