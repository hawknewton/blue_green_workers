# frozen_string_literal: true

module BlueGreenWorkers
  RSpec.describe Config do
    describe '#validate' do
      let(:cluster_name) { 'test' }
      let(:active_cluster_block) { proc {} }

      subject(:validate) do
        instance = Config.new.tap do |config|
          config.determine_active_cluster(&active_cluster_block)
          config.cluster_name = cluster_name
        end
        instance.validate
      end

      context 'given a cluster name and active cluster block' do
        it 'does not raise an error' do
          expect { validate }.to_not raise_error
        end
      end

      context 'given no cluster_name' do
        let(:cluster_name) { nil }

        it 'raises an error' do
          expect { validate }.to raise_error(/No cluster_name defined/)
        end
      end

      context 'given no determine_active_cluster block' do
        let(:active_cluster_block) { nil }

        it 'raises an error' do
          expect { validate }.to raise_error(
            /No determine_active_cluster block defined/
          )
        end
      end
    end
  end
end
