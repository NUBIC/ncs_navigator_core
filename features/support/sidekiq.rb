# -*- coding: utf-8 -*-


# Disconnects Sidekiq from the network and places jobs into an in-memory
# queue.
require 'sidekiq/testing'

# Isolates tests.
Before do
  NcsNavigator::Core::Field::MergeWorker.jobs.clear
end
