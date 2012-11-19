require 'logger'

f = File.open("#{Rails.root}/log/psc.log", 'a')
NcsNavigatorCore.psc_logger = Logger.new(f)
