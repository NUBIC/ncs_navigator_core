require 'logger'
require 'stringio'

##
# Defines a logger whose contents can be inspected in examples.  Useful for
# expecting log messages as a side effect of actions.
shared_context 'logger' do
  let(:log) { logdev.string }
  let(:logdev) { StringIO.new }
  let(:logger) { Logger.new(logdev) }
end
