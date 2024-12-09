class Configurator
  attr_reader :config

  # Ініціалізація конфігураційних параметрів за замовчуванням
  def initialize
    @config = {
      run_website_parser: 0,  # Запуск розбору сайту
      run_save_to_csv: 0,     # Збереження даних в CSV форматі
      run_save_to_json: 0,    # Збереження даних в JSON форматі
      run_save_to_yaml: 0,    # Збереження даних в YAML форматі

    }
  end

  # Налаштування конфігураційних параметрів через хеш
  def configure(overrides = {})
    overrides.each do |key, value|
      if @config.key?(key)
        @config[key] = value
      else
        puts "Warning: Invalid configuration key - #{key}"
      end
    end
  end

  # Класовий метод, який повертає список доступних конфігураційних параметрів
  def self.available_methods
    {
      run_website_parser: 'Запуск розбору сайту',
      run_save_to_csv: 'Збереження даних в CSV форматі',
      run_save_to_json: 'Збереження даних в JSON форматі',
      run_save_to_yaml: 'Збереження даних в YAML форматі',

    }
  end
end
