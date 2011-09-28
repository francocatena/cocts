require 'bundler/capistrano'

set :application, 'cocts'
set :repository,  'https://github.com/francocatena/cocts.git'
set :deploy_to, '/var/rails/cocts'
set :user, 'deployer'
set :group_writable, false
set :shared_children, %w(system log pids private public config)
set :use_sudo, false

set :scm, :git
set :branch, 'master'

role :web, 'cocts.com.ar'
role :app, 'cocts.com.ar'
role :db,  'cocts.com.ar', :primary => true

after 'deploy:symlink', 'deploy:create_shared_symlinks'

namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc 'Creates the symlinks for the shared folders'
  task :create_shared_symlinks do
    shared_paths = []

    shared_paths.each do |path|
      shared_files_path = File.join(shared_path, *path)
      release_files_path = File.join(release_path, *path)

      run "ln -s #{shared_files_path} #{release_files_path}"
    end
  end
end
