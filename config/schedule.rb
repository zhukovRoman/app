# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :current_path_rake, 'cd :path && :environment_variable=:environment bundle exec rake :task --silent :output'

every 1.day, :at => '4:30 am'  do
  current_path_rake 'employee:update_employees_stats'
end

every 1.day, :at => '4:35 am'  do
  current_path_rake 'apartments:update'
end

every 1.day, :at => '11:35 pm'  do
  current_path_rake 'photo:save'
end

every 1.hour  do
  current_path_rake 'api_cacher:update_all'
end
