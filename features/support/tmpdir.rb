require 'tmpdir'

# NB: This isn't an Around hook because we need to set variables and access
# methods in the world.
Before('@tmpdir') do
  @tmpdir = Dir.mktmpdir
end

After('@tmpdir') do
  remove_entry_secure(@tmpdir)
end
