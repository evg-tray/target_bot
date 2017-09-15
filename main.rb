require 'dotenv/load'
require_relative 'lib/target_worker'

print 'Enter count new apps:'
count_apps = gets.chomp.to_i
count_apps.times do
  TargetWorker.perform_async(
      ENV['TARGET_LOGIN'],
      ENV['TARGET_PASSWORD'],
      'https://itunes.apple.com/us/app/angry-birds/id343200656?mt=8',
      :test
  )
end

puts "Creating #{count_apps} new apps sent to queue"
