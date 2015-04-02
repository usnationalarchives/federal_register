class FederalRegister::Facet::PublicInspectionIssue::TypeFiling < FederalRegister::Facet::PublicInspectionIssue
  attr_reader :document_types

  def initialize(attributes, options={})
    @document_types = attributes.map{|k,v| DocumentTypeFacet.new(v)}
  end

  private

  class DocumentTypeFacet
    attr_reader :count, :name
    def initialize(attributes)
      @count = attributes['count']
      @name = attributes['name']
    end
  end
end
