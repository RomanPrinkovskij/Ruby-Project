require 'logger'
require 'yaml'

class LoggerManager
  class << self
    attr_reader :logger

    def initialize_logger
      config = load_logging_config['logging'] # Access the 'logging' section

      # Debugging: Print the config to check if it's loaded correctly
      puts "Loaded logging config: #{config}"

      # Ensure directory exists, create it if needed
      Dir.mkdir(config['directory']) unless Dir.exist?(config['directory'])

      @logger = Logger.new(File.join(config['directory'], config['files']['application_log']))
      @logger.level = case config['level'].upcase
                      when 'DEBUG' then Logger::DEBUG
                      when 'INFO' then Logger::INFO
                      when 'WARN' then Logger::WARN
                      when 'ERROR' then Logger::ERROR
                      when 'FATAL' then Logger::FATAL
                      else Logger::UNKNOWN
                      end
    end

    def log_processed_file(message)
      @logger.info("Processed: #{message}")
    end

    def log_error(message)
      @logger.error("Error: #{message}")
    end

    private

    def load_logging_config
      config_path = 'config/yaml_config/logging.yaml'

      raise "Logging configuration file not found: #{config_path}" unless File.exist?(config_path)

      YAML.load_file(config_path)
    end
  end
end
