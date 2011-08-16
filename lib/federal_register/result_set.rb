class FederalRegister::ResultSet < FederalRegister::Client
  include Enumerable

  attr_reader :count, :total_pages, :results, :errors
  
  def initialize(attributes, result_class)
    @result_class = result_class
    @count = attributes['count']
    @total_pages = attributes['total_pages']
    @results = (attributes['results'] || []).map{|result| @result_class.new(result) }
    
    @prev_url = attributes['previous_page_url']
    @next_url = attributes['next_page_url']
    @errors   = attributes['errors']
  end
  
  def next
    self.class.fetch(@next_url, :result_class => @result_class) if @next_url
  end
  
  def previous
    self.class.fetch(@prev_url, :result_class => @result_class) if @prev_url
  end
  
  def self.fetch(url, options = {})
    result_class = options.delete(:result_class)
    response = get(url, options)
    new(response, result_class)
  end

  def each
    @results.each {|result| yield result }
  end
end
