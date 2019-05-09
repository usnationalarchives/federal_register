class FederalRegister::Facet::PublicInspectionIssue::TypeFiling < FederalRegister::Facet::PublicInspectionIssue
  attr_reader :document_types, :search_conditions

  def initialize(attributes, conditions, options={})
    @search_conditions = conditions
    @document_types = attributes.map{|k,v| DocumentTypeFacet.new(k, v, @search_conditions)}
  end

  private

  class DocumentTypeFacet
    attr_reader :count, :name, :search_conditions

    def initialize(type, attributes, search_conditions)
      @count = attributes['count']
      @name = attributes['name']
      @search_conditions = search_conditions.deep_merge({
        conditions: {type: Array(type)}
      })
    end
  end
end
