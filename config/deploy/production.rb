set :stage, :production
set :rails_env, 'production'

role :web, %w{deployer@cocts.com.ar}
role :app, %w{deployer@cocts.com.ar}
role :db,  %w{deployer@cocts.com.ar}

server 'cocts.com.ar', user: 'deployer', roles: %w{web app db}
