# frozen_string_literal: true

module BlueGreenWorkers
  # Config for BlueGreenWorkers
  class Config
    attr_reader :active_cluster_block
    attr_accessor :cluster_name, :refresh_interval, :activate_block,
                  :deactivate_block
    attr_writer :logger

    def activate(&block)
      @activate_block = block
    end

    def deactivate(&block)
      @deactivate_block = block
    end

    def determine_active_cluster(&block)
      @active_cluster_block = block
    end

    def logger
      @logger ||= Logger.new STDOUT
    end

    def validate
      cluster_name || raise('No cluster_name defined')
      active_cluster_block || raise('No determine_active_cluster block defined')
    end
  end
end
