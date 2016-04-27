# Mailman configuration
# namespace :mailman do
#   desc "Mailman::Start"
#   task :start, :roles => [:app] do
#     run "cd #{current_path};RAILS_ENV=#{rails_env} script/mailman_daemon.rb start"
#   end
#   desc "Mailman::Stop"
#   task :stop, :roles => [:app] do
#   run "cd #{current_path};RAILS_ENV=#{rails_env} script/mailman_daemon.rb stop"
# end
# desc "Mailman::Restart"
#   task :restart, :roles => [:app] do
# Mailman.stop Mailman.start
# end
# end
# before "deploy:cleanup", "mailman:restart"


# set :rails_env, "production" #added for delayed job
# set :rails_env, "development" #added for delayed job
# after "deploy:stop",    "delayed_job:stop"
# after "deploy:start",   "delayed_job:start"
# after "deploy:restart", "delayed_job:restart"
# after "deploy:stop",    "mailman:stop"
# after "deploy:start",   "mailman:start"
# after "deploy:restart", "mailman:restart"
#
# namespace :deploy do
#   desc "mailman script ausfuehrbar machen"
#   task :mailman_executable, :roles => :app do
#     run "chmod +x #{current_path}/script/mailman_server"
#   end
#
#   desc "mailman daemon ausfuehrbar machen"
#   task :mailman_daemon_executable, :roles => :app do
#     run "chmod +x #{current_path}/script/mailman_daemon"
#   end
# end
#
# namespace :mailman do
#   desc "Mailman::Start"
#   task :start, :roles => [:app] do
#     run "cd #{current_path};RAILS_ENV=#{fetch(:rails_env)} bundle exec script/mailman_daemon start"
#   end
#
#   desc "Mailman::Stop"
#   task :stop, :roles => [:app] do
#     run "cd #{current_path};RAILS_ENV=#{fetch(:rails_env)} bundle exec script/mailman_daemon stop"
#   end
#
#   desc "Mailman::Restart"
#   task :restart, :roles => [:app] do
#     mailman.stop
#     mailman.start
#   end
# end