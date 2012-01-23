# developer machine will log in with username(netID) to server (either staging or production)
# developer machine will also log in with username(netID) to code repositary to do a git ls-remote to resolve branch/tag to commit hash
# server will log in with the same username(netID) and check out application from code repositary

require 'bundler/capistrano'
require 'bcdatabase'
require 'ncs_navigator/configuration'

bcconf = Bcdatabase.load[:ncs_deploy, :ncs_navigator_core] # Using the bcdatabase gem for server config
set :application, "ncs_navigator_core"

# User
set :use_sudo, false
ssh_options[:forward_agent] = true

# Version control
default_run_options[:pty]   = true # to get the passphrase prompt from git
default_environment['PATH'] = '/opt/ruby-enterprise/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin'

set :bundle_without, [:development, :test, :ci, :osx_development]

set :scm, "git"
set :repository, bcconf["repo"]
set :branch do
  # http://nathanhoad.net/deploy-from-a-git-tag-with-capistrano
  puts "Tags: " + `git tag`.split("\n").join(", ")
  puts "Remember to push tags first: git push origin --tags"
  ref = Capistrano::CLI.ui.ask "Tag, branch, or commit to deploy [master]: "
  ref.empty? ? "master" : ref
end
set :deploy_to, bcconf["deploy_to"]
set :deploy_via, :remote_cache

# Roles
task :set_roles do
  role :app, app_server
  role :web, app_server
  role :db, app_server, :primary => true
end

# Demo environment
desc "Deploy to demo"
task :demo do
  set :app_server, bcconf["demo_app_server"]
  set :rails_env, "staging"
  set_roles
end

# Staging environment
desc "Deploy to staging"
task :staging do
  set :app_server, bcconf["staging_app_server"]
  set :rails_env, "staging"
  set :whenever_environment, fetch(:rails_env)
  set_roles
end

# Production environment
desc "Deploy to production"
task :production do
  set :app_server, bcconf["production_app_server"]
  set :rails_env, "production"
  set :whenever_environment, fetch(:rails_env)
  set_roles
end

# Deploy start/stop/restart
namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Fix permissions"
  task :permissions do
    sudo "chmod -R g+w #{shared_path} #{current_path} #{release_path}"
  end

  desc 'Set up shared paths used by the importer'
  task :setup_import_directories do
    shared_import  = File.join(shared_path,  'importer_passthrough')
    release_import = File.join(current_path, 'importer_passthrough')
    cmds = [
      "mkdir -p #{shared_import}",
      "chmod g+w #{shared_import}",
      "if [ ! -e #{release_import} ]; then ln -s #{shared_import} #{release_import}; fi",
    ]
    run cmds.join(' && ')
  end
end

# backup the database before migrating
# before 'deploy:migrate', 'db:backup'

# after deploying, generate static pages, copy over uploads and results, cleanup old deploys, aggressively set permissions
after 'deploy:update_code', 'deploy:permissions', 'deploy:cleanup'

# after deploying symlink , copy images to current image config location.
after 'deploy:symlink', 'config:images', 'deploy:setup_import_directories'

# Database
namespace :db do
  desc "Backup Database"
  task :backup,  :roles => :app do
    run "cd #{current_path} && rake RAILS_ENV=#{rails_env} db:backup"
  end
end

namespace :config do
  desc "Copy configurable images to /public/assets/images folder"
  task :images,  :roles => :app do
    if NcsNavigator.configuration.footer_logo_left || NcsNavigator.configuration.footer_logo_right
      run "mkdir -p #{current_path}/public/images/config"
      run "cp #{NcsNavigator.configuration.footer_logo_left} #{current_path}/public/assets/images" if NcsNavigator.configuration.footer_logo_left
      run "cp #{NcsNavigator.configuration.footer_logo_right} #{current_path}/public/assets/images" if NcsNavigator.configuration.footer_logo_right
    end
  end
end
