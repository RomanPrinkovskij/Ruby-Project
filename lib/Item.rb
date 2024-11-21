require 'faker'
require 'logger'
require 'yaml'
require_relative 'LoggerManager' # Assuming LoggerManager is already implemented

class Item
  include Comparable

  # Атрибути класу
  attr_accessor :name, :price, :description, :category, :image_path

  # Конструктор
  def initialize(attributes = {})
    # Встановлюємо значення за замовчуванням, якщо не передано
    @name = attributes[:name] || 'Unknown Item'
    @price = attributes[:price] || 0.0
    @description = attributes[:description] || 'No description available.'
    @category = attributes[:category] || 'General'
    @image_path = attributes[:image_path] || 'no_image.png'

    # Логування ініціалізації
    LoggerManager.log_processed_file("Item initialized: #{@name}, #{@price}")

    # Якщо передано блок для додаткової настройки
    yield(self) if block_given?
  end

  # Формуємо рядок для виведення інформації про об'єкт
  def to_s
    "Item: #{@name}, Price: #{@price}, Description: #{@description}, Category: #{@category}, Image: #{@image_path}"
  end

  # Перетворюємо об'єкт на хеш
  def to_h
    {
      name: @name,
      price: @price,
      description: @description,
      category: @category,
      image_path: @image_path
    }
  end

  # Для зручного відображення об'єкта
  def inspect
    "#<Item name='#{@name}', price=#{@price}, category='#{@category}'>"
  end

  # Оновлення атрибутів через блок
  def update
    yield(self) if block_given?
  end

  # Псевдонім для to_s
  alias info to_s

  # Генерація фіктивного об'єкта за допомогою Faker
  def self.generate_fake
    new(
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price,
      description: Faker::Lorem.sentence,
      category: Faker::Commerce.department,
      image_path: Faker::Avatar.image
    )
  end

  # Порівняння об'єктів за ціною
  def <=>(other)
    return nil unless other.is_a?(Item)

    @price <=> other.price
  end
end
