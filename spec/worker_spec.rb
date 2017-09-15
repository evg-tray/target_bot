require 'target_worker'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe TargetWorker do
  let(:login) { 'test@example.com' }
  let(:pass) { '123' }
  let(:link) { 'http://example.com' }

  describe '#perform' do
    it 'change count jobs' do
      expect { TargetWorker.perform_async(login, pass, link, :test) }.to change(TargetWorker.jobs, :size).by(1)
    end
  end
end
