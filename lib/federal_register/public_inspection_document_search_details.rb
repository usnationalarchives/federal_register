class FederalRegister::PublicInspectionDocumentSearchDetails < FederalRegister::Base
  extend FederalRegister::Utilities

  add_attribute :filters,
                :suggestions

  def self.search(args)
    response = get('/public-inspection-documents/search-details', query: args).parsed_response
    new(response)
  end
end