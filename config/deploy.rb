require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/unicorn'
require 'mina/whenever'

set :domain, '213.85.34.118'
set :deploy_to, '/var/www/app'
set :repository, 'git@github.com:zhukovRoman/app.git'
set :branch, 'master'
set :user, 'user'
set :forward_agent, true     # SSH forward_agent.
set :ssh_options, '-A -p 50022'
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :shared_paths, ['config/database.yml', 'log', 'config/secrets.yml', 'db/development.sqlite3', 'api_cache']

task :environment do
  queue %{
    echo "-----> Loading environment"
    #{echo_cmd %[source ~/.bashrc]}
        }

  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/sockets"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/database.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/secrets.yml"]
  queue %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/secrets.yml'."]

  queue! %[mkdir -p "#{deploy_to}/shared/pids/"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/api_cache/"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/api_cache"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'whenever:update'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end



