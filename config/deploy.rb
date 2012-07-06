# -*- coding: utf-8 -*-


# developer machine will log in with username(netID) to server (either staging or production)
# developer machine will also log in with username(netID) to code repositary to do a git ls-remote to resolve branch/tag to commit hash
# server will log in with the same username(netID) and check out application from code repositary

require 'bundler/capistrano'
require 'bcdatabase'
require 'ncs_navigator/configuration'

bcconf = Bcdatabase.load["#{ENV['STUDY_CENTER']}_deploy", :ncs_navigator_core] # Using the bcdatabase gem for server config
set :application, "ncs_navigator_core"

# User
set :use_sudo, false
set :default_shell, "bash"
ssh_options[:forward_agent] = true

# Version control
default_run_options[:pty]   = true # to get the passphrase prompt from git

set :bundle_without, [:development, :test, :ci, :osx_development]

set :scm, "git"
set :git_enable_submodules, true
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

task :set_roles do
  role :app, app_server
  role :web, app_server
  role :db, app_server, :primary => true
end

desc "Deploy to demo"
task :demo do
  set :app_server, bcconf["demo_app_server"]
  set :rails_env, "staging"
  set_roles
end

desc "Deploy to staging"
task :staging do
  set :app_server, bcconf["staging_app_server"]
  set :rails_env, "staging"
  set :whenever_environment, fetch(:rails_env)
  set_roles
end

desc "Deploy to production"
task :production do
  set :app_server, bcconf["production_app_server"]
  set :rails_env, "production"
  set :whenever_environment, fetch(:rails_env)
  set_roles
end

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
    unless ENV['NO_FIX_PERMISSIONS']
      sudo "chmod -R g+w #{shared_path} #{current_path} #{release_path}"
    end
  end

  desc 'Set up shared paths used by the importer'
  task :setup_import_directories do
    shared_import  = File.join(shared_path,     'importer_passthrough')
    release_import = File.join(current_release, 'importer_passthrough')
    cmds = [
      "mkdir -p '#{shared_import}'",
      # Only chmod if owned; this is the only case in which chmod is
      # allowed. Will be owned if just created, which is the important
      # case.
      "if [ -O '#{shared_import}' ]; then chmod g+w '#{shared_import}'; fi",
      "if [ ! -e '#{release_import}' ]; then ln -s '#{shared_import}' '#{release_import}'; fi"
    ]
    run cmds.join(' && ')
  end

  desc "Link to surveys if they've been deployed"
  task :create_surveys_symlink do
    shared_surveys  = File.join(shared_path,     'surveys')
    release_surveys = File.join(current_release, 'surveys')
    run %Q(if [ ! -e '#{release_surveys}' -a -e '#{shared_surveys}' ]; then
             ln -s '#{shared_surveys}' '#{release_surveys}';
           fi).gsub(/\s+/, ' ')
  end
end

after 'deploy:finalize_update',
  'config:images',
  'deploy:setup_import_directories',
  'deploy:create_surveys_symlink'

namespace :db do
  desc "Backup Database"
  task :backup,  :roles => :app do
    run "cd '#{current_release}' && rake RAILS_ENV=#{rails_env} db:backup"
  end
end

namespace :config do
  desc "Copy configurable images to /public/assets/images folder"
  task :images,  :roles => :app do
    run [
      "cd '#{current_release}'",
      "#{rake} configuration:copy_image_files"
    ].join(' && ')
  end
end
