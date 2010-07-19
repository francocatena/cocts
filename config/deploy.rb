set :application, 'cocts'
set :repository,  'deployer@fcatena.com.ar:/home/franco/NetBeansProjects/cocts_app'
set :deploy_to, '/var/rails/cocts'
set :user, 'deployer'
set :password, '!QAZxsw2'
set :group_writable, false
set :shared_children, %w(system log pids private public config)
set :use_sudo, false

default_run_options[:pty] = true
set :scm, :git
set :branch, 'master'
set :scm_passphrase, "!QAZxsw2"

role :web, 'mawida.com.ar' # Your HTTP server, Apache/etc
role :app, 'mawida.com.ar' # This may be the same as your `Web` server
role :db,  'mawida.com.ar', :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

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