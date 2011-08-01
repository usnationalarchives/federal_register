class FederalRegister::Base < FederalRegister::Client
  attr_reader :attributes
  def initialize(attributes = {}, options = {})
    @attributes = attributes
    @full = options[:full] || false
  end
  
  def full?
    @full
  end
  
  def fetch_full
    @attributes = self.class.get(json_url)
    @full = true
    self
  end
  
  private
  
  attr_reader :attributes
  
  def method_missing(name, *args)
    if attributes.has_key?(name.to_s)
      attributes[name.to_s]
    elsif self.class::ATTRIBUTES.include?(name.to_sym)
      if ! full? && @attributes['json_url']
        fetch_full
        method_missing(name,*args)
      else
        nil
      end
    else
      super
    end
  end
end