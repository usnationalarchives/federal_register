class FederalRegister::Base < FederalRegister::Client
  attr_reader :attributes

  def self.add_attribute(*attributes)
    options = {}

    if attributes.last.is_a?(Hash)
      options = attributes.pop
    end

    attributes.each do |attr|
      define_method attr do
        val = @attributes[attr.to_s]
        if val && options[:type] == :date
          val = Date.strptime(val.to_s)
        end

        if ! val && ! full? && respond_to?(:json_url) && @attributes['json_url']
          fetch_full
          val = send(attr)
        end
        val
      end
    end
  end

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

  def self.override_base_uri(uri)
    [FederalRegister::Agency, FederalRegister::Article, FederalRegister::Base, FederalRegister::Client, FederalRegister:: ResultSet].each do |klass|
      klass.base_uri(uri)
    end
  end

  private
  
  attr_reader :attributes
end
