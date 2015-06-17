class FederalRegister::Facet < FederalRegister::Base
  extend FederalRegister::Utilities

  attr_reader :result_set

  add_attribute :count,
    :name,
    :slug

  def self.search(args={})
    FederalRegister::FacetResultSet.fetch(
      url, :query => args, :result_class => self
    )
  end

  def initialize(attributes={}, options={})
    @result_set = options.delete(:result_set)

    super(attributes, options)
  end
end
