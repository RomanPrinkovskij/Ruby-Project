module ItemContainer
  module ClassMethods
    # Метод для повернення інформації про клас (ім'я та версія)
    def class_info
      "#{name} - Version 1.0"
    end

    # Лічильник кількості створених об'єктів
    def object_count
      @object_count ||= 0
    end

    def increment_object_count
      @object_count = object_count + 1
    end
  end

  module InstanceMethods
    # Додавання товару в колекцію
    def add_item(item)
      @items << item
      LoggerManager.log_processed_file("Item added: #{item.name}")
    end

    # Видалення товару з колекції
    def remove_item(item)
      @items.delete(item)
      LoggerManager.log_processed_file("Item removed: #{item.name}")
    end

    # Видалення всіх товарів з колекції
    def delete_items
      @items.clear
      LoggerManager.log_processed_file('All items deleted.')
    end

    # Псевдоним для методу show_all_items
    def method_missing(method, *args)
      if method == :show_all_items
        @items.each { |item| puts item }
      else
        super
      end
    end

    # Ітерація по всіх товарах
    def each(&)
      @items.each(&)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end
end
