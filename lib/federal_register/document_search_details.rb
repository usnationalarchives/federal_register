class FederalRegister::DocumentSearchDetails < FederalRegister::Base
  extend FederalRegister::Utilities

  add_attribute :filters,
                :suggestions

  def self.search(args)
    response = get('/documents/search-details', query: args).parsed_response
    new(response)
  end
end
