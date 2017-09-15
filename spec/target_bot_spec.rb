require 'target_bot'

RSpec.describe TargetBot do
  let(:login) { 'zghywgwf@emlpro.com' }
  let(:pass) { '123456a' }
  let(:incorrect_login) { 'test@example.com' }
  let(:incorrect_pass) { '123' }
  let(:link) { 'https://itunes.apple.com/us/app/angry-birds/id343200656?mt=8' }

  context 'incorrect login-pass' do
    it 'raise exception "Incorrect login/pass"' do
      bot = TargetBot.new(incorrect_login, incorrect_pass, link, :test)
      expect { bot.run }.to raise_error('Incorrect login/pass')
    end
  end

  context 'correct login-pass' do
    it 'after run result is hash with created app and placements ids' do
      bot = TargetBot.new(login, pass, link, :test)
      bot.run
      expect(bot.result).to have_key(:app_id)
      expect(bot.result).to have_key(:placement_ids)
    end

    it 'after initialize result is empty hash' do
      bot = TargetBot.new(login, pass, link, :test)
      expect(bot.result).to eq({})
    end
  end
end
