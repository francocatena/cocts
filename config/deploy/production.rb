set :stage, :production
set :rails_env, 'production'

role :all, %w{cocts.com.ar}

server 'cocts.com.ar', user: 'deployer', roles: %w{web app db}
