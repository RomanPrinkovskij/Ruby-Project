require 'json'
require 'csv'
require 'yaml'
require_relative 'ItemContainer'
require_relative 'LoggerManager'
require_relative 'Item'

class Cart
  include ItemContainer

  attr_accessor :items

  # Конструктор
  def initialize
    @items = []
    self.class.increment_object_count
  end

  # Зберігання в текстовий файл
  def save_to_file(filename)
    File.open(filename, 'w') do |file|
      @items.each { |item| file.puts item.to_s }
    end
    LoggerManager.log_processed_file("Items saved to file: #{filename}")
  end

  # Зберігання в форматі JSON
  def save_to_json(filename)
    File.write(filename, @items.map(&:to_h).to_json)
    LoggerManager.log_processed_file("Items saved to JSON: #{filename}")
  end

  # Зберігання в форматі CSV
  def save_to_csv(filename)
    CSV.open(filename, 'w') do |csv|
      csv << ['Name', 'Price', 'Description', 'Category', 'Image Path']
      @items.each { |item| csv << [item.name, item.price, item.description, item.category, item.image_path] }
    end
    LoggerManager.log_processed_file("Items saved to CSV: #{filename}")
  end

  # Зберігання в форматі YAML
  def save_to_yml(filename)
    @items.each_with_index do |item, index|
      File.write("#{filename}_#{index}.yml", item.to_h.to_yaml)
    end
    LoggerManager.log_processed_file('Items saved to YAML.')
  end

  # Генерація тестових товарів
  def generate_test_items(count)
    count.times do
      add_item(Item.generate_fake)
    end
    LoggerManager.log_processed_file("#{count} test items generated.")
  end
end
