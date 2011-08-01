class FederalRegister::Agency < FederalRegister::Base
  ATTRIBUTES = [
    :id,
    :name,
    :short_name,
    :url,
    :description,
    :url,
    :recent_articles_url,
    :logo,
    :json_url
  ]
  
  def self.all
    response = get('/agencies.json')
    if response.success?
      response.map do |hsh|
        new(hsh, :full => true)
      end
    else
      raise response.inspect
    end
  end
  
  def logo_url(size)
    if attributes.has_key?("logo")
      attributes["logo"]["#{size}_url"] || raise("size '#{size}' not a valid image size")
    end
  end
end