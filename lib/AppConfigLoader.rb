require 'erb'
require 'yaml'
require 'json'
require 'active_support/core_ext/hash/deep_merge'

class AppConfigLoader
  def config(config_file, config_dir)
    @config = load_default_config(config_file)
    load_config(config_dir)
    yield @config if block_given?
  end

  def pretty_print_config_data
    puts JSON.pretty_generate(@config)
  end

  def load_default_config(config_file)
    config_data = ERB.new(File.read(config_file)).result
    YAML.load(config_data)
  end

  def load_config(config_dir)
    Dir.glob("#{config_dir}/*.yaml").each do |config_file|
      next if config_file == 'default_config.yaml'

      config_data = YAML.load_file(config_file)
      @config.deep_merge!(config_data)
    end
  end

  def load_libs
    # Підключаємо системні бібліотеки
    require 'date'

    # Підключаємо локальні бібліотеки
    Dir.glob('lib/*.rb').each do |lib_file|
      require_relative File.basename(lib_file, '.rb')
    end
  end
end
