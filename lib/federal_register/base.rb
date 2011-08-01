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
    @full = true # noop unless subclassed and made real
  end
  
  private
  
  attr_reader :attributes
  
  def method_missing(name, *args)
    if attributes.has_key?(name.to_s)
      attributes[name.to_s]
    elsif self.class::ATTRIBUTES.include?(name.to_sym) && ! full?
      fetch_full
      method_missing(name,*args)
    else
      super
    end
  end
end