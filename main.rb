# Load the script from the `lib` directory
require_relative 'lib/AppConfigLoader'
require_relative 'lib/LoggerManager'
require_relative 'lib/Item'
require_relative 'lib/Cart'
require_relative 'lib/Configurator'
require_relative 'lib/SimpleWebsiteParser'

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

# Створюємо Cart і додаємо тестові товари
cart = Cart.new
cart.generate_test_items(5)

# Показуємо всі товари
cart.show_all_items

# Перевіряємо лічильник об'єктів
puts "Object count: #{Cart.object_count}"

# Видаляємо товар
cart.remove_item(cart.items.first)

# Видаляємо всі товари
cart.delete_items

# Створюємо новий екземпляр Configurator
configurator = Configurator.new

# Перевіряємо початкові конфігураційні параметри
puts "Initial config: #{configurator.config}"

# Налаштовуємо конфігураційні параметри
configurator.configure(
  run_website_parser: 1,      # Включити розбір сайту
  run_save_to_csv: 1,         # Включити збереження даних в CSV
  run_save_to_yaml: 1,       # Включити збереження даних в YAML
  run_save_to_sqlite: 1      # Включити збереження даних в SQLite
)

# Перевіряємо налаштовані параметри
puts "Updated config: #{configurator.config}"

# Виводимо список доступних методів конфігурації
puts "Available methods: #{Configurator.available_methods}"

# Тестування парсера
puts 'Starting website scraping...'
scraper = SimpleWebsiteParser.new('config/yaml_config/web_parser.yaml')
scraper.start_parse
scraper. save_all_data_to_csv
puts 'Scraping completed.'

# Перевіряємо результати парсингу
puts "Scraped items: #{scraper.item_collection.size}"
puts "First scraped item: #{scraper.item_collection.first[:name]}" if scraper.item_collection.any?
