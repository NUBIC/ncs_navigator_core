# -*- coding: utf-8 -*-

require 'simplecov'
SimpleCov.start 'rails'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
NcsNavigatorCore::Application.initialize!