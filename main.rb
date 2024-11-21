# Load the script from the `lib` directory
require_relative 'lib/AppConfigLoader'
require_relative 'lib/LoggerManager'
require_relative 'lib/Item'

# Use the methods from SomeScript
puts Dir.pwd
# Initialize AppConfigLoader
AppConfigLoader.new.load_libs

# Завантаження конфігурацій
config_loader = AppConfigLoader.new
config_loader.config('config/yaml_config/default_config.yaml', 'config/yaml_config') do |config|
  config_loader.pretty_print_config_data
end

# Ініціалізація логування
LoggerManager.initialize_logger
LoggerManager.log_processed_file('Started scraping books.')

# Створення нового товару
item = Item.new(name: 'Laptop', price: 1000, description: 'High-performance laptop', category: 'Electronics') do |i|
  i.image_path = 'laptop_image.png' # Дополнительная настройка через блок
end

# Виведення інформації про товар
puts item.info

# Оновлення атрибутів товару
item.update do |i|
  i.name = 'Gaming Laptop'
  i.price = 1500
  i.description = 'High-performance gaming laptop'
end

# Виведення оновленої інформації
puts item.info

# Генерація фіктивного товару
fake_item = Item.generate_fake
puts "Generated fake item: #{fake_item.info}"

# Порівняння двох товарів
item2 = Item.new(name: 'Smartphone', price: 500, description: 'Latest model smartphone', category: 'Electronics',
                 image_path: 'smartphone_image.png')
puts "Is the first item more expensive than the second? #{item > item2}"

# Логування обробки товару
LoggerManager.log_processed_file("Processed item: #{item.name}, #{item.price}")
