class FederalRegister::Facet::PublicInspectionIssue < FederalRegister::Base
  add_attribute :slug
  attr_reader :conditions

  def initialize(attributes, options = {})
    @conditions = options[:query] || {}
    super
  end

  def special_filings
    @special_filings ||= filing_class.new(attributes['special_filings'])
  end

  def regular_filings
    @regular_filings ||= filing_class.new(attributes['regular_filings'])
  end

  def self.search(args={})
    response = get(url, query: args)

    response.map do |slug, attributes|
      attributes['slug'] = slug
      new(attributes, query: args)
    end
  end
end
