require 'bundler/capistrano'

default_run_options[:shell] = '/bin/bash --login'

set :default_environment, {
  'PATH' => '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH'
}

set :application, 'cocts'
set :user, 'deployer'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :group_writable, false
set :shared_children, %w(log private)
set :use_sudo, false

set :repository,  'git://github.com/francocatena/cocts.git'
set :branch, 'master'
set :scm, :git
set :deploy_via, :remote_cache

server 'cocts.com.ar', :web, :app, :db, primary: true

after 'deploy:finalize_update', 'deploy:create_shared_symlinks'

namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc 'Creates the symlinks for the shared folders'
  task :create_shared_symlinks do
    shared_paths = [['config', 'app_config.yml']]

    shared_paths.each do |path|
      shared_files_path = File.join(shared_path, *path)
      release_files_path = File.join(release_path, *path)

      run "ln -s #{shared_files_path} #{release_files_path}"
    end
  end
end
