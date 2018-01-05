# frozen_string_literal: true

require 'blue_green_workers/version'
require 'blue_green_workers/config'
require 'logger'

# Main module for blue_green_workers
module BlueGreenWorkers
  def self.active_cluster
    if config.refresh_interval.positive?
      @active_cluster
    else
      determine_active_cluster
    end
  end

  def self.configure
    yield config
    determine_active_cluster
    (config.refresh_interval || 0).positive? && start_refresh_thread
    config.validate
  end

  def self.when_active(opts = {})
    if config.active_cluster_block.call == config.cluster_name
      yield
    else
      logger.debug 'Cluster not active, skipping BlueGreenWorkers#when_active'
      opts[:delay] && sleep(opts[:delay])
      opts[:return]
    end
  end

  def self.shutdown
    logger.warn 'Shutting down BlueGreenWotkers!'
    @refresh_thread&.kill
    @active_cluster = nil
    @refresh_thread = nil
    @config = nil
  end

  # private
  def self.activate
    logger.info 'BlueGreenWorkers cluster activating!'
    config.activate_block&.call
  end

  def self.deactivate
    logger.info 'BlueGreenWorkers cluster deactivating!'
    config.deactivate_block&.call
  end

  def self.active_cluster=(cluster)
    if cluster != @active_cluster
      if cluster == config.cluster_name
        activate
      elsif @active_cluster == config.cluster_name
        deactivate
      end
    end
    @active_cluster = cluster
  end

  def self.config
    @config ||= Config.new
  end

  def self.determine_active_cluster
    self.active_cluster = config.active_cluster_block.call
  end

  def self.logger
    config.logger
  end

  def self.refresh_thread
    logger.info "BlueGreenWorkers refreshing every #{config.refresh_interval}s"
    @refresh_thread ||= Thread.new { refresh_loop }
  end

  def self.refresh_loop
    loop do
      begin
        determine_active_cluster
        sleep config.refresh_interval
      rescue StandardError => err
        Logger.error "Error during refresh: #{err} #{err.backtrace.join "\n"}"
      end
    end
  end

  def self.start_refresh_thread
    refresh_thread
  end

  private_class_method :active_cluster=, :config, :determine_active_cluster,
                       :logger, :refresh_thread, :start_refresh_thread,
                       :refresh_loop
end
