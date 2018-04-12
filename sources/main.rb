require_relative 'cluster_logger.rb'
require_relative 'project_logger.rb'
require_relative 'user_database.rb'
require_relative 'slack_pinger.rb'
require_relative 'slack_bot.rb'
require 'awesome_print'

cluster = ClusterLogger.new
project = ProjectLogger.new
slack = SlackPinger.new
db = UserDatabase.new

def log(c1, c2, slack_id)
  	puts "\nTime: #{Time.now}"
	ap c1
	puts "\n"
	ap c2
  puts "slack_id ----------------------------------------------"
  ap slack_id
	puts "-------------------------------------------------------\n\n"
	STDOUT.flush
end

while true

  users = db.get_users
  users_api42_ids = users.map { |u| u[:api42_id] }

  begin
  	connected_infos = cluster.update_logger(users_api42_ids)
  	projects_infos = project.get_infos(users_api42_ids)
  rescue Exception => e
  	puts "En error occured: #{e.message}"
  	next
  end

  users.each do |user|
    cluster.update_user(connected_infos, user, slack, db)
    project.update_user(projects_infos, user, slack, db)
  end

  db.close
  users = nil
  sleep 10
end
