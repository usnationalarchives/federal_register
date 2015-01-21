class FederalRegister::FacetResultSet < FederalRegister::Client
  include Enumerable

  attr_reader :conditions

  def initialize(attributes, result_class, options={})
    @result_class = result_class
    @conditions = options[:query] || {}

    @results = (attributes || {}).map do |slug, attributes|
      attributes["slug"] = slug
      @result_class.new(attributes, options.merge(:result_set => self) )
    end
  end

  def self.fetch(url, options = {})
    result_class = options.delete(:result_class)
    response = get(url, options)
    new(response, result_class, options)
  end

  def each
    @results.each {|result| yield result }
  end
end
