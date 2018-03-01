class FederalRegister::Topic < FederalRegister::Base
  add_attribute :name,
                :slug,
                :url

  def self.suggestions(args={})
    response = get("/topics/suggestions", query: args).parsed_response

    response.map do |hsh|
      new(hsh, :full => true)
    end
  end
end
