require 'sidekiq'
require_relative 'target_bot'

class TargetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(login, pass, link, test = false)
    begin
      bot = TargetBot.new(login, pass, link, test)
      bot.run
      puts bot.result
    rescue Exception => e
      puts "Error. #{e}"
    end
  end
end
