
namespace :sidekiq do
  sidekiq_pid_file = './tmp/pids/sidekiq.pid'

  desc "Sidekiq stop"
  task :stop do
    puts "Trying to stop Sidekiq Now"
    if File.exist?(sidekiq_pid_file)
      puts "Stopping sidekiq now #PID-#{File.readlines(sidekiq_pid_file).first}"
      system "sidekiqctl stop #{sidekiq_pid_file}"
    else
      puts "Sidekiq Not Running"
    end
  end

  desc "Sidekiq start"
  task :start do
    puts "Starting Sidekiq"
    system "bundle exec sidekiq -r './lib/target_worker.rb' -C './config/sidekiq.yml' -P './tmp/pids/sidekiq.pid' -d -L './tmp/logs/sidekiq.log'"
    sleep(2)
    puts "Sidekiq started #PID-#{File.readlines(sidekiq_pid_file).first}"
  end

  desc "Sidekiq restart"
  task :restart do
    puts "Trying to restart Sidekiq Now"
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['sidekiq:start'].invoke
    puts "Sidekiq restarted successfully"
  end

  desc "Sidekiq dashboard"
  task :dash do
    puts "Starting sidekiq dashboard"
    system "rackup sidekiq_web.ru"
  end
end
