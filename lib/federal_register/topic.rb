class FederalRegister::Topic < FederalRegister::Base
  add_attribute :name,
                :slug,
                :url

  def self.suggestions(args={})
    response = get("/topics/suggestions", query: args)

    response.map do |hsh|
      new(hsh, :full => true)
    end
  end
end
