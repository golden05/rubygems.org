# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rubygems'
set :deploy_to, '/applications/rubygems'
set :repo_url, 'https://github.com/rubygems/rubygems.org.git'
set :scm, :git
set :git_strategy, Capistrano::Git::SubmoduleStrategy
set :pty, true
set :assets_roles, [:app]
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/cache', 'tmp/sockets')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secret.rb')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do

  desc 'Remove git cache for clean deploy'
  task :clean_git_cache do
    on roles(:app) do
      execute :rm, "-rf #{repo_path}"
    end
  end

  desc 'Restart unicorn and delayed_job'
  task :restart do
    on roles(:app) do |host|
      host.user = nil
      execute :sudo, 'service unicorn restart'
      execute :sudo, 'service delayed_job restart'
    end
  end
  after :publishing, :'deploy:restart'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
