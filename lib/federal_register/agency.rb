class FederalRegister::Agency < FederalRegister::Base
  add_attribute :description,
                :json_url,
                :logo,
                :name,
                :recent_articles_url,
                :short_name,
                :slug,
                :url
  add_attribute :id,
                :parent_id,
                :type => :integer

  def self.all(options={})
    get_options = {}
    get_options.merge!(:query => {:fields => options[:fields]}) if options[:fields]

    response = get('/agencies.json', get_options)

    response.map do |hsh|
      new(hsh, :full => true)
    end
  end

  def logo_url(size)
    if attributes.has_key?("logo")
      attributes["logo"]["#{size}_url"] || raise("size '#{size}' not a valid image size")
    end
  end
end
