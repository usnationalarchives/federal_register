class FederalRegister::Client
  include HTTParty
  
  class RecordNotFound < HTTParty::ResponseError; end
  class ServerError < HTTParty::ResponseError; end
  
  base_uri 'http://api.federalregister.gov/v1'
  
  def self.get(url, *options)
    response = super
    
    case response.code
    when 200
      response
    when 404
      raise RecordNotFound.new(response)
    when 500
      raise ServerError.new(response)
    else
      raise HTTParty::ResponseError.new(response)
    end
  end
end
