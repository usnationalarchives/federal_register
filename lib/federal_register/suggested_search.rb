class FederalRegister::SuggestedSearch < FederalRegister::Base
  add_attribute :description,
                :documents_in_last_year,
                :documents_with_open_comment_periods,
                :position,
                :search_conditions,
                :section,
                :slug,
                :title

  def self.search(args={})
    response = get('/suggested_searches', query: args)

    responses = {}
    response.map do |section, searches|
      responses[section] = searches.map{|attributes| new(attributes)}
    end

    responses
  end

  def self.find(slug)
    response = get("/suggested_searches/#{slug}")
    new(response)
  end
end
