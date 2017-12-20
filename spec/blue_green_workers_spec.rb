# frozen_string_literal: true

RSpec.describe BlueGreenWorkers do
  it 'has a version number' do
    expect(BlueGreenWorkers::VERSION).not_to be nil
  end

  around do |example|
    load "#{__dir__}/../lib/blue_green_workers.rb"
    BlueGreenWorkers.instance_variable_set :@config, nil
    example.run
    BlueGreenWorkers.shutdown
  end

  describe '#configure' do
    let(:config) { BlueGreenWorkers.instance_variable_get :@config }

    it 'sets a cluster name' do
      BlueGreenWorkers.configure do |c|
        c.determine_active_cluster { 'active' }
        c.cluster_name = 'blue'
      end
      expect(config.cluster_name).to eq 'blue'
    end

    it 'sets an active_cluster block' do
      active_cluster = proc{}
      BlueGreenWorkers.configure do |config|
        config.determine_active_cluster(&active_cluster)
        config.cluster_name = 'us'
      end
      expect(config.active_cluster_block).to_not be_nil
      expect(config.active_cluster_block).to eq active_cluster
    end

    it 'sets the refresh interval' do
      BlueGreenWorkers.configure do |config|
        config.determine_active_cluster { 'active' }
        config.refresh_interval = 10
        config.cluster_name = 'us'
      end
      expect(config.refresh_interval).to be 10
    end

    it 'sets a logger' do
      logger = NullLogger.new
      BlueGreenWorkers.configure do |config|
        config.determine_active_cluster { 'active' }
        config.logger = logger
        config.cluster_name = 'us'
      end
      expect(config.logger).to eq logger
    end

    it 'uses a default logger' do
      BlueGreenWorkers.configure do |config|
        config.determine_active_cluster { 'active' }
        config.cluster_name = 'us'
      end
      expect(config.logger).to be_a Logger
    end
  end

  describe '#execute' do
    before do
      BlueGreenWorkers.configure do |config|
        config.determine_active_cluster { active_cluster }
        config.cluster_name = cluster_name
      end
    end

    context 'when our cluster is not active' do
      let(:cluster_name) { 'inactive' }
      let(:active_cluster) { 'active' }

      it 'does not execute the worker' do
        ran = false
        described_class.execute { ran = true }
        expect(ran).to be false
      end

      it 'sleeps for delay: seconds' do
        expect(described_class).to receive(:sleep).with 10
        described_class.execute(delay: 10) { true }
      end
    end

    context 'when our cluster is active' do
      let(:cluster_name) { 'active' }
      let(:active_cluster) { 'active' }

      it 'executes the worker' do
        ran = false
        described_class.execute { ran = true }
        expect(ran).to be true
      end
    end
  end

  it 'checks for active cluster every refresh_interval seconds' do
    times = 0
    BlueGreenWorkers.configure do |config|
      config.refresh_interval = 0.1
      config.cluster_name = 'us'
      config.determine_active_cluster do
        times += 1
      end
    end
    sleep 1

    expect(times).to be_between(9, 11).inclusive
  end

  it 'initializes active cluster' do
    BlueGreenWorkers.configure do |config|
      config.cluster_name = 'us'
      config.refresh_interval = 10
      config.determine_active_cluster { 'active' }
    end
    expect(BlueGreenWorkers.active_cluster).to eq 'active'
  end

  it 'activates on initialization' do
    active = false
    BlueGreenWorkers.configure do |config|
      config.cluster_name = 'active'
      config.determine_active_cluster { 'active' }
      config.activate { active = true }
    end

    expect(active).to be true
  end

  it 'does not deactivate on initialization ' do
    called = false
    BlueGreenWorkers.configure do |config|
      config.cluster_name = 'us'
      config.determine_active_cluster { 'them' }
      config.deactivate { called = true }
    end

    expect(called).to be false
  end

  context 'when our cluster is active' do
    before do
      @active = true
      @active_cluster = 'us'

      BlueGreenWorkers.configure do |c|
        c.refresh_interval = 0.1
        c.deactivate { @active = false }
        c.determine_active_cluster { @active_cluster }
        c.cluster_name = 'us'
      end
    end

    it 'calls deactive block when we are deactivated' do
      @active_cluster = 'them'
      expect { @active }.to eventually be false
    end
  end
end
