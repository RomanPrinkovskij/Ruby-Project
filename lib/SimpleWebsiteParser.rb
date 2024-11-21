require 'mechanize'
require 'yaml'
require 'logger'
require 'fileutils'
require 'thread'

class SimpleWebsiteParser
  attr_reader :config, :agent, :item_collection

  def initialize(config_file)
    @config = load_config(config_file)
    @agent = Mechanize.new
    @item_collection = []
    @logger = Logger.new('parser.log')
  end

  def load_config(config_file)
    YAML.load_file(config_file)
  end

  def start_parse
    @logger.info(@config)
    if @config['start_page'].nil? || @config['start_page'].empty?
      @logger.error('Не вказано URL стартової сторінки в конфігурації!')
      return
    end
    @logger.info("Парсинг стартує для URL: #{@config['start_page']}")
    if check_url_response(@config['start_page'])
      page = @agent.get(@config['start_page'])
      product_links = extract_products_links(page)
      parse_products(product_links)
    else
      @logger.error('Стартова сторінка недоступна.')
    end
  end

  def check_url_response(url)
    @logger.info("Sending request to URL: #{url}")
    response = @agent.get(url)
    @logger.info("Response code: #{response.code}")
    response.code.to_i == 200
  rescue StandardError => e
    @logger.error("Error checking URL #{url}: #{e.message}")
    false
  end

  def extract_products_links(page)
    @logger.info('Витягуємо посилання на продукти...')
    links = page.search(@config['product_links_selector']).map { |link| link['href'] }.uniq

    # Перевірка, чи є лінк абсолютним, і комбінування з базовим URL
    links.map! do |link|
      # Якщо посилання вже абсолютне
      if link.start_with?('http')
        link
      else
        # Якщо це відносне посилання, комбінуємо з базовим URL
        URI.join(page.uri.to_s, link).to_s
      end
    end

    @logger.info("#{links.size} посилань на продукти знайдено.")
    links
  end

  def parse_products(product_links)
    @logger.info('Парсинг сторінок продуктів...')
    threads = []
    product_links.each do |link|
      threads << Thread.new { parse_product_page(link) }
    end
    threads.each(&:join)
  end

  def parse_product_page(product_link)
    @logger.info("Парсинг продукту: #{product_link}")
    if check_url_response(product_link)
      page = @agent.get(product_link)
      product = extract_product_details(page)
      @item_collection << product
    else
      @logger.error("Продукт #{product_link} недоступний.")
    end
  end

  def extract_product_details(product_page)
    {
      name: extract_product_name(product_page),
      price: extract_product_price(product_page),
      description: extract_product_description(product_page),
      image_url: extract_product_image(product_page),
      category: extract_product_category(product_page) # Dynamic category extraction
    }
  end

  def extract_product_name(product)
    product.search(@config['product_name_selector']).text.strip
  end

  def extract_product_price(product)
    product.search(@config['product_price_selector']).text.strip
  end

  def extract_product_description(product)
    product.search(@config['product_description_selector']).text.strip
  end

  def extract_product_image(product)
    image_element = product.search(@config['product_image_selector']).first
    if image_element.nil?
      @logger.error('Не знайдено зображення для продукту.')
      return nil
    end
    image_url = image_element['src']
    save_product_image(image_url, product) if image_url
    image_url
  end

  def extract_product_category(product)
    product.search('.breadcrumb li:nth-child(3) a').text.strip
  rescue StandardError => e
    @logger.error("Не вдалося отримати категорію продукту: #{e.message}")
    nil
  end

  def save_product_image(image_url, product_page)
    # Extract the category dynamically from the product page
    category = extract_product_category(product_page)

    # If no category is found, default to a generic folder
    category = 'uncategorized' if category.nil? || category.empty?

    image_filename = File.basename(image_url)
    dir_path = File.join('media_dir', category)

    FileUtils.mkdir_p(dir_path) unless File.exist?(dir_path)

    image_path = File.join(dir_path, image_filename)
    File.binwrite(image_path, @agent.get(image_url).body)
    @logger.info("Зображення збережено: #{image_path}")
  end
end
