class FederalRegister::Section < FederalRegister::Base
  add_attribute :name,
                :slug


  def self.search(args={})
    response = get('/sections', query: args)

    response.map do |attributes|
      new(attributes)
    end
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
