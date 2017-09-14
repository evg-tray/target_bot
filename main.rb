require 'dotenv/load'
require_relative 'lib/target_worker'

print 'Enter count workers:'
count_workers = gets.chomp.to_i
count_workers.times do
  TargetWorker.perform_async(
      ENV['TARGET_LOGIN'],
      ENV['TARGET_PASSWORD'],
      'https://itunes.apple.com/us/app/angry-birds/id343200656?mt=8'
  )
end

puts "#{count_workers} worker(s) sent to queue"
