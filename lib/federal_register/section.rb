class FederalRegister::Section < FederalRegister::Base
  add_attribute :name

  def self.search(args={})
    response = get('/sections', query: args)

    responses = {}
    response.map do |section, attributes|
      responses[section] = new(attributes)
    end

    responses
  end

  def highlighted_documents
    @highlighted_documents ||= attributes['highlighted_documents'].map do |attributes|
      highlighted_document_class.new(attributes)
    end
  end

  private

  def highlighted_document_class
    FederalRegister::HighlightedDocument
  end
end
